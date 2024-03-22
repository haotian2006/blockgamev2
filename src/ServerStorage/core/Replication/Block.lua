
local Events = game.ReplicatedStorage.Events.Block
local BlockR:RemoteFunction = Events.Client 
local Update:RemoteEvent = Events.Update

local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Chunk = require(game.ReplicatedStorage.Chunk)
local Data = require(game.ReplicatedStorage.Data)
local Entity = require(game.ReplicatedStorage.EntityHandler)
local BlockClass = require(game.ReplicatedStorage.Block)
local ItemClass =require(game.ReplicatedStorage.Item)
local ContaineClass = require(game.ReplicatedStorage.Container)
local Block = {}

function Block.update(x,y,z,id)
    Update:FireAllClients(Vector3.new(x,y,z),id)
end

local RandomObj = Random.new()
BlockR.OnServerInvoke = function(player,coord,isBreak)
    local playerEntity = Data.getEntityFromPlayer(player)
    if not playerEntity then return end 
    local holding,Loc,Containter = Entity.getSlot(playerEntity)
    local blockComp
    
    local x,y,z = coord.X,coord.Y,coord.Z
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    local at = Chunk.getBlockAt(chunk, lx, ly, lz)

    if holding == "" or isBreak then  
        blockComp = 0
    else
        local BlockName = ItemClass.getName(holding[1])
        if not BlockClass.exists(BlockName) then 
            blockComp = 0
        else
            if at ~= 0 then return end 
            local var = holding[1][2]
            local BlockId = BlockClass.getBlockId(BlockName)
            blockComp = BlockClass.compress(BlockId, nil, var)
            ContaineClass.setCount(Containter, Loc, -1)
        end
    end 
    
    if not blockComp then return false end 
    Chunk.insertBlockAt(chunk, lx,ly,lz, blockComp)
    if blockComp == 0 then
        local Item = Entity.new("c:Item")
        local Block,_,Id = BlockClass.decompressCache(at)
        Entity.set(Item, "Position", Vector3.new(x,y,z))
        Item.ItemId = ItemClass.getIndexFromName(BlockClass.getBlock(Block))
        Item.ItemVariant = Id
        Item.ItemCount = 1
        Entity.setTemp(Item,"AliveTime",time()+.15)
        Data.addEntity(Item)
        local randVector = RandomObj:NextUnitVector()
        Entity.applyVelocity(Item,randVector*20)
    end
    for i,v in game:GetService("Players"):GetPlayers() do
        if v == player then continue end 
        task.spawn(Update.FireClient,Update,v,coord,blockComp)
    end
    return true
end



return Block 