local Debirs = require(game.ReplicatedStorage.Libarys.Debris)
local Config = require(script.Parent.Config)
local Chunk = require(script.Parent.LocalChunk)
local ChunkData = Debirs.getOrCreateFolder("Actor Chunk", Config.MaxTimeDebris,Chunk.destroy)
local raw = ChunkData
local Data = {}
Data.created = 0
function Data.get(chunk)
    local a = ChunkData[chunk]
    if not a then return  end 
    a[3] = true
    return a[1]
end

function Data.getOrCreate(chunk)
    local old = Data.get(chunk)
    if not old then
        old = Chunk.new(chunk)
        Data.created+=1
        Debirs.add(ChunkData, chunk, old)
    end
    return old
end

function Data.getFeature(chunk)
    local old = Data.getOrCreate(chunk)
    if not old.FeatureBuffer then
        Chunk.initFeatureBuffer(old)
    end
    return old.FeatureBuffer
end

function Data.getCarved(chunk)
    local old = Data.getOrCreate(chunk)
    if not old.Carved then
        Chunk.initCarveBuffer(old)
    end
    return old.Carved
end



function Data.rawGet(chunk)
    local a = raw[chunk]
    return a and a[1]
end

function Data.rawGetOrCreate(chunk)
    local old = raw[chunk]
    if not old then
        old = Chunk.new(chunk)
        Data.created+=1
        Debirs.add(ChunkData, chunk, old)
    else
        old = old[1]
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