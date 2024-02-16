
local Events = game.ReplicatedStorage.Events.Block
local BlockR:RemoteFunction = Events.Client 
local Update:RemoteEvent = Events.Update

local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Chunk = require(game.ReplicatedStorage.Chunk)
local Data = require(game.ReplicatedStorage.Data)
local Block = {}

function Block.update(x,y,z,id)
    Update:FireAllClients(Vector3.new(x,y,z),id)
end

BlockR.OnServerInvoke = function(player,loc,id)
    local x,y,z = loc.X,loc.Y,loc.Z
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    Chunk.insertBlockAt(chunk, lx,ly,lz, id)
    for i,v in game:GetService("Players"):GetPlayers() do
        if v == player then continue end 
        task.spawn(Update.FireClient,Update,v,loc,id)
    end
    return true
end



return Block 