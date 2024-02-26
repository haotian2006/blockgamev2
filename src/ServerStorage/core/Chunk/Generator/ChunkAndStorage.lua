local Config = require(script.Parent.Config)
local Communicator = require(script.Parent.Communicator)
local RegionHelper = require(script.Parent.RegionHelper)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)

local Precompute = OtherUtils.preComputeSquare(Config.StructureRange)
local preComputeLength = #Precompute

local Stack = require(game.ReplicatedStorage.Libarys.DataStructures.Stack)
local indexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
indexUtils.preComputeAll()

local MaxTime =  Config.MaxTimeDebris
local Storage = {}
local Chunk = {}
local DestroyStack = Stack.new(10000)

local carvedBufferSize =  2*8*256*8
local BufferRange = 8*256*8-1
local FeatureBufferSize = carvedBufferSize*2

local UINT16 = 65535
local UINT32 = 2^32-1
local DESTROY_INTERVAL = 5 -- prevents roblox's GC from casuing too much lag

game:GetService("RunService").Heartbeat:Connect(function()
    for i = 1,DESTROY_INTERVAL do
        local item = Stack.pop(DestroyStack) -- Stack will act as a refrence holder preventing the object from being gc until it is popped 
        if not item then break end 
        table.clear(item)
    end
end)



local function CopyBuffer(b)
    local len = buffer.len(b)
    local newb = buffer.create(len)
    buffer.copy(newb, 0, b, 0, len)
    return newb
end


local ChunkData = setmetatable({}, {__mode = 'v'}) 
local Chunks = {}
local InUse = {}

--//Storage
function Storage.getInfo()
    local chunkAmt = 0
    local ChunkDataAmt = 0
    for _ in Chunks do
        chunkAmt+=1
    end
    for _ in ChunkData do
        ChunkDataAmt+=1
    end
    return chunkAmt,ChunkDataAmt,#DestroyStack
end

local function OnDestroy(chunk)
    local obj = Chunks[chunk]
    if not obj then return end 
    Chunks[chunk] = nil
    Stack.push(DestroyStack, obj)
end

function Storage.add(name,value)
    Chunks[name] = value
end

function Storage.increment(chunk)
    local current = InUse[chunk] or 0
    InUse[chunk] = current+1
end

function Storage.decrement(chunk)
    local current = InUse[chunk] or 0
    InUse[chunk] = current-1
    if current<=0 then
        InUse[chunk] = nil
        Storage.remove(chunk)
    end
end

function Storage.getChunkData(chunk)
    return ChunkData[chunk]
end

function Storage.removeChunkData(chunk)
     ChunkData[chunk] = nil
end


function Storage.getOrCreateChunkData(chunk)
    local obj = ChunkData[chunk]
    if obj then return obj end 
    obj =  {}
    ChunkData[chunk] = obj
    return obj
end

function Storage.pause(name)
    local object = Chunks[name]
    if not object then return end 
    local t = object[1]
    if t then
       -- task.cancel(t)
    end
    object[1] = nil
end

function Storage.resume(name)
    local object = Chunks[name]
    if not object then return end 
    object[1] = object[1] or task.delay(MaxTime,OnDestroy,name)
    object[2] = true
end

function Storage.remove(name)
    local object = Chunks[name]
    if not object then return end 
    local t = object[1]
    if t then
        task.cancel(t)
    end
    object[2] = false
    OnDestroy(name)
end

function Storage.get(name)
    local chunkobj = Chunks[name]
    if not chunkobj then return  end 
    chunkobj[2] = true
    return chunkobj
end


local sharedBuffer = buffer.create( 4*8*256*8)
buffer.fill(sharedBuffer, 0,255,4*8*256*8)

function Storage.getFeatureBuffer(chunk)
    local chunkobj = Storage.getOrCreateChunkData(chunk)
    if not chunkobj.FeatureBuffer then
        local fBuffer = buffer.create(FeatureBufferSize)
        buffer.fill(fBuffer, 0,255,FeatureBufferSize)
        chunkobj.FeatureBuffer = fBuffer
    end
    return chunkobj.FeatureBuffer
end

function Storage.getCarvedBuffer(chunk)
    local chunkobj = Storage.getOrCreateChunkData(chunk)
    if not chunkobj.CarveBuffer then
        local fBuffer = buffer.create(FeatureBufferSize)
        buffer.fill(fBuffer, 0,255,FeatureBufferSize)
        chunkobj.CarveBuffer = fBuffer
    end
    return chunkobj.CarveBuffer
end

function Storage.getOrCreate(name)
    local a = Chunks[name] 
    if not a then 
        local chunk = Chunk.new(name)
        Storage.add(name, chunk )
        return chunk
    end 
    a[2] = true
    return a
end


--//Chunk 
function Chunk.new(chunk)
    local _,ActorID = Communicator.getActor()
    local ChunkRegion = RegionHelper.GetIndexFromChunk(chunk)
    local isSame = ChunkRegion == ActorID
    local count = if isSame then preComputeLength else 0
    local nearby = isSame and {}
    local ToQueue = {}
    local allNearby = {}
    debug.profilebegin("precompute")
    for i,offset in Precompute do
        local newChunk = chunk + offset
        allNearby[newChunk] = Storage.getOrCreateChunkData(newChunk) 
        local newID = RegionHelper.GetIndexFromChunk(newChunk)
        local equals = newID == ActorID 
        if isSame and not equals  then 
            nearby[newID] =  nearby[newID] or {}
            table.insert(nearby[newID],newChunk)
            continue 
        elseif equals  then
            table.insert(ToQueue,newChunk)
        end 
        if isSame or not equals then continue end 
        count += 1
    end
    debug.profileend()
    local self = {
        Loc = chunk,
        Chunks = allNearby,
        NotInRegion =if isSame then nil else ChunkRegion,
        ActorsToSend = nearby,
        ToQueue = ToQueue,
        MainThread = nil,
        Required = count,

        BuildAmmount = 0;
        BuildTable = {},

        CarveAmmount = 0,
        CarveTable = {},
        FeatureAmmount = 0,
        FeatureTable = {}
    }
    return self 
end 

local function AttempCombineCave(self,data)
    if typeof(data) ~= "buffer" then return end 
    local cData = Storage.getChunkData(self.Loc)
    if not cData.CarveBuffer then 
        cData.CarveBuffer = data
        return 
    end 
    local carved = cData.CarveBuffer
    for i =0,BufferRange do
        i*=4
        local value = buffer.readu32(data, i)
        if value == UINT32 then continue end 
        buffer.writeu32(carved, i, value)
    end
end


function Chunk.combineCarve(self,from,data)
    if self.FCarve then return end 
    local Carved = self.CarveTable or {}
    for i,chunk in self.ActorsToSend[from] do
        if Carved[chunk] then continue end 
        Carved[chunk] = true
        self.CarveAmmount +=1
    end
    AttempCombineCave(self,data)
    if self.CarveAmmount >= self.Required then
        self.FCarve = true
        return true
    end
    return false 
end

local function AttempCombineFeature(self,data)
    if typeof(data) ~= "buffer" then return end 
    local cData = Storage.getChunkData(self.Loc)
    if not cData.FeatureBuffer then 
        cData.FeatureBuffer = data
        return 
    end 
    local carved = cData.FeatureBuffer
    for i =0,BufferRange do
        i*=4
        local value = buffer.readu32(data, i)
        if value == UINT32 then continue end 
        buffer.writeu32(carved, i, value)
    end
end


function Chunk.combineFeature(self,from,data)
    if self.FFeature then return end 
    local done = self.FeatureTable or {}
    for i,chunk in self.ActorsToSend[from] do
        if done[chunk] then continue end 
        done[chunk] = true
        self.FeatureAmmount +=1
    end
    AttempCombineFeature(self,data)
    if self.FeatureAmmount >= self.Required then
        self.FFeature = true
        return true
    end
    return false 
end

function Chunk.getData(self)
    return self.Chunks[self.Loc]
end


function Chunk.finishCarve(self)
    local cData = Storage.getChunkData(self.Loc)
    if not cData.CarveBuffer then return end 
    local carved = cData.CarveBuffer
    local Shape = cData.Shape
   -- cData.CarveBuffer = nil --removes from mem
    for i =0,BufferRange do
        i*=4
        local value = buffer.readu32(carved, i)
        if value == UINT32 then continue end 
        buffer.writeu32(Shape, i, value)
    end
end

function Chunk.finishFeatures(self)
    local cData = Storage.getChunkData(self.Loc)
    if not cData.FeatureBuffer then return end 
    local carved = cData.FeatureBuffer
    local Shape = cData.Shape
  --  cData.FeatureBuffer = nil --removes from mem
    for i =0,BufferRange do
        i*=4
        local value = buffer.readu32(carved, i)
        if value == UINT32 then continue end 
        buffer.writeu32(Shape, i, value)
    end
end

--//Chunk Data
return {Storage,Chunk}