
local Events = game.ReplicatedStorage.Events.Block
local CubicalEvents = require(game.ReplicatedStorage.Events)
local BlockR:RemoteFunction = Events.Client 
local Update:RemoteEvent = Events.Update

local RunService = game:GetService("RunService")

local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Chunk = require(game.ReplicatedStorage.Chunk)
local Data = require(game.ReplicatedStorage.Data)
local Entity = require(game.ReplicatedStorage.EntityHandler)
local BlockClass = require(game.ReplicatedStorage.Handler.Block)
local ItemClass =require(game.ReplicatedStorage.Handler.Item)
local ContainerClass = require(game.ReplicatedStorage.Handler.Container)
local CollisionUtils = require(game.ReplicatedStorage.Utils.CollisionUtils)


local Block = {}

local BlocksBreaking = {}

function Block.update(x,y,z,id)
    Update:FireAllClients(Vector3.new(x,y,z),id)
end

local RandomObj = Random.new()
local function getNearbyPlayers(x,y,z,exclude)
    local t = {}
    local i = 1
    for _,v in game:GetService("Players"):GetPlayers() do
        if v == exclude then continue end
        t[i] = v
        i+=1 
    end
    return t 
end
local function updateNearbyPlayers(x,y,z,block,exclude)
    for i,v in game:GetService("Players"):GetPlayers() do
        if v == exclude then continue end 
        CubicalEvents.UpdateBlock.sendTo({Vector3.new(x,y,z),block},v)
    end
end

function Block.placeBlock(x,y,z,block)
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    local at = Chunk.getBlockAt(chunk, lx, ly, lz)
    if at ~= 0 then return false end
    local colliding = CollisionUtils.doesBlockCollideWithEntityAt(block,Vector3.new(x,y,z))
    if colliding then return false end 
    Chunk.insertBlockAt(chunk, lx,ly,lz, block)
    updateNearbyPlayers(x,y,z,block)
    return true
end

function Block.breakBlock(x,y,z)
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    local at = Chunk.getBlockAt(chunk, lx, ly, lz)

    Chunk.insertBlockAt(chunk, lx,ly,lz, 0)
     if not at or at == 0 then return false end 
    local Item = Entity.new("c:Item")
    local Block,Id = BlockClass.decompress(at)
    Entity.set(Item, "Position", Vector3.new(x,y,z))
    Item.ItemId = ItemClass.getIndexFromName(BlockClass.getBlock(Block))
    Item.ItemVariant = Id
    Item.ItemCount = 1
    Entity.setTemp(Item,"AliveTime",time()+.15)
    Data.addEntity(Item)
    local randVector = RandomObj:NextUnitVector()
    Entity.applyVelocity(Item,randVector*20)
    updateNearbyPlayers(x,y,z,0)

    return true
end

BlockR.OnServerInvoke = function(player,coord)
    local playerEntity = Data.getEntityFromPlayer(player)
    if not playerEntity then return end 
    local holding,Loc,Container = Entity.getSlot(playerEntity)
    
    local x,y,z = coord.X,coord.Y,coord.Z
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    local at = Chunk.getBlockAt(chunk, lx, ly, lz)

    if holding == "" then  
        return false
    end



    if at ~= 0 then return false  end 
    local block = ItemClass.getBlock(holding[1])
    if not block then return false end 
    local pass =Block.placeBlock(x,y,z,block)
    if not pass then return false end 
    ContainerClass.setCount(Container, Loc, -1)

    return true
end


function Block.startBreaking(entity,x,y,z)
    local block = Data.getBlock(x, y, z)
    if block == 0 then return end 
    local HoldingItem = Entity.getHolding(entity)

    local Multiplier = 1
    local TimeToBreak = BlockClass.get( block, "BreakTime") or 1
    if HoldingItem then
        Multiplier = ItemClass.getBreakMultiplier(HoldingItem, block) or 1
    end
    local Owner = Entity.getOwner(entity)
    local players = getNearbyPlayers(x,y,z,Owner)

    local data = {
        Entity = entity,
        LastHolding = HoldingItem,
        Block = block,
        Location = Vector3.new(x,y,z),
        Progress = 0
    }
    if  BlocksBreaking[entity] then
        Block.stopBreaking(entity)
    end
    BlocksBreaking[entity] = data
    CubicalEvents.StartBreakingBlockClient.sendToList({entity.Guid,Vector3.new(x,y,z),Multiplier,TimeToBreak},players)
end

function Block.stopBreaking(entity)
    local data =  BlocksBreaking[entity] 
    if not data then return end 
    BlocksBreaking[entity]  = nil
    local loc = data.Location
    local players = getNearbyPlayers(loc.X,loc.Y,loc.Z,Entity.getOwner(entity))
    CubicalEvents.StopBreakingBlock.sendToList(entity.Guid,players)
end

local function UpdateTimeForOne(data,dt)
    local entity = data.Entity
    local LastHolding = data.LastHolding
    local HoldingItem = Entity.getHolding(entity)
    local Location = data.Location
    local block = Data.getBlock(Location.X,Location.Y,Location.Z)
 
    if (LastHolding~=HoldingItem and not ItemClass.equals(LastHolding,HoldingItem)) or data.Block ~= block then
        Block.stopBreaking(entity)
        return false
    end
    local Multiplier = 1
    local TimeToBreak = BlockClass.get( block, "BreakTime") or 1
    if HoldingItem then
        Multiplier = ItemClass.getBreakMultiplier(HoldingItem, block) or 1
    end
    data.Progress += dt*Multiplier
    if data.Progress > TimeToBreak then
        Block.breakBlock(Location.X,Location.Y,Location.Z)
        Block.stopBreaking(entity)
    end
    return true
end

CubicalEvents.StartBreakingBlockServer.listen(function(loc,player)
    local Entity = Data.getEntityFromPlayer(player)
    if not Entity then return end 
    Block.startBreaking(Entity,loc.X,loc.Y,loc.Z)
end)

CubicalEvents.StopBreakingBlock.listen(function(_, player: Player)  
    local Entity = Data.getEntityFromPlayer(player)
    if not Entity then return end 
    Block.stopBreaking(Entity)
end)

RunService.Heartbeat:Connect(function(dt)
    for i,v in BlocksBreaking do
        UpdateTimeForOne(v,dt)
    end
end)

return Block 