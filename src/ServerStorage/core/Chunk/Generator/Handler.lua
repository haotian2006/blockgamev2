local Handler = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

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
local Communicator = require(script.Parent.Communicator)
local Storage,LocalChunk = unpack(require(script.Parent.ChunkAndStorage))
local Overworld = require(script.Parent.OverworldActorLayer)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)

local Start_Time = os.clock()
local _,ACTORID = Communicator.getActor()

Overworld.Init()
local preComputedArea = OtherUtils.preComputeSquare(Configs.StructureRange)
local AreaSize = #preComputedArea

--//Queues
local CarveQueue = Queue.new(999)
local FeatureQueue = Queue.new(999)
local BuildQueue = Queue.new(999)
local ResumeQueue = Queue.new(999)
local MainQueue = Queue.new(999)
--//InQueue
local InCarveQueue = {}
local InFeatureQueue = {}
local InBuildQueue = {}
--//Replication
local RequestBuildR = {}
local SendCarve = {}
local SendFeatures = {}
local RequestMain = {}
local MainFailed = {}
local RequestBuildTable = {}
local ToReplicateBuilt = {}
local SendMain = {}

local ChunksRequested = {}
local numOfPlayers = 0

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

local function AddToReplicator(t,id,c,data)
    t[id] = t[id] or {}
    t[id][c] = data or true 
end

local function finishBuild(chunk,Shape,Surface,Biome,frombuilt)
    local obj = Storage.getOrCreateChunkData(chunk)
    obj.Shape = Shape
    obj.Surface = Surface
    obj.Biome = Biome
    if ChunksRequested[chunk] then
        for i,v in ChunksRequested[chunk] do
            AddToReplicator(ToReplicateBuilt, v, chunk, obj)
        end
    end
    began("Biome-loop")
    for _,v in preComputedArea do
        local newLoc = v+chunk
        local SubChunk =  Storage.get(newLoc)
        if not SubChunk then continue end 
        local checked = SubChunk.BuildTable
        if  SubChunk.AllBuild or checked[chunk] then continue end 
        checked[chunk] = true
        SubChunk.BuildAmmount += 1
        if  SubChunk.BuildAmmount < AreaSize then continue end 
        SubChunk.AllBuild = true
        SubChunk.BuildTable = nil --GC
        if SubChunk.Step ~= 1 then continue end 
        Queue.enqueue(ResumeQueue,newLoc)
    end
    close()
end

--//Handler
local function BuildHandler(chunk)
    InBuildQueue[chunk] = nil
    began("building")
    local Shape,Surface,Biome = Overworld.Build(chunk)
    close()
    finishBuild(chunk,Shape,Surface,Biome,true)
end

local function replicateBuiltHandler()
    local new = {}
    local created = {}
    for i,children in ToReplicateBuilt do
        local t = {}
        new[i] = t
        local count = 1
        for key,data in children do
            local d = created[key] or {data.Shape,data.Surface,data.Biome,key}
            created[key] = d
            t[count] = d
            count +=1
        end
        table.clear(children)
    end
    for i,v in new do
        if #v == 0 then continue end 
        Communicator.sendMessageToId(i, "SendBlockData",v)
    end
end

local function replicateToMain()
    local new = {}
    for i,v in SendMain do
        table.insert(new,v)
    end
    if #new ~= 0 then
        table.clear(SendMain)
        Communicator.sendMessageMain(new)
    end
end

local function HandleCarve(chunk)
    Overworld.Carve(chunk)
    InCarveQueue[chunk] = false
    local obj = Storage.getOrCreateChunkData(chunk)
    obj.Carved = true
    began("CarveFLoop")
    for _,v in preComputedArea do
        local newLoc = chunk + v
        local SubChunk =  Storage.get(newLoc)
        if not SubChunk then continue end 
        local checked = SubChunk.CarveTable
        if SubChunk.FCarve or checked[chunk] then continue end 
        checked[chunk] = true
        SubChunk.CarveAmmount += 1
        if SubChunk.CarveAmmount < SubChunk.Required then continue end 
        SubChunk.FCarve = true
        if SubChunk.Step ~= 2 then 
            continue 
        end 
        Queue.enqueue(ResumeQueue,newLoc)
    end
    close()
end

local function HandleFeature(chunk)
     InFeatureQueue[chunk] = false
     Overworld.AddFeatures(chunk)
     local obj = Storage.getOrCreateChunkData(chunk)
     obj.DidFeature = true
     began("FeatureLoop")
     for _,v in preComputedArea do
         local newLoc = chunk + v
         local SubChunk =  Storage.get(newLoc)
         if not SubChunk then continue end 
         local checked = SubChunk.FeatureTable
         if SubChunk.FFeature or checked[chunk] then continue end 
         checked[chunk] = true
         SubChunk.FeatureAmmount += 1
         if SubChunk.FeatureAmmount < SubChunk.Required then continue end 
         SubChunk.FFeature = true
         if SubChunk.Step ~= 3 then continue end 
         Queue.enqueue(ResumeQueue,newLoc)
     end
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
    return os.clock()-Start_Time <= .013
end

local function ResumeLoop()
    began("resume")
    for i =1 , MaxResume do
        if os.clock()-Start_Time >= 0.015 then break end 
        local chunk = Queue.dequeue(ResumeQueue)
        if not chunk  then break end 
        local ChunkObj = Storage.getOrCreate(chunk)
        coroutine.resume(ChunkObj.MainThread)
    end
    close()
    return os.clock()-Start_Time <= .013
end

local function CarveLoop()
    began("Carve")
    for i =1 , MaxCarver do
        if os.clock()-Start_Time >.013  then break end 
        local chunk = Queue.dequeue(CarveQueue)
        if not chunk  then break end 
        HandleCarve(chunk)
    end
    close()
    return  os.clock()-Start_Time <=.013
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
    return  os.clock()-Start_Time <=.013
end

local ReplicateOrder:{[number]:()->()|{}} = {
    {MainFailed,"MainFailed"},
    replicateToMain,
    replicateBuiltHandler,
   -- {RequestBuildR, "RequestBuildR"},
    {RequestMain, "RequestMain"},
    {RequestBuildTable, "RequestBuild"},
    {SendCarve,"SendCarve"},
    {SendFeatures,"SendFeatures"},
}
local function ReplicateLoop()
    for i,v in ReplicateOrder do
        if os.clock()-Start_Time > .010 then break end
        if type(v) == "table" then
            QuickReplicator(v[1], v[2])
        else
            v()
        end
    end
    return os.clock()-Start_Time <= .013
end

--//Other
local function RequestCarve(chunk)
    if InCarveQueue[chunk] then return end 
    Queue.enqueue(CarveQueue,chunk)
    InCarveQueue[chunk] = true
end

local function RequestFeature(chunk)
    if InFeatureQueue[chunk] then return end 
    Queue.enqueue(FeatureQueue,chunk)
    InFeatureQueue[chunk] = true
end

local function RequestBuild(chunk)
    if InBuildQueue[chunk] then return end 
    InBuildQueue[chunk] = true
    local Region = RegionHelper.GetIndexFromChunk(chunk)
    if Region ~= ACTORID then
        AddToReplicator(RequestBuildTable, Region,chunk)
        return
    end
    Queue.enqueue(BuildQueue,chunk)
end

--//Main
local function MainHandler(chunk)
    local ChunkObj = Storage.getOrCreate(chunk)
    if ChunkObj.InQueue then return end 
    ChunkObj.InQueue = true
    local IsInActor = not ChunkObj.NotInRegion
    local internalStep = 0

   -- Storage.pause(chunk) --Pause collection 

    local running = coroutine.running()
    local Failed = task.delay(25+(numOfPlayers-1)*5, function()
        if IsInActor then
            for Actor,_ in ChunkObj.ActorsToSend do
                if not MainFailed[Actor] then 
                    MainFailed[Actor] = {}
                end
                MainFailed[Actor][chunk] = true
            end
            --return back to main thread 
            SendMain[chunk] =  {false,false,false,chunk}
        end
        print(chunk, internalStep,ChunkObj.NotInRegion ,ChunkObj.CarveAmmount,ChunkObj.Required,ChunkObj)
        Storage.removeChunkData(chunk)
        ChunkObj.Failed  = nil
        task.cancel(running)
        task.wait(.5)
        ChunkObj.Step = -1
        ChunkObj.InQueue = false
        Storage.remove(chunk)
    end)
    ChunkObj.Failed = Failed 
    ChunkObj.MainThread = running
    
    local nChunks = ChunkObj.Chunks --Nearby chunks 
    local chunkData = Storage.getChunkData(chunk)

    if IsInActor then --Tells the other actor (if there is) to Init this chunk
        for Actor,_ in ChunkObj.ActorsToSend do
            if not RequestMain[Actor] then 
                RequestMain[Actor] = {}
            end
            RequestMain[Actor][chunk] = true
        end
    end

    for c,data in nChunks do -- loop thru nearby chunks 
        --Storage.increment(c) --tells the system that its being used
        if data.Shape then --If shape was already calculated 
            ChunkObj.BuildAmmount +=1
            ChunkObj.BuildTable[c] = true
        end

        if data.Carved then -- if carving was already calculated 
            ChunkObj.CarveAmmount +=1
            ChunkObj.CarveTable[c] = true
        end
        
        if data.DidFeature then -- if features was already calculated 
            ChunkObj.FeatureAmmount +=1
            ChunkObj.FeatureTable[c] = true
        end      

    end
    internalStep = 1
    ChunkObj.Step = 1 --Building Step
    if ChunkObj.BuildAmmount < AreaSize then --If not finished build 
        for nChunk,_ in nChunks do
            if ChunkObj.BuildTable[nChunk] then continue end --If already checked 
            RequestBuild(nChunk)
        end
        coroutine.yield()
    end
    internalStep = 2
    ChunkObj.Step = 2 --Carving Step
    if ChunkObj.CarveAmmount < ChunkObj.Required then --If not finished carve 
        for _,nChunk in ChunkObj.ToQueue do
            if ChunkObj.CarveTable[nChunk] then continue end --If already checked 
            RequestCarve(nChunk)
        end
        coroutine.yield() --Wait for nearby chunks to carve
    else
        ChunkObj.FCarve = true
    end
    internalStep = 3
    --handle Cave Replication
    if not IsInActor then
        --Send carved data 
        internalStep = 3.1
        local Actor = ChunkObj.NotInRegion
        if not SendCarve[Actor] then 
            SendCarve[Actor] = {}
        end
        internalStep = 3.2
        SendCarve[Actor][chunk] = chunkData.CarveBuffer or false 
    elseif  IsInActor and not ChunkObj.FCarve then
        internalStep = 3.3
        coroutine.yield() --Wait for stuff to be replicated 
    end
    internalStep = 4
  --  print("done")
    if IsInActor then
        LocalChunk.finishCarve(ChunkObj) -- combine carve with shape 
    end
    internalStep = 5
    ChunkObj.Step = 3 --Feature Step
    if ChunkObj.FeatureAmmount < ChunkObj.Required then --If not finished Feature 
        for _,nChunk in ChunkObj.ToQueue do
            if ChunkObj.FeatureTable[nChunk] then continue end --If already checked 
            RequestFeature(nChunk)
        end
        coroutine.yield() --Wait for nearby chunks to add Features
    else
        ChunkObj.FFeature = true
    end
    internalStep = 6
    --handle Features Replication
    if not IsInActor then
        --Send carved data 
        local Actor = ChunkObj.NotInRegion
        if not SendFeatures[Actor] then 
            SendFeatures[Actor] = {}
        end
        SendFeatures[Actor][chunk] = chunkData.FeatureBuffer or false 
    elseif  IsInActor and not ChunkObj.FFeature then
        coroutine.yield() --Wait for stuff to be replicated 
    end
    internalStep = 7
   -- print("done")
    if IsInActor then
        LocalChunk.finishFeatures(ChunkObj) -- combine features with shape 
    end

    --Finish
    -- for c,data in nChunks do 
    --     Storage.decrement(c) --tells the system that its not being used
    -- end
    internalStep = 8
    if IsInActor then
        --return back to main thread 
        SendMain[chunk] =  {chunkData.Shape,chunkData.Surface,chunkData .Biome,chunk}
    end
    ChunkObj.InQueue = false
    Storage.remove(chunk) -- resume collection 
    task.cancel(Failed)
    ChunkObj.Failed  = nil
end
  
local function MainLoop()
    for i =1 , 5 do
        local chunk = Queue.dequeue(MainQueue)
        if not chunk  then break end 
        task.spawn(MainHandler,chunk)
    end
    --return times == 0
end

--//Runner
local RunnerOrder = {
    MainLoop,
    BuildLoop,
    ReplicateLoop,
    CarveLoop,
    ReplicateLoop,
    FeatureLoop,
    ReplicateLoop,
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
    if not Communicator.Ready then return end 
    numOfPlayers = #Players:GetPlayers()
    iter_ = 0
    if not ResumeLoop() then return end 
    Communicator.runParallel(RecursiveRunner)
end)

RunService.Stepped:Connect(function()
    Start_Time = os.clock()
end)

--//Message Binds
Communicator.bindToMessage("Q",function(From,cx,cz)
    local chunk = Vector3.new(cx,0,cz)
    Queue.enqueue(MainQueue,chunk)
    --MainHandler(chunk)
end)

Communicator.bindToMessage("MainFailed",function(from,requested)
    for _,chunk in requested do
        local c = Storage.get(chunk)
        if not c or not c.Failed then continue end 
        coroutine.resume(c.Failed)
     -- task.spawn(MainHandler,chunk)
    end
end)

Communicator.bindToMessage("RequestMain",function(from,requested)
    for _,chunk in requested do
        Queue.enqueue(MainQueue,chunk)
     -- task.spawn(MainHandler,chunk)
    end
end)

Communicator.bindToMessage("RequestBuildR",function(from,requested)
    for _,chunk in requested do
      RequestBuild(chunk)
    end
end)

Communicator.bindToMessage("RequestBuild",function(from,requested)
    for _,chunk in requested do
        local data = Storage.getChunkData(chunk)
        if data and data.Shape then
            AddToReplicator(ToReplicateBuilt, from, chunk, data)
            continue
        end
        ChunksRequested[chunk] =  ChunksRequested[chunk] or {}
        table.insert( ChunksRequested[chunk],from)
    end
end)

Communicator.bindToMessage("SendCarve",function(from,requested)
    for _,rev in requested do
        local chunk,data = rev[1],rev[2]
        local ChunkObject = Storage.get(chunk)
        if not ChunkObject then warn(`{tostring(chunk)} Is Not in Storage?`) end 
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
        local ChunkObject = Storage.get(chunk)
        if not ChunkObject then warn(`{tostring(chunk)} Is Not in Storage?`) end 
        local Finished = LocalChunk.combineFeature(ChunkObject,from,data)
        
        if not Finished then continue end 
        if ChunkObject.Step == 3 then
            Queue.enqueue(ResumeQueue,chunk)
        end
    end
end)

Communicator.bindToMessage("SendBlockData",function(from,blocks)
    for _,v in blocks do
        local block,surface,biomes,chunk = unpack(v)
        InBuildQueue[chunk] = nil
        finishBuild(chunk,block,surface,biomes)
    end
end)

return {}
