local Handler = {}

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local DataHandler = require(game.ReplicatedStorage.Data)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Worker = require(LocalPlayer.PlayerScripts:WaitForChild("ClientWorker")).create("RenderWorker2", 7, script.Parent.Actor,script.Parent.Tasks)
local Queue = require(game.ReplicatedStorage.Libarys.DataStructures.Queue)
local Search = require(script.Parent.Helper.Search)
local Builder = require(script.Parent.Helper.Build)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)

local Config = require(script.Parent.Config)

local AntiLag = Config.ANTI_LAG

local ChunkTable = DataHandler.getAllChunks()

local Start_Time = os.clock()
local Updated = false
local Center = Vector3.zero

local WALLS = {}

for x = 1, 8 do
    WALLS[x] = {}
    for z = 1, 8 do
        WALLS[x][z] = {}
        
        if x == 1 then
            table.insert(WALLS[x][z], Vector3.new(-1, 0, 0)) 
        elseif x == 8 then
            table.insert(WALLS[x][z], Vector3.new(1, 0, 0))  
        end

        if z == 1 then
            table.insert(WALLS[x][z], Vector3.new(0, 0, -1))
        elseif z == 8 then
            table.insert(WALLS[x][z], Vector3.new(0, 0, 1))  
        end
    end
end

local function CheckWalls(lx, lz)
    if lx < 1 or lx > 8 or lz < 1 or lz > 8 then
        return false 
    end
    return WALLS[lx][lz]
end

local SearchIndex = 0
local SearchIDX = {Value = 1}
--//Max
local MAX_LARGESUBCHUNKS = AntiLag and 10 or 10
local MAX_SUBCHUNKS = AntiLag and 126 or 15
local MAX_CULL = AntiLag and 10 or 4
--//Queues
local SubChunkQueue = Queue.new(100)
local LargeSubChunkQueue = Queue.new(100)
local CullQueue = {}
--//InQueue
local SubChunkInQueue = {}

local ForceCull = {}

--//Handlers
local function HandleSubChunk(chunk)
    local x,y,z = chunk.X,chunk.Y,chunk.Z
    local Chunk = DataHandler.getChunk(x,z) or {}
    local TransparencyBuffer = Chunk.TransparencyBuffer
    if not TransparencyBuffer then return true end  
    local Data = Worker:DoWork("ComputeFlood",y-1,TransparencyBuffer,Start_Time)
    if not Data then return false end 
    Chunk.SubChunks[y] = Data
    Updated = true
    local newC = Vector3.new(x,0,z)
    task.delay(1/10, function()
        ForceCull[newC] = SearchIDX.Value
        Updated = true
    end)
    return true
end

local function HandleLargeSubChunk(chunk)
    local x,y,z = chunk.X,chunk.Y,chunk.Z
    local Chunk = DataHandler.getChunk(x,z) or {}
    local TransparencyBuffer = Chunk.TransparencyBuffer
    if not TransparencyBuffer then return true end  
    local Data = Worker:DoWork("ComputeFloodLarge",y,TransparencyBuffer,Start_Time)
    if not Data then return false end 
    local offset = y*8
    for i =1,8 do
        local info = Data[i]
        Chunk.SubChunks[i+offset] = info
    end
    local newC = Vector3.new(x,0,z)
    if #Chunk.SubChunks >= 32 then
        task.delay(1/10, function()
            Chunk.SubChunks.DONE = true
            ForceCull[newC] = SearchIDX.Value
            Updated = true
        end)
    end
    return true
end

local function HandleCull(chunk)
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
    local data = Search.update(Updated, Start_Time,SearchIDX)
  --  print("done",data and true or false)

    if not data then return data == false and 1 end 
    Updated = false
    local checked = {}
    for loc,sectionBuffer in data do
        checked[loc] = true
        local chunk = DataHandler.getChunk(loc.X,loc.Z)
        if not chunk then continue end 
        if not chunk.SubChunks.DONE then continue end 
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



        if (not changed or CullQueue[loc]) and not ForceCull[loc]  then
            continue
        end
        CullQueue[loc]  = true
        -- if ForceCull[loc] and ForceCull[loc]+2> SearchIDX.Value then
        --     continue
        -- end
        ForceCull[loc] = nil 
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
    return Times <24
end

local function LargeSubChunkLoop()
    local Times = 0
    for i = 1,MAX_LARGESUBCHUNKS do
        local toDo = Queue.dequeue(LargeSubChunkQueue)
        if not toDo then break end 
        Times+=1
        task.spawn(function()
            local passed = HandleLargeSubChunk(toDo)
            if not passed then
                Queue.enqueue(LargeSubChunkQueue, toDo)
            end
        end)
    end
    return Times <5
end


local function CullLoop()
    local Times = 0
    debug.profilebegin("SortCull")
    local ComputeToCull = OtherUtils.chunkDictToArray(CullQueue, Center)
    debug.profileend()
    for _,toDo in ComputeToCull do
        if Times > MAX_CULL then break end 
        Times+=1
        task.spawn(function()
            CullQueue[toDo] = nil
            local passed = HandleCull(toDo)
            if  passed then
                CullQueue[toDo] = nil
            else
                CullQueue[toDo] = true
                Times -=1
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
    LargeSubChunkLoop,
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

local function enqueueSub(chunk)
    if SubChunkInQueue[chunk] then return end 
    Queue.enqueue(SubChunkQueue,chunk)
    SubChunkInQueue[chunk] = true
end

function Handler.getStatus()
    return getSize(LargeSubChunkQueue)-2,getSize(CullQueue),getSize(Builder.InQueue)
end

function Handler.renderNewChunk(chunk)
    for i = 0,3 do
        local pos = chunk + Vector3.yAxis*i
        Queue.enqueue(LargeSubChunkQueue, pos)
    end
end

function Handler.blockUpdate(x,y,z)
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local cVector = Vector3.new(cx,0,cz)
    local SubChunk = (y-1)//8+1--1,256 | 1-8 = 1
    enqueueSub(Vector3.new(cx,SubChunk,cz))
    local nearBy = CheckWalls(lx,lz)
    if not nearBy then return end 
    for i,Offset in nearBy do
        local chunk = cVector + Offset
        if not Builder.Rendered[chunk] then
            continue
        end
        CullQueue[chunk] = true
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
    local camera = workspace.CurrentCamera.CFrame.Position/3
    local cx,cy = ConversionUtils.getChunk(camera.X,camera.Y,camera.Z)
    Center = Vector3.new(cx,0,cy)
    iter_ = 0
    iter_s = 0
    RecursiveRunner()
    if Config.ANTI_LAG then 
        local pass,err  = pcall(SingleThreadRunner)
        if not pass then print(err) end 
    end
end)

return Handler