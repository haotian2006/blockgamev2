
local Events = game.ReplicatedStorage.Events.Block
local BlockR:RemoteFunction = Events.Client 
local Update:RemoteEvent = Events.Update

local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Chunk = require(game.ReplicatedStorage.Chunk)
local Data = require(game.ReplicatedStorage.Data)
local Entity = require(game.ReplicatedStorage.EntityHandler)
local BlockClass = require(game.ReplicatedStorage.Block)
local Block = {}

function Block.update(x,y,z,id)
    Update:FireAllClients(Vector3.new(x,y,z),id)
end

local RandomObj = Random.new()
BlockR.OnServerInvoke = function(player,loc,id)
    local x,y,z = loc.X,loc.Y,loc.Z
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    local at = Chunk.getBlockAt(chunk, lx, ly, lz)
    Chunk.insertBlockAt(chunk, lx,ly,lz, id)
    if id == 0 then
        local Item = Entity.new("c:Item")
        local Block,_,Id = BlockClass.decompressCache(at)
        Entity.set(Item, "Position", Vector3.new(x,y,z))
        Item.Item = BlockClass.getBlock(Block)
        Item.ItemId = Id
        Item.ItemCount = 1
        Entity.setTemp(Item,"AliveTime",time()+.15)
        Data.addEntity(Item)
        local randVector = RandomObj:NextUnitVector()
        Entity.applyVelocity(Item,randVector*20)
    end
    for i,v in game:GetService("Players"):GetPlayers() do
        if v == player then continue end 
        task.spawn(Update.FireClient,Update,v,loc,id)
    end
    return true
end



return Block 