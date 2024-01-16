local Handler = {}
local RunService = game:GetService("RunService")
local Configs = require(script.Parent.Config)

local MaxBuild = Configs.MaxBuild
local MaxCarver = Configs.MaxCarver
local MaxMain = Configs.MaxMain
local MaxCarveCombine = Configs.MaxCarveCombine
local MaxFeature = Configs.MaxFeature

local Queue = require(game.ReplicatedStorage.Libarys.DataStructures.Queue)
local Generator = game.ServerStorage.Generation.generation
local RegionHelper = require(script.Parent.RegionHelper)
local LocalChunk = require(script.Parent.LocalChunk)
local Communicator = require(script.Parent.Communicator)
local Storage = require(script.Parent.ChunkDataLocal)
local Overworld = require(script.Parent.OverworldActorLayer)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)

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

local AwaitingForBuild = {}
local AwaitingChunks = {}

local CarverReplication = {}

local ReplicateBuildQueue = {}
local BuildQueue = Queue.new(50)
local CaveQueue = {}
local FeatureQueue = {}
local MainQueue = {}

local ToCombineCarveQueue = {}

local InBuildQueue = {}

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

local function FinishBuild(chunk,cdata)
    local ChunkObj = Storage.get(chunk)
    LocalChunk.setData(ChunkObj, cdata[1], cdata[2], cdata[3])
    InBuildQueue[chunk] = nil
    ChunkObj.FinishBuild = true
end

local function HandleBuild(chunk)
    local data = {Overworld.Build(chunk)}
    --ReplicateBuildQueue[chunk] = data
    FinishBuild(chunk,data)
    CaveQueue[chunk] = true
end

local function HandleCarveCombine(chunk)
    local ChunkObj = Storage.get(chunk)
    LocalChunk.combineCarve(ChunkObj)
    ChunkObj.FinishCarve = true
    FinishCarve(chunk)
end

local function HandleFeature(chunk)
    
end

local function HandlerCave(chunk,data)
    local carved = Overworld.Carve(chunk)
    CaveQueue[chunk] = nil
    debug.profilebegin("loop")
    for i,offset in preComputedRadius do
        local newChunk = chunk+offset
        local ChunkObj = Storage.rawGetOrCreate(newChunk)
        local pass,r,d1,d2 = LocalChunk.didCarving(ChunkObj,chunk)
        if pass == 2 then
            ToCombineCarveQueue[newChunk] = true
        end
        if pass ~= 1 then continue end 
        CarverReplication[newChunk] = {r,d1,d2}
    end
    debug.profileend()
    return carved 
end

local function HandleMain(chunk,toSend)
    if  AwaitingChunks[chunk] and preComputeLength > (#AwaitingChunks[chunk] or {}) then
        return
    end
    AwaitingChunks[chunk] = AwaitingChunks[chunk] or {}
    local Awaiting = AwaitingChunks[chunk]
    local flag = true
    for i,offset in preComputedRadius do
        local newChunk = offset + chunk
        local foundData = Storage.get(newChunk)
        if foundData.FinishCarve then
            if  table.find(Awaiting, newChunk) then continue end 
            table.insert(Awaiting,newChunk)
            continue
        end
        flag = false
    end

    if flag then 
        print("done Main")
        return 2
    end
    debug.profilebegin("Large")
    for i,offset in preComputedLarge do
        local newSubChunk = chunk + offset
    
        if  InBuildQueue[newSubChunk]  then continue end 
        local ActorId = Communicator.chunkNotInActor(newSubChunk)
        InBuildQueue[newSubChunk] = true
        if ActorId then
            toSend[ActorId] = toSend[ActorId] or {}
            if  table.find(toSend[ActorId],newSubChunk) then continue end 
            table.insert(toSend[ActorId],newSubChunk)
            continue
        end
        Queue.enqueue(BuildQueue,newSubChunk)
    end
    debug.profileend()
    return 1
end

local function MainLoop()
    local times = 0
    local removed = {}
    local ToSend = {}
    for v,i in MainQueue do
        if times >= MaxMain then break end 
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
        Communicator.sendMessageToId(i,"RB",v)
    end
    return times == 0
end

local function CarveCombineLoop()
    local times = 0
    for i,v in ToCombineCarveQueue do
        if times >= MaxCarveCombine then break end 
        HandleCarveCombine(i)
        ToCombineCarveQueue[i] = nil
        times +=1
    end
    return times == 0
end

local function CaveLoop()
    local times =0
    local start = os.clock()
    for i,v in CaveQueue do
        if times >= MaxCarver then break end 
        if HandlerCave(i) then
            times +=1
            if  os.clock()-start >.014 then
                break
            end
        end
    end
    return times == 0
end

local function FeatureLoop()
    local times =0
    local start = os.clock()
    for i,v in FeatureQueue do
        if times >= MaxFeature then break end 
        if HandleFeature(i) then
            times +=1
            if  os.clock()-start >.014 then
                break
            end
        end
    end
    return times == 0
end

local function BuildLoop()
    local times = 0
    for i =1,MaxBuild  do
        local chunk = Queue.dequeue(BuildQueue)
        if not chunk then break end
        times+=1
        HandleBuild(chunk)
    end
    return times == 0 
end

local function ReplicateBuild()
    local toReplicate = {}
    for chunk,data in ReplicateBuildQueue do
        ReplicateBuildQueue[chunk] = nil
        local Requested = AwaitingForBuild[chunk]
        if not Requested then continue end 
        local toSend = {chunk.X,chunk.Z,unpack(data)}
        for _,Id in Requested do
            toReplicate[Id] =  toReplicate[Id] or {}
            table.insert(toReplicate[Id],toSend)
        end
    end
    local count = 0
    for ID,data in toReplicate do
        count +=1
        Communicator.sendMessageToId(ID,"SB",data)
    end
    return count == 0
end

local function ReplicateCarver()
    local toReplicate = {}
    for chunk,data in CarverReplication do
        CarverReplication[chunk] = nil
        local toSend = {chunk.X,chunk.Z,data[2],data[3]}
        local Id = data[1]
        toReplicate[Id] =  toReplicate[Id] or {}
        table.insert(toReplicate[Id],toSend)
    end
    local count = 0
    for ID,data in toReplicate do
        count +=1
        Communicator.sendMessageToId(ID,"Carver",data)
    end
    return count == 0
end

local function ReplicateLoop()
    local build = ReplicateBuild()
    local carver = ReplicateCarver()
    return build and carver
end

local Order = {
    BuildLoop,
    BuildLoop,
    BuildLoop,
    BuildLoop,
    CaveLoop,
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

RunService.Stepped:Connect(function()
    Communicator.runParallel(Loop)
end)

Communicator.bindToMessage("UpdateShape",function(from,cx,cz,shape)
    local chunk = Vector3.new(cx,0,cz)
    local cdata = Storage.get(chunk)
    cdata.Shape = shape
    cdata.FinishCarve = true
    FinishCarve(chunk)
end)

Communicator.bindToMessage("Carver",function(from,Data)
    for i,v in Data do
        local cx,cz,carver,amt = unpack(v)
        local chunk = Vector3.new(cx,0,cz)
        local cdata = Storage.get(chunk)
        cdata.AmmountCarved += amt
        if LocalChunk.checkCaveDone(cdata,carver) == 2 then
            ToCombineCarveQueue[chunk] = true
        end
    end
end)

Communicator.bindToMessage("Q",function(From,cx,cz)
    local chunk = Vector3.new(cx,0,cz)
    table.insert(MainQueue,chunk)
end)

Communicator.bindToMessage("SB",function(From,Data)
    for i,chunkData in Data do
        local cx,cz,Colored,surface,Biomes = unpack(chunkData)
        local chunk = Vector3.new(cx,0,cz)
        InBuildQueue[chunk]  = false
        FinishBuild(chunk,{Colored,surface,Biomes})
    end
end)

Communicator.bindToMessage("RB",function(From,chunks)
  for i,chunk in chunks do 
    local data = Storage.get(chunk)
    if data.FinishBuild then
        ReplicateBuildQueue[chunk] = {data.Shape,data.Surface,data.Biome}
        return
    end
    Queue.enqueue(BuildQueue,chunk)
    InBuildQueue[chunk] = true
    if not AwaitingForBuild[chunk] then
        AwaitingForBuild[chunk] = {}
    end
    table.insert(AwaitingForBuild[chunk],From)
  end
end)

return Handler