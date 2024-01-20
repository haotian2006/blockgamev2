local Debirs = require(game.ReplicatedStorage.Libarys.Debris)
local Config = require(script.Parent.Config)
local Chunk = require(script.Parent.LocalChunk)
local ChunkData = Debirs.createFolder("Actor Chunk", Config.MaxTimeDebris,Chunk.destroy)
local raw = ChunkData[1]
local Data = {}
Data.created = 0
function Data.get(chunk)
   return Debirs.get(ChunkData,chunk)
end

function Data.getOrCreate(chunk)
    local old = Debirs.get(ChunkData,chunk)
    if not old then
        old = Chunk.new(chunk)
        Data.created+=1
        Data.add(chunk, old)
    end
    return old
end

function Data.rawGet(chunk)
    return raw[chunk]
end

function Data.rawGetOrCreate(chunk)
    local old = raw[chunk]
    if not old then
        old = Chunk.new(chunk)
        Data.created+=1
        Data.add(chunk, old)
    end
    return old
end

function Data.add(chunk,data)
    return Debirs.add(ChunkData, chunk, data)
end

function Data.remove(chunk)
    ChunkData:remove(chunk)
end

function Data.getDebirs()
    return ChunkData
end

return Data