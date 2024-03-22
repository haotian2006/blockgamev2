local Chunk = require(game.ReplicatedStorage.Chunk)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local Data = require(game.ReplicatedStorage.Data)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local RenderHandler = require(script.Parent.core.chunk.Rendering.Handler)
local BlockReplication = require(script.Parent.core.Replication.Block)
local Events = require(game.ReplicatedStorage.Events)



local to1d = IndexUtils.to1D
local Helper = {}

function Helper.AttackEntity(guid)
    Events.AttackEntity.send(guid)
end

function Helper.insertBlock(x,y,z,block)
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    local idx = to1d[lx][ly][lz]
    local old =   Chunk.getblock(chunk, idx)
    Chunk.insertBlock(chunk, idx, block)
    RenderHandler.blockUpdate(x, y, z)
    local pass = BlockReplication.update(x,y,z,block == 0)
    if not pass then
        Chunk.insertBlock(chunk, idx, old)
        RenderHandler.blockUpdate(x, y, z)
    end
    return true
end



return Helper
 