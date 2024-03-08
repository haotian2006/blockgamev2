local Chunk = {}

local Stack = require(game.ReplicatedStorage.Libarys.DataStructures.Stack)

local MaxBuffers = 1000
local Buffers = Stack.new(MaxBuffers)

local UINT32 = 2^32-1
local BUFFERRANGE = 8*256*8-1
local BUFFERSIZE = 4*8*256*8


local function resetBuffer(b)
    buffer.fill(b, 0,255,BUFFERSIZE)
    return b
end

local function getNextBuffer()
    if #Buffers == 0 then
        return resetBuffer(buffer.create(BUFFERSIZE))
    end
    local next = Stack.pop(Buffers)
    return resetBuffer(next)
end

local function returnBuffer(b)
    if #Buffers >= MaxBuffers then
        return
    end
    Stack.push(Buffers, b)
end


local Chunks = {}
local Refrences = {}

local function get(chunk)
    if not Chunks[chunk] then return end 
    Refrences[chunk] +=1
    return Chunks[chunk]
end
Chunk.get = get

local function rawGet(chunk)
    if not Chunks[chunk] then return end 
    return Chunks[chunk]
end
Chunk.rawGet = rawGet

local function getOrCreate(chunk)
    local Data = get(chunk)
    if Data then
        return Data
    end
    local t = {}
    Chunks[chunk] = t
    Refrences[chunk] = 1
    return t
end

Chunk.getOrCreate = getOrCreate

local function increment(chunk)
    Refrences[chunk]+=1
end

Chunk.increment = increment

local function release(chunk)
    if not Chunks[chunk] then return end  
    local r = Refrences[chunk]-1
    if r <= 0 then
        local obj = Chunks[chunk]
        if obj.FeatureBuffer then
            returnBuffer( obj.FeatureBuffer)
        end
        if obj.CarveBuffer then
            returnBuffer( obj.CarveBuffer)
        end
        Refrences[chunk] = nil
        Chunks[chunk] = nil
        return
        --destroy
    end
    Refrences[chunk] = r
end

Chunk.release = release

local function getFeatures(chunk)
    local obj = getOrCreate(chunk)
    if not obj.FeatureBuffer then
        local b = getNextBuffer()
        obj.FeatureBuffer = b
        return b
    end
    return obj.FeatureBuffer
end

Chunk.release = getFeatures

local function getCarved(chunk)
    local obj = getOrCreate(chunk)
    if not obj.CarveBuffer then
        local b = getNextBuffer()
        obj.CarveBuffer = b
        return b
    end
    return obj.CarveBuffer
end

Chunk.getCarved = getCarved

function Chunk.GetAllChunks()
    return Chunks 
end
return Chunk