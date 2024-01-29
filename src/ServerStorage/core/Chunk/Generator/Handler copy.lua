local Handler = {}
local RunService = game:GetService("RunService")
local Configs = require(script.Parent.Config)

local began = debug.profilebegin
local close = debug.profileend

--//Settings
local MaxResume = Configs.MaxResume
local MaxBuild = Configs.MaxBuild
local MaxCarver = Configs.MaxCarver
local MaxFeature = Configs.MaxFeature

--//Requires
local Queue = require(game.ReplicatedStorage.Libarys.DataStructures.Queue)
local Generator = game.ServerStorage.Generation.generation
local RegionHelper = require(script.Parent.RegionHelper)
local LocalChunk = require(script.Parent.LocalChunk)
local Communicator = require(script.Parent.Communicator)
local Storage = require(script.Parent.ChunkDataLocal)
local Overworld = require(script.Parent.OverworldActorLayer)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)

local Start_Time = os.clock()
local _,ACTORID = Communicator.getActor()

Overworld.Init()
local preComputedArea = OtherUtils.preComputeSquare(Configs.StructureRange)
local AreaSize = #preComputedArea
--//Queues
local CaveQueue = Queue.new(999)
local FeatureQueue = Queue.new(999)
local BuildQueue = Queue.new(999)
local ResumeQueue = Queue.new(999)
--//InQueue
local InCaveQueue = {}
local InFeatureQueue = {}
local InBuildQueue = {}
--//Replication
local RequestCarve = {}
local RequestBuildR = {}
local SendCarve = {}
local SendFeatures = {}
local SendBlockData = {}
local RequestMain = {}

local function QuickReplicator(toReplicate,task)
    local new = {}
    for i,children in toReplicate do
        local t = {}
        new[i] = t
        local count = 1
        for key,data in children do
            if data ~= true then
                t[count] = {key,data}
            else
                t[count] = key
            end
            count +=1
        end
        table.clear(children)
    end
    for i,v in new do
        if #v == 0 then continue end 
        Communicator.sendMessageToId(i, task,v)
    end
end
--//Handler
local function BuildHandler(chunk)
    local ChunkObj = Storage.getOrCreate(chunk)
    if not ChunkObj.Built then
        local Shape,Surface,Biome = Overworld.Build(chunk)
        ChunkObj.Shape =Shape
        ChunkObj.Surface =Surface
        ChunkObj.Biome =Biome
        ChunkObj.Built = true
    end
    for _,v in preComputedArea do
        local newLoc = v+chunk
        local SubChunk =  Storage.getOrCreate(newLoc)
        local checked = SubChunk.BChecked
        if checked[chunk] or SubChunk.ABuilt then continue end 
        checked[chunk] = true
        SubChunk.BAmtChecked += 1
        if  SubChunk.BAmtChecked >= AreaSize then
            SubChunk.ABuilt = true
            print("x")
            if SubChunk.Step == 1 then
                Queue.enqueue(ResumeQueue,newLoc)
            end
            continue
        end
        if not SubChunk.FBuilt and  SubChunk.BAmtChecked >= SubChunk.RequiredAmmount then
            SubChunk.FBuilt = true
            if SubChunk.Step == 1 then
                Queue.enqueue(ResumeQueue,newLoc)
            end
        end
    end

end

local function SendBlockDataHandler()
    local new = {}
    for i,children in SendBlockData do
        local t = {}
        new[i] = t
        local count = 1
        for key,data in children do
                t[count] = data
            count +=1
        end
        table.clear(children)
    end
    for i,v in new do
        if #v == 0 then continue end 
        Communicator.sendMessageToId(i, "SendBlockData",v)
    end
end
local function HandleCave(chunk)
   -- local ChunkObject = Storage.getOrCreate(chunk)
    --//CarveChunkHere
    Overworld.Carve(chunk)
    began("CarveFLoop")
    for _,v in preComputedArea do
        local newLoc = v+chunk
        local SubChunk =  Storage.getOrCreate(newLoc)
        local checked = SubChunk.Checked
        if checked[chunk] or SubChunk.FCarve then continue end 
        checked[chunk] = true
        SubChunk.AmtChecked += 1

        if SubChunk.AmtChecked >= SubChunk.RequiredAmmount then
            SubChunk.FCarve = true
            if SubChunk.Step == 2 then
                Queue.enqueue(ResumeQueue,newLoc)
            end
        end
    end
    InCaveQueue[chunk] = false
    close()
end

local function HandleFeature(chunk)
     Overworld.AddFeatures(chunk)
     began("FeatureFloop")
     for _,v in preComputedArea do
         local newLoc = v+chunk
         local SubChunk =  Storage.getOrCreate(newLoc)
         local checked = SubChunk.FChecked
         if checked[chunk] or SubChunk.FFeature then continue end 
         checked[chunk] = true
         SubChunk.FAmtChecked += 1
 
         if SubChunk.FAmtChecked >= SubChunk.RequiredAmmount then
             SubChunk.FFeature = true
             if SubChunk.Step == 4 then
                 Queue.enqueue(ResumeQueue,newLoc)
                
             end
         end
     end
     InFeatureQueue[chunk] = false
     close()
 end
--//Loops
local function BuildLoop()
    
    local times = 0
    began("build")
    for i =1 , MaxBuild do
        if os.clock()-Start_Time >= .0125 then break end 
        local chunk = Queue.dequeue(BuildQueue)
        if not chunk then break end 
        BuildHandler(chunk)
        times+=1
    end
    close()
    return times == 0
end

local function ResumeLoop()
    began("resume")
    for i =1 , MaxResume do
        if os.clock()-Start_Time >= 0.15 then break end 
        local chunk = Queue.dequeue(ResumeQueue)
        if not chunk  then break end 
        began("resumeChunk")
        local ChunkObj = Storage.getOrCreate(chunk)
        coroutine.resume(ChunkObj.MainThread)
        close()
    end
    close()
    return os.clock()-Start_Time <= .007
end

local function CaveLoop()
    began("Carve")
    for i =1 , MaxCarver do
        if os.clock()-Start_Time >.013  then break end 
        local chunk = Queue.dequeue(CaveQueue)
        if not chunk  then break end 
        HandleCave(chunk)
    end
    close()
    return  os.clock()-Start_Time <=.005
end

local function FeatureLoop()
    began("Feature")
    for i =1 , MaxFeature do
        if os.clock()-Start_Time >.013  then break end 
        local chunk = Queue.dequeue(FeatureQueue)
        if not chunk  then break end 
        HandleFeature(chunk)
    end
    close()
    return  os.clock()-Start_Time <=.005
end

local function ReplicateLoop()
    QuickReplicator(RequestBuildR, "RequestBuildR")
    QuickReplicator(RequestMain,"RequestMain")
    QuickReplicator(SendCarve,"SendCarve")
    QuickReplicator(SendFeatures,"SendFeatures")
    SendBlockDataHandler()
    return os.clock()-Start_Time <= .007
end
--//Other
local function RequestCaves(chunk)
    if InCaveQueue[chunk] then return end 
    Queue.enqueue(CaveQueue,chunk)
    InCaveQueue[chunk] = true
end

local function RequestFeature(chunk)
    if InFeatureQueue[chunk] then return end 
    Queue.enqueue(FeatureQueue,chunk)
    InFeatureQueue[chunk] = true
end

local function RequestBuild(chunk)
    if InBuildQueue[chunk] then return end 
    Queue.enqueue(BuildQueue,chunk)
    InBuildQueue[chunk] = true
end

local function MainHandler(chunk)
    local ChunkObj = Storage.getOrCreate(chunk)
    if ChunkObj.InQueue then return end 
    ChunkObj.InQueue = true
    local IsInActor = not ChunkObj.NotInRegion
    Storage.pause(chunk)
    local running = coroutine.running()
    ChunkObj.MainThread = running
    ChunkObj.Step = 1
    if not ChunkObj.ABuilt then
        if IsInActor then
            for Actor,_ in ChunkObj.ActorsToSend do
                if not RequestMain[Actor] then 
                    RequestMain[Actor] = {}
                end
                RequestMain[Actor][chunk] = true
            end
        end
        for _,v in ChunkObj.ChunksToQueue do
            RequestBuild(v)
        end
        coroutine.yield()
        print(ChunkObj.BAmtChecked)
    end
    if IsInActor then
        for Actor,_ in ChunkObj.ActorsToSend do
            if not SendBlockData[Actor] then 
                SendBlockData[Actor] = {}
            end
            SendBlockData[Actor][chunk] = {ChunkObj.Shape,ChunkObj.Surface,ChunkObj.Biome,chunk}
        end
    else
        local Actor = ChunkObj.NotInRegion
        if not SendBlockData[Actor] then 
            SendBlockData[Actor] = {}
        end
        SendBlockData[Actor][chunk] =  {ChunkObj.Shape,ChunkObj.Surface,ChunkObj.Biome,chunk}
    end
    --print("x")
    --print(ChunkObj.BAmtChecked,AreaSize,ACTORID,ChunkObj.ChunksToQueue,ChunkObj.RequiredAmmount)  
    if ChunkObj.BAmtChecked < AreaSize then
        ChunkObj.Step = 1.5
        coroutine.yield()
    end
    ChunkObj.Step = 2
    if not ChunkObj.FCarve then
        if IsInActor then
           
        end
        for _,v in ChunkObj.ChunksToQueue do
            RequestCaves(v)
        end
        coroutine.yield()
    end
    if not IsInActor then
        local Actor = ChunkObj.NotInRegion
        if not SendCarve[Actor] then 
            SendCarve[Actor] = {}
        end
        SendCarve[Actor][chunk] = ChunkObj.Carved or false 
       -- coroutine.yield()
    elseif  IsInActor and not ChunkObj.FCarve then
        coroutine.yield()
    end
        --//WaitForCombine
    do
        return
    end
    if not ChunkObj.FFeature then
        if IsInActor then
            --//Combine
            LocalChunk.finishCarve(ChunkObj)
            --//Replicate
            for Actor,_ in ChunkObj.ActorsToSend do
                if not SendBlockData[Actor] then 
                    SendBlockData[Actor] = {}
                end
                SendBlockData[Actor][chunk] = {ChunkObj.Shape,ChunkObj.Surface,ChunkObj.Biome,chunk}
            end
        elseif not ChunkObj.Shape then 
            ChunkObj.Step = 3
            coroutine.yield()
        end
        -- table.clear(ChunkObj.Checked)
        -- ChunkObj.AmtChecked = 0

        ChunkObj.Step = 4
        for _,v in ChunkObj.ChunksToQueue do
            RequestFeature(v)
        end
        coroutine.yield()
    end
    --print("step4")   
   -- print("step4")    if IsInActor and not next(ChunkObj.ActorsToSend) then  print("step4") end
    ChunkObj.Step = 4
    if not IsInActor then
     
        local Actor = ChunkObj.NotInRegion
        if not SendFeatures[Actor] then 
            SendFeatures[Actor] = {}
        end
        SendFeatures[Actor][chunk] = ChunkObj.FeatureBuffer or false 
       -- coroutine.yield()
    elseif  IsInActor and not ChunkObj.FFeature then
        coroutine.yield()
    end

--     task.synchronize()
--     if IsInActor and not next(ChunkObj.ActorsToSend) then    game.ServerScriptService.Tests.NewGeneration[`{chunk.X},{chunk.Z}`]:Destroy() end
--    game.ServerScriptService.Tests.NewGeneration[`{chunk.X},{chunk.Z}`]:Destroy()
end

local RunnerOrder = {
    BuildLoop,
    ResumeLoop,
    ReplicateLoop,
    CaveLoop,
    ResumeLoop,
    FeatureLoop,
    ResumeLoop,
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

local function getSize(x)
    local c = 0
    for i,v in x do c +=1 end 
    return c
end

function Handler.getInfo()
   --return `\nCave Rep: {getSize(CarverReplication)}\nData Rep: {getSize(ReplicateDataQueue)}\nBuild: {getSize(BuildQueue[3])}\nCave: {getSize(CaveQueue)}\nMain: {getSize(MainQueue)}\nToCombine: {getSize(ToCombineCarveQueue)}\n-------`
end

RunService.Heartbeat:Connect(function()
    iter_ = 0
    Communicator.runParallel(RecursiveRunner)
end)
RunService.Stepped:Connect(function()
    Start_Time = os.clock()
end)

--//Message Binds
Communicator.bindToMessage("Q",function(From,cx,cz)
    local chunk = Vector3.new(cx,0,cz)
    MainHandler(chunk)
end)

Communicator.bindToMessage("RequestMain",function(from,requested)
    for _,chunk in requested do
      task.spawn(MainHandler,chunk)
    end
end)


Communicator.bindToMessage("RequestBuildR",function(from,requested)
    for _,chunk in requested do
      RequestBuild(chunk)
    end
end)


Communicator.bindToMessage("SendCarve",function(from,requested)
    for _,rev in requested do
        local chunk,data = rev[1],rev[2]
        local ChunkObject = Storage.getOrCreate(chunk)
        local Finished = LocalChunk.combineCarve(ChunkObject,from,data)
        
        if not Finished then continue end 
        if ChunkObject.Step == 2 then
            Queue.enqueue(ResumeQueue,chunk)
        end
    end
end)

Communicator.bindToMessage("SendFeatures",function(from,requested)
    for _,rev in requested do
        local chunk,data = rev[1],rev[2]
        local ChunkObject = Storage.getOrCreate(chunk)
        local Finished = LocalChunk.combineFeature(ChunkObject,from,data)
        
        if not Finished then continue end 
        if ChunkObject.Step == 4 then
            Queue.enqueue(ResumeQueue,chunk)
        end
    end
end)

Communicator.bindToMessage("SendBlockData",function(from,blocks)
    for _,v in blocks do
        local block,surface,biomes,chunk = unpack(v)
        local ChunkObject = Storage.getOrCreate(chunk)
        ChunkObject.Shape = block
        ChunkObject.Surface = surface
        ChunkObject.Biome = biomes
        ChunkObject.Built = true
        RequestBuild(chunk)
    end
end)

return {}
