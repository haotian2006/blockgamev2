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
local RequestBuildR = {}
local SendCarve = {}
local SendFeatures = {}
local RequestMain = {}
local ToReplicateBuilt = {}
local SendMain = {}

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
    InBuildQueue[chunk] = nil
    if not ChunkObj.Built then
        debug.profilebegin("building")
        local Shape,Surface,Biome = Overworld.Build(chunk)
        ChunkObj.Shape =Shape
        ChunkObj.Surface =Surface
        ChunkObj.Biome =Biome
        ChunkObj.Built = true 
        if next(ChunkObj.ActorsToSend) then
            --If it has nearby then send 
            ToReplicateBuilt[chunk] = true
        end
        debug.profileend()
    end
    began("Bloop")
    for _,newLoc in ChunkObj.NearbyChunks do
        local SubChunk =  Storage.getOrCreate(newLoc)
        local checked = SubChunk.BChecked
        if checked[chunk] or SubChunk.ABuilt then continue end 
        checked[chunk] = true
        SubChunk.BAmtChecked += 1
        if  SubChunk.BAmtChecked < AreaSize then continue end 
        SubChunk.ABuilt = true
        if SubChunk.Step ~= 1 then continue end 
        Queue.enqueue(ResumeQueue,newLoc)
    end
    close()
end

local function replicateBuiltHandler()
    local times = 0
    local new = {}
    for chunk,_ in ToReplicateBuilt do
        if times >= 5 then break end 
        local ChunkObj = Storage.getOrCreate(chunk)
        local data =  {ChunkObj.Shape,ChunkObj.Surface,ChunkObj.Biome,chunk}
        for nearby,_ in ChunkObj.ActorsToSend do
            new[nearby] = new[nearby] or {}
            table.insert( new[nearby],data)
        end
        ToReplicateBuilt[chunk] = nil
        times+=1
    end
    for i,v in new do
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

local function HandleCave(chunk)
    local ChunkObj = Storage.getOrCreate(chunk)
   -- local ChunkObject = Storage.getOrCreate(chunk)
    --//CarveChunkHere
    InCaveQueue[chunk] = false
    Overworld.Carve(chunk)
    began("CarveFLoop")
    for _,newLoc in ChunkObj.NearbyChunks do
        local SubChunk =  Storage.getOrCreate(newLoc)
        local checked = SubChunk.Checked
        if checked[chunk] or SubChunk.FCarve then continue end 
        checked[chunk] = true
        SubChunk.AmtChecked += 1
        if SubChunk.AmtChecked < SubChunk.RequiredAmmount then continue end 
        SubChunk.FCarve = true
        if SubChunk.Step ~= 2 then continue end 
        Queue.enqueue(ResumeQueue,newLoc)
    end
    close()
end

local function HandleFeature(chunk)
    local ChunkObj = Storage.getOrCreate(chunk)
     InFeatureQueue[chunk] = false
     Overworld.AddFeatures(chunk)
     began("FeatureFloop")
     for _,newLoc in ChunkObj.NearbyChunks do
      --  local newLoc = v+chunk
        local SubChunk =  Storage.getOrCreate(newLoc)
        local checked = SubChunk.FChecked
        if checked[chunk] or SubChunk.FFeature then continue end 
        checked[chunk] = true
        SubChunk.FAmtChecked += 1
        if SubChunk.FAmtChecked < SubChunk.RequiredAmmount then continue end 
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

local ReplicateOrder:{[number]:()->()|{}} = {
    replicateToMain,
    replicateBuiltHandler,
    {RequestBuildR, "RequestBuildR"},
    {RequestMain, "RequestMain"},
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
    Storage.pause(chunk) --Don't GC
    local running = coroutine.running()
    ChunkObj.MainThread = running
    --This step will tell the other Nearby Workers to Began their Handler
    for i,sub in ChunkObj.NearbyChunks do
        local subObject = Storage.getOrCreate(sub)
        subObject[3] +=1
    end
    if IsInActor then
        for Actor,_ in ChunkObj.ActorsToSend do
            if not RequestMain[Actor] then 
                RequestMain[Actor] = {}
            end
            RequestMain[Actor][chunk] = true
        end
    end
    ChunkObj.Step = 1
    --Began The Build
    if not ChunkObj.ABuilt then --If not All Built
        for _,v in ChunkObj.ChunksToQueue do
            RequestBuild(v)
        end
        coroutine.yield() -- Yield until AllReplicated 
    end
    -- All nearbychunk data is recieved
    --Carve
    ChunkObj.Step = 2
    if not ChunkObj.FCarve then
        for _,v in ChunkObj.ChunksToQueue do
            RequestCaves(v)
        end
        coroutine.yield()
    end
      --ReplicateCaves
    if not IsInActor then
        local Actor = ChunkObj.NotInRegion
        if not SendCarve[Actor] then 
            SendCarve[Actor] = {}
        end
        SendCarve[Actor][chunk] = ChunkObj.Carved or false 
    elseif  IsInActor and not ChunkObj.FCarve then
        coroutine.yield()
    end
    --AddFeatures
    if IsInActor then
        LocalChunk.finishCarve(ChunkObj)
    end
    ChunkObj.Step = 3
    if not ChunkObj.FFeature then
        for _,v in ChunkObj.ChunksToQueue do
            RequestFeature(v)
        end
        coroutine.yield()
    end
      --ReplicateFeatures
    if not IsInActor then
        local Actor = ChunkObj.NotInRegion
        if not SendFeatures[Actor] then 
            SendFeatures[Actor] = {}
        end
        SendFeatures[Actor][chunk] = ChunkObj.FeatureBuffer or false 
    elseif  IsInActor and not ChunkObj.FFeature then
        coroutine.yield()
    end
    for i,v in ChunkObj.NearbyChunks do
        local sub = v+chunk
        local subObject = Storage.getOrCreate(sub)
        subObject[3] -=1
    end
    Storage.resume(chunk) -- resume

    --Finish
    if IsInActor then
        LocalChunk.finishFeature(ChunkObj)
        SendMain[chunk] =  {ChunkObj.Shape,ChunkObj.Surface,ChunkObj.Biome,chunk}
    end
    --print("step4")    if IsInActor and not next(ChunkObj.ActorsToSend) then  print("step4") end
    
end
  

local RunnerOrder = {
    BuildLoop,
    ReplicateLoop,
    CaveLoop,
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
        if ChunkObject.Step == 3 then
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
