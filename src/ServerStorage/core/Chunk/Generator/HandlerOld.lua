local Handler = {}
local RunService = game:GetService("RunService")
local Configs = require(script.Parent.Config)

local MaxBuild = Configs.MaxBuild
local MaxCarver = Configs.MaxCarver
local MaxCarverReplication = Configs.MaxCarverReplication
local MaxFeatureReplication = Configs.MaxCarverReplication
local MaxMain = Configs.MaxMain
local MaxCarveCombine = Configs.MaxCarveCombine
local MaxFeatureCombine = Configs.MaxCarveCombine
local MaxFeature = Configs.MaxFeature

local Queue = require(game.ReplicatedStorage.Libarys.DataStructures.Queue)
local Generator = game.ServerStorage.Generation.generation
local RegionHelper = require(script.Parent.RegionHelper)
local LocalChunk = require(script.Parent.LocalChunk)
local Communicator = require(script.Parent.Communicator)
local Storage = require(script.Parent.ChunkDataLocal)
local Overworld = require(script.Parent.OverworldActorLayer)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)

local _,aaa = Communicator.getActor()
if aaa == 1 then
    local c = Storage.getOrCreate(Vector3.new())
    local a = setmetatable({c}, {__mode = "v"})
    c = nil
    print("adsa")
    task.spawn(function()
        while task.wait(.2) do
            if not a[1] then
                print("xxx")
                break
            end
        end
    end)
end

local requested = 0

local START_FRAME = os.clock()

Overworld.Init()

local preComputedRadius = OtherUtils.preComputeSquare(Configs.StructureRange)
local preComputeLength = #preComputedRadius

local preComputedLarge = {}
for i,of1 in preComputedRadius do
    for _,of2 in preComputedRadius do
        local offset = of1+of2
        if table.find(preComputedLarge, offset) then continue end 
        table.insert(preComputedLarge,offset)
    end
end

local AwaitingChunksF = {}
local AwaitingChunks = {}

local FeatureReplication = {}
local CarverReplication = {}
local ReplicateDataQueue = {}

local BuildQueue = Queue.new(50)
local CaveQueue = {}
local FeatureQueue = {}
local MainQueue = {}

local ToCombineCarveQueue = {}
local ToCombineFeatureQueue = {}


local Generation = game.ServerStorage.Generation

local Cave = {}


local function FinishCarve(chunk)
    for i,offset in preComputedRadius do
        local newChunk = chunk + offset

        local data = AwaitingChunks[newChunk]
        if not data then continue end 
        if table.find(data,chunk) then continue end 
        table.insert(data,chunk)
    end
end

local function FinishFeatures(chunk)
    --ChunkObj.InQueue = false
    for i,offset in preComputedRadius do
        local newChunk = chunk + offset

        local data = AwaitingChunksF[newChunk]
        if not data then continue end 
        if table.find(data,chunk) then continue end 
        table.insert(data,chunk)
    end
end

local function FinishBuild(chunk,shape,surface,biome)
    local ChunkObj = Storage.getOrCreate(chunk)
    LocalChunk.setData(ChunkObj, shape,surface,biome)
   -- if  ChunkObj.FinishBuild then error(ChunkObj) end 
    ChunkObj.FinishBuild = true
    return ChunkObj
end

local function HandleBuild(chunk)
    FinishBuild(chunk,Overworld.Build(chunk))
    CaveQueue[chunk] = true
end

local function HandleCarveCombine(chunk)
    local ChunkObj = Storage.get(chunk)
    LocalChunk.combineCarve(ChunkObj)
    Communicator.sendMessageMain(chunk,ChunkObj.Shape)
    ChunkObj.InQueue = false
    ReplicateDataQueue[chunk] = ReplicateDataQueue[chunk] or {{}}
    local queue = ReplicateDataQueue[chunk]
    for i,v in ChunkObj.ActorsToSend  do 
        queue[1][i] = true
    end
    queue[2] = ChunkObj
    --FinishCarve(chunk)
end

local function HandleFeatureCombine(chunk)
    local ChunkObj = Storage.get(chunk)
    LocalChunk.combineFeature(ChunkObj)

    ChunkObj.FinishFeatures = true
    -- ReplicateDataQueue[chunk] = ReplicateDataQueue[chunk] or {{}}
    -- local queue = ReplicateDataQueue[chunk]
    -- for i,v in ChunkObj.ActorsToSend  do 
    --     queue[1][i] = true
    -- end
    -- queue[2] = ChunkObj
    FinishFeatures(chunk)
end


local function HandleFeature(chunk)
    local ChunkObj_ = Storage.getOrCreate(chunk)
     local features = Overworld.AddFeatures(chunk)
     FeatureQueue[chunk] = nil
     ChunkObj_.FeatureFlag = true
     debug.profilebegin("loopF")
     for i,offset in preComputedRadius do
         local newChunk = chunk+offset
         local ChunkObj = Storage.getOrCreate(newChunk)
         local pass,r,d1 = LocalChunk.didFeature(ChunkObj,chunk)
         if pass == 2 then
             ToCombineFeatureQueue[newChunk] = true
         end
         if pass ~= 1 then continue end 
         FeatureReplication[newChunk] = {r,d1}
     end
     debug.profileend()
    FeatureQueue[chunk] = nil 
    return features
end

local function HandleCave(chunk,data)
    local ChunkObj_ = Storage.getOrCreate(chunk)
   -- if ChunkObj_.CarvedFlag then return error(tostring(chunk)) end 
    local carved = Overworld.Carve(chunk)
    CaveQueue[chunk] = nil
    ChunkObj_.CarvedFlag = true
    debug.profilebegin("loop")
    for i,offset in preComputedRadius do
        local newChunk = chunk+offset
        local ChunkObj = Storage.getOrCreate(newChunk)
        debug.profilebegin("check")
        local pass,r,d1 = LocalChunk.didCarving(ChunkObj,chunk)
        debug.profileend()
        if pass == 2 then
            ToCombineCarveQueue[newChunk] = true
        end
        if pass ~= 1 then continue end 
        CarverReplication[newChunk] = {r,d1}
    end
    debug.profileend()
    return carved--carved 
end

local function HandleMain(chunk,toSend)
    local Chunks = Storage.getOrCreate(chunk)
    if not Chunks.FinishCarve and Chunks.init then return end 
    Chunks.init = true
   
    if Chunks.FinishCarve then 
    -- print("done")
        return 2
    end
    debug.profilebegin("Large")
    for i,offset in preComputedRadius do
        local newSubChunk = chunk + offset
        local chunkObject = Storage.getOrCreate(newSubChunk)
        if   chunkObject.InQueue  then continue end 
        if chunkObject.FinishCarve and  Chunks.CarvedAlready[newSubChunk] then continue end 
        local ActorId = Communicator.chunkNotInActor(newSubChunk)
        chunkObject.InQueue = true
        requested+=1
        if ActorId then
            toSend[ActorId] = toSend[ActorId] or {}
            toSend[ActorId][newSubChunk] = true
            continue
        end
        Queue.enqueue(BuildQueue,newSubChunk)
    end
    debug.profileend()
    return 1
end

local function HandleMainF(chunk,toSend)
    if  AwaitingChunksF[chunk] and preComputeLength > (#AwaitingChunksF[chunk] or {}) then
        return
    end
    AwaitingChunksF[chunk] = AwaitingChunksF[chunk] or {}
    local Awaiting = AwaitingChunksF[chunk]
    local flag = true
    for i,offset in preComputedRadius do
        local newChunk = offset + chunk
        local foundData = Storage.getOrCreate(newChunk)
        if foundData.FinishFeatures then
            if  table.find(Awaiting, newChunk) then continue end 
            table.insert(Awaiting,newChunk)
            continue
        end
        flag = false
    end

    if flag then 
     print("done")
        return 2
    end
    debug.profilebegin("Large2")
    for i,offset in preComputedLarge do
        local newSubChunk = chunk + offset
        local chunkObject = Storage.rawGetOrCreate(newSubChunk)
        if  chunkObject.FinishCarve or  chunkObject.InQueue  then continue end 
        local ActorId = Communicator.chunkNotInActor(newSubChunk)
        chunkObject.InQueue = true
        requested+=1
        if ActorId then
            toSend[ActorId] = toSend[ActorId] or {}
            toSend[ActorId][newSubChunk] = true
            continue
        end
        Queue.enqueue(BuildQueue,newSubChunk)
    end
    debug.profileend()
    return 1
end

--// LOOPS

local function MainLoop()
    local times = 0
    local removed = {}
    local ToSend = {}
    for v,i in MainQueue do
        if times >= MaxMain or os.clock()-START_FRAME >=0.013 then break end 
        local value = HandleMain(i,ToSend)
        if value ==2 then
            times +=1
            removed[i] = true
        elseif value == 1 then
            times +=1
        end
    end
    for i,v in removed do
        table.remove(MainQueue,table.find(MainQueue, i))
    end
    for i,v in ToSend do
        local newT = {}
        for i,v in v do
            table.insert(newT,i)
        end
        Communicator.sendMessageToId(i,"RequestBuild",newT)
    end

    if os.clock()-START_FRAME <=.004 then
        return true 
    end
    return times == 0
end

local function CarveCombineLoop()
    local times = 0
    for i,v in ToCombineCarveQueue do
        if times >= MaxCarveCombine or os.clock()-START_FRAME>.015 then break end 
        HandleCarveCombine(i)
        ToCombineCarveQueue[i] = nil
        times +=1
    end
    if os.clock()-START_FRAME <=.005 then
        return true
    end
    return times == 0
end

local function FeatureCombineLoop()
    local times = 0
    for i,v in ToCombineFeatureQueue do
        if times >= MaxFeatureCombine or os.clock()-START_FRAME>.015 then break end 
        HandleFeatureCombine(i)
        ToCombineFeatureQueue[i] = nil
        times +=1
    end
    if os.clock()-START_FRAME <=.005 then
        return true
    end
    return times == 0
end

local function CaveLoop()
    local times =0
    for i,v in CaveQueue do
        if times >= MaxCarver then break end 
        if HandleCave(i) then
            times +=1
            if  os.clock()-START_FRAME >.012 then
                break
            end
        end
    end
    return times == 0
end

local function FeatureLoop()
    local times =0
    for i,v in FeatureQueue do
        if times >= MaxFeature then break end 
        if HandleFeature(i) then
            times +=1
            if  os.clock()-START_FRAME >.014 then
                break
            end
        end
    end
    return times == 0
end

local function BuildLoop()
    local times = 0
    for i =1,MaxBuild  do
        if os.clock() - START_FRAME>.0125 then break end 
        local chunk = Queue.dequeue(BuildQueue)
        if not chunk then break end
        times+=1
        HandleBuild(chunk)
    end
    return times == 0 
end

local function ReplicateData()

    local toReplicate = {}
    for chunk,data in ReplicateDataQueue do
        ReplicateDataQueue[chunk] = nil
        local chunkD = data[2]
        local toSend = {chunk.X,chunk.Z,chunkD.Shape,chunkD.Surface,chunkD.Biomes}
        for Id,_ in data[1] do
            toReplicate[Id] =  toReplicate[Id] or {}
            table.insert(toReplicate[Id],toSend)
        end
    end
    local count = 0
    for ID,data in toReplicate do
        count +=1
        Communicator.sendMessageToId(ID,"SendData",data)
    end
    return count == 0
end

local function ReplicateCarver()
    local toReplicate = {}
    local times = 0
    for chunk,data in CarverReplication do
        if times >= MaxCarverReplication or os.clock()-START_FRAME >=.007 then break end 
        CarverReplication[chunk] = nil
        local toSend = {chunk.X,chunk.Z,data[2]}
        local Id = data[1]
        toReplicate[Id] =  toReplicate[Id] or {}
        table.insert(toReplicate[Id],toSend)
        times +=1
    end
    local count = 0
    for ID,data in toReplicate do
        count +=1
        Communicator.sendMessageToId(ID,"Carver",data)
    end
    return count == 0
end

local function ReplicateFeatures()
    local toReplicate = {}
    local times = 0
    for chunk,data in FeatureReplication do
        if times >= MaxFeatureReplication or os.clock()-START_FRAME >=.007 then break end 
        FeatureReplication[chunk] = nil
        local toSend = {chunk.X,chunk.Z,data[2]}
        local Id = data[1]
        toReplicate[Id] =  toReplicate[Id] or {}
        table.insert(toReplicate[Id],toSend)
        times +=1
    end
    local count = 0
    for ID,data in toReplicate do
        count +=1
        Communicator.sendMessageToId(ID,"FeatureR",data)
    end
    return count == 0
end


local function ReplicateLoop()
    local build = ReplicateData()
    local carver = ReplicateCarver()
    if os.clock()-START_FRAME <=.005 then
        return true 
    end
    return build and carver
end

local Order = {
    BuildLoop,
    BuildLoop,
    BuildLoop,
    BuildLoop,
    CaveLoop,
    CaveLoop,
    CarveCombineLoop,
    ReplicateLoop,
    MainLoop,
}

local iter_ = 0
local function Loop(current)
    current = current or 0
    current+=1
    if current > #Order+2 then
        return
    end
    iter_+=1
    if not Order[iter_] then
        iter_ = 0
        return Loop(current)
    end
    if Order[iter_](iter_) then
        return Loop(current)
    end
    return 
end
--[[
local CarverReplication = {}
local ReplicateDataQueue = {}

local BuildQueue = Queue.new(50)
local CaveQueue = {}
local FeatureQueue = {}
local MainQueue = {}

local ToCombineCarveQueue = {}
]]
local function getSize(x)
    local c = 0
    for i,v in x do c +=1 end 
    return c
end
function Handler.getInfo()
    return `\nCave Rep: {getSize(CarverReplication)}\nData Rep: {getSize(ReplicateDataQueue)}\nBuild: {getSize(BuildQueue[3])}\nCave: {getSize(CaveQueue)}\nMain: {getSize(MainQueue)}\nToCombine: {getSize(ToCombineCarveQueue)}\n-------`
end

RunService.Stepped:Connect(function()
    START_FRAME = os.clock()
    Communicator.runParallel(Loop)
end)

Communicator.bindToMessage("UpdateShape",function(from,cx,cz,shape)
    local chunk = Vector3.new(cx,0,cz)
    local cdata = Storage.getOrCreate(chunk)
    cdata.Shape = shape
    cdata.FinishCarve = true
    cdata.InQueue = false
    FinishCarve(chunk)
end)

Communicator.bindToMessage("Carver",function(from,Data)
    for i,v in Data do
        local cx,cz,carver = unpack(v)
        local chunk = Vector3.new(cx,0,cz)
        local cdata = Storage.getOrCreate(chunk)
        LocalChunk.combineCarverfromActor(cdata, from, carver)
        if LocalChunk.checkCaveDone(cdata) == 2 then
            ToCombineCarveQueue[chunk] = true
        end
    end
end)

Communicator.bindToMessage("FeatureR",function(from,Data)
    for i,v in Data do
        local cx,cz,carver = unpack(v)
        local chunk = Vector3.new(cx,0,cz)
        local cdata = Storage.getOrCreate(chunk)
        LocalChunk.combineFeaturefromActor(cdata, from, carver)
        if LocalChunk.checkFeatureDone(cdata) == 2 then
            ToCombineFeatureQueue[chunk] = true
        end
    end
end)


Communicator.bindToMessage("Q",function(From,cx,cz)
    local chunk = Vector3.new(cx,0,cz)
    table.insert(MainQueue,chunk)
end)

Communicator.bindToMessage("SendData",function(From,Data)
    for i,chunkData in Data do
        local cx,cz,Colored,surface,Biomes = unpack(chunkData)
        local chunk = Vector3.new(cx,0,cz)
        local obj = FinishBuild(chunk,Colored,surface,Biomes)
        obj.InQueue = true
        FinishCarve(chunk)
    end
end)

Communicator.bindToMessage("RequestBuild",function(From,chunks)

    for i,chunk in chunks do 
        local data = Storage.getOrCreate(chunk)

        if data.FinishCarve and false then
            if ReplicateDataQueue[chunk] then
                ReplicateDataQueue[chunk][1][From] = true
                ReplicateDataQueue[chunk][2] = data
            else
                ReplicateDataQueue[chunk] = {{[From] = true},data}
            end
            continue
        end
        
        if data.InQueue then continue end 
        data.InQueue = true
        Queue.enqueue(BuildQueue,chunk)
    end
end)

return Handler