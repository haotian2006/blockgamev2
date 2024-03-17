local Chunk = require(game.ReplicatedStorage.Chunk)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local Data = require(game.ReplicatedStorage.Data)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local RenderHandler = require(script.Parent.core.chunk.Rendering.Handler)
local BlockReplication = require(script.Parent.core.Replication.Block)

local to1d = IndexUtils.to1D
local Helper = {}


function Helper.insertBlock(x,y,z,block)
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    local idx = to1d[lx][ly][lz]
    Chunk.insertBlock(chunk, idx, block)
    RenderHandler.blockUpdate(x, y, z)
    BlockReplication.update(x,y,z,block == 0)
    return true
end

return Helper
 