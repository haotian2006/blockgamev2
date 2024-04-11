local Chunk = require(game.ReplicatedStorage.Chunk)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local Data = require(game.ReplicatedStorage.Data)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local RenderHandler = require(script.Parent.core.chunk.Rendering.Handler)
local BlockReplication = require(script.Parent.core.Replication.Block)
local CollisionUtils = require(game.ReplicatedStorage.Utils.CollisionUtils)
local Events = require(game.ReplicatedStorage.Events)
local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local ItemHandler = require(game.ReplicatedStorage.Handler.Item)


local to1d = IndexUtils.to1D
local Helper = {}

function Helper.AttackEntity(guid)
    Events.AttackEntity.send(guid)
end 

function Helper.insertHoldingBlock(x,y,z)
    local Entity = Data.getPlayerEntity()
    if not Entity then return end 
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    local idx = to1d[lx][ly][lz]
    local old =   Chunk.getBlock(chunk, idx)
    local colliding =CollisionUtils.doesBlockCollideWithEntityAt(old,Vector3.new(x,y,z))
    if colliding then return false end 
    local holding = EntityHandler.getHolding(Entity)
    if not holding then return end 
    local b = ItemHandler.getBlock(holding)
    Chunk.insertBlock(chunk, idx,b)
    RenderHandler.blockUpdate(x, y, z)
    local pass = BlockReplication.placeHoldingBlock(x,y,z)
    if not pass then
        Chunk.insertBlock(chunk, idx, old)
        RenderHandler.blockUpdate(x, y, z)
    end
    return true
end



return Helper
 