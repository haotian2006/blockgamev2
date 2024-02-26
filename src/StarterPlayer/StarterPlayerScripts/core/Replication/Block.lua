 

local Events = game.ReplicatedStorage.Events.Block
local BlockR:RemoteFunction = Events.Client 
local Update:RemoteEvent = Events.Update

local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Chunk = require(game.ReplicatedStorage.Chunk)
local RenderHandler = require(script.Parent.Parent.chunk.Rendering.Handler)
local Data = require(game.ReplicatedStorage.Data)
local Block = {}

function Block.update(x,y,z,id)
    BlockR:InvokeServer(Vector3.new(x,y,z),id)
end

Update.OnClientEvent:Connect(function(loc,id)
    local x,y,z = loc.X,loc.Y,loc.Z
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    Chunk.insertBlockAt(chunk, lx,ly,lz, id)
    RenderHandler.blockUpdate(x, y, z)
    return true
end)

return Block 