local Handler = {}

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local DataHandler = require(game.ReplicatedStorage.Data)
local Worker = require(LocalPlayer.PlayerScripts:WaitForChild("ClientWorker")).create("RenderWorker2", 7, script.Parent.Actor,script.Parent.Tasks)
local Queue = require(game.ReplicatedStorage.Libarys.DataStructures.Queue)
local Search = require(script.Parent.Helper.Search)
local Builder = require(script.Parent.Helper.Build)

local Config = require(script.Parent.Config)

local ChunkTable = DataHandler.getAllChunks()

local Start_Time = os.clock()
local Updated = false

--//Max
local MAX_SUBCHUNKS = 126
local MAX_CULL = 10
--//Queues
local SubChunkQueue = Queue.new(100)
local CullQueue = Queue.new(100)
--//InQueue
local SubChunkInQueue = {}
local CullInQueue = {}

--//Handlers
local function HandleSubChunk(chunk)
    local x,y,z = chunk.X,chunk.Y,chunk.Z
    local Chunk = DataHandler.getChunk(x,z) or {}
    local TransparencyBuffer = Chunk.TransparencyBuffer
    if not TransparencyBuffer then return true end  
    local Data = Worker:DoWork("ComputeFlood",y,TransparencyBuffer,Start_Time)
    if not Data then return false end 
    Chunk.SubChunks[y] = Data
    Updated = true
    return true
end

local function HandleCull(chunk)
    if CullInQueue[chunk] == 2 then return true end 
    local Main = ChunkTable[chunk]
    if not Main then return true end 
    local n,e,s,w = ChunkTable[chunk+Vector3.xAxis],ChunkTable[chunk+Vector3.zAxis],ChunkTable[chunk-Vector3.xAxis],ChunkTable[chunk-Vector3.zAxis]
    if not( n and e and s and w and Main) then return  end 
    n,e,s,w = n.TransparencyBuffer,e.TransparencyBuffer,s.TransparencyBuffer,w.TransparencyBuffer
    local Layers = Main.CurrentlyLoaded
    local MainTrans = Main.TransparencyBuffer
    if not( n and e and s and w and MainTrans and Layers) then return end 
    local Data = Worker:DoWork("ComputeCull",chunk,Main.Blocks,MainTrans,n,e,s,w,Layers,Start_Time)

    if not Data then return false end 

    Builder.addToQueue(chunk, Data)
    return true
end

local debugModel = Instance.new("Model")
debugModel.Name = "Debug"
debugModel.Parent = workspace

local function HandlerSearch()
  --  print("start")
    local data = Search.update(Updated, Start_Time)
  --  print("done",data and true or false)
    Updated = false

    if not data then return data == false and 1 end 
    local checked = {}
    for loc,sectionBuffer in data do
        checked[loc] = true
        local chunk = DataHandler.getChunk(loc.X,loc.Z)
        if not chunk then continue end 
        local sections = chunk.CurrentlyLoaded
        local changed = false
        for i =0,31 do
            local value = buffer.readu8(sectionBuffer, i)
            if value == 0 then continue end
            local oldValue = buffer.readu8(sections, i)
            if oldValue == 0 then
                changed = true
                buffer.writeu8(sections, i,1)
            end
        end



        if not changed then
            continue
        elseif  CullInQueue[loc] then
            CullInQueue[loc]  = true
            continue
        end



        CullInQueue[loc]  = true
        Queue.enqueue(CullQueue, loc)
    end
    for i,v in CullInQueue do
        if not checked[i] then
           -- CullInQueue[i] = 2
        end
    end
    return 2 
end

local function HandleBuild()
    return Builder.run(Start_Time) 
end

--//Loops
local function SubChunkLoop()
    local Times = 0
    for i = 1,MAX_SUBCHUNKS do
        local toDo = Queue.dequeue(SubChunkQueue)
        if not toDo then break end 
        Times+=1
        task.spawn(function()
            local passed = HandleSubChunk(toDo)
            if not passed then
                Queue.enqueue(SubChunkQueue, toDo)
            else
                SubChunkInQueue[toDo] = nil
            end
        end)
    end
    return Times <12
end

local function CullLoop()
    local Times = 0
    for i = 1,MAX_CULL do
        local toDo = Queue.dequeue(CullQueue)
        if not toDo then break end 
        Times+=1
        task.spawn(function()
            local passed = HandleCull(toDo)
            if not passed then
                Queue.enqueue(CullQueue, toDo)
            else
                CullInQueue[toDo] = nil
            end
        end)
    end
    return Times <4
end

local function sleep()
    return 2
end

local Current_ = 1
local iter_s = 1

local SingleOrder = {
    HandlerSearch,
    HandleBuild,
}

local function SingleThreadRunner()
    if Current_ > #SingleOrder then
        Current_ = 1
    end
    local value = SingleOrder[Current_]()
    --print(value,Current_)
    iter_s +=1
    if value == 1 and iter_s < #SingleOrder+2 then
        Current_ += 1
        SingleThreadRunner()
    end
    if value ~= 2 then return end
    Current_ += 1
end

local function Other()
    if Config.ANTI_LAG then
        return true
    end
    return SingleThreadRunner()
end

local RunnerOrder = {
    Other,
    SubChunkLoop,
    CullLoop
}

local index_ = 0
local iter_ = 0
local function RecursiveRunner()
    iter_+=1
    if iter_ > #RunnerOrder+2 then
        return
    end
    index_+=1
    if not RunnerOrder[index_] then
        index_ = 0
        return RecursiveRunner()
    end
    if RunnerOrder[index_](index_) then
        return RecursiveRunner()
    end
    return 
end


local function getSize(t)
    local tc = 0
    for i,v in t do
        tc+=1
    end
    return tc
end

function Handler.getStatus()
    return getSize(SubChunkQueue)-2,getSize(CullQueue)-2,getSize(Builder.Queue)-2
end

function Handler.renderNewChunk(chunk)
    for i = 0,31 do
        local pos = chunk + Vector3.yAxis*i
        if SubChunkInQueue[pos] then continue end 
        Queue.enqueue(SubChunkQueue, pos)
    end
end

function Handler.requestDeload(chunk)
    Builder.deload(chunk)
end

RunService.RenderStepped:Connect(function()
    Start_Time = os.clock()
end)

RunService.Heartbeat:Connect(function()
    if not DataHandler.getPlayerEntity() or game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Q) then return end 
    iter_ = 0
    iter_s = 0
    RecursiveRunner()
    if Config.ANTI_LAG then 
        SingleThreadRunner()
    end
end)

return Handler