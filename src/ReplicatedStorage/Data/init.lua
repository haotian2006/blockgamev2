local Data = {}
local EntityHolder = require(game.ReplicatedStorage.EntityHandler.EntityHolder)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils) 
local BlockUtils = require(game.ReplicatedStorage.Utils.BlockUtils)
local Chunk = require(game.ReplicatedStorage.Chunk)

debug.setmemorycategory("CUBICAL STORAGE")
local Chunks = {}
local Other = {}
local PlayerEntity = nil 
local Simulated = {}

function Data.getSimulated()
    return Simulated
end

function Data.addEntity(Entity)
    EntityHolder.addEntity(Entity)
end

function Data.removeEntity(guid)
    EntityHolder.removeEntity(guid)
end

function Data.getEntity(Guid)
    return EntityHolder.getEntity(Guid)
end

function Data.getEntityFromPlayer(Player)
    return EntityHolder.getEntity(tostring(Player.UserId))
end

function Data.getAllEntities()
    return EntityHolder.getAllEntities()
end
function Data.insertChunk(x,y,chunk)
    Chunks[Vector3.new(x,0,y)] = chunk
end

function Data.getChunk(x,y)
    return Chunks[Vector3.new(x,0,y)]
end 

function Data.deloadChunk(x,z)
    Chunks[Vector3.new(x,0,z)] = nil
end

function Data.getChunkFrom(vector)
    return Chunks[vector]
end 

function Data.getAllChunks()
    return Chunks
end 
function Data.getChunkOrCreate(x,y)
    local c = Chunks[Vector3.new(x,0,y)] 
    if not c then
        c = Chunk.new(x, y)
        Chunks[Vector3.new(x,0,y)]  = c
    end
    return c
end 

function Data.getBiome(x,y,z)
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return  end
    return Chunk.getBiomeAt(chunk, lx, lz)
end

function Data.getBlock(x,y,z)
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return BlockUtils.CONST_NULL end
    return Chunk.getBlockAt(chunk, lx, ly, lz)
end 

function Data.insertBlock(x,y,z,block)
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    Chunk.insertBlockAt(chunk, lx,ly,lz, block)
    return true
end
function Data.set(key,value)
    Other[key] = value
end
function Data.get(key)
    return Other[key]
end 

function Data.getPlayerEntity()
    return PlayerEntity
end
function Data.setPlayerEntity(e)
    PlayerEntity = e
end
return table.freeze(Data)