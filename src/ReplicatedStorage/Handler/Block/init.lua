local Block = {}
--block.VOID = 65535
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local Synchronizer = require(game.ReplicatedStorage.Synchronizer)
local Loading = Instance.new("BindableEvent")

local Blocks = {
    'c:air',
    'c:stone',
    'c:grassBlock',
    'c:dirt'
}

local Cache = {}
local Debris = require(game.ReplicatedStorage.Libs.Debris)
local BlockFolder = Debris.getFolder("BlockFolder", 10)

function Block.exists(str)
    if Cache[str] then
        return true
    end
    local loc = table.find(Blocks, str)
    Cache[str] = if loc then loc-1 else nil
    return if loc then true else false 
end

function Block.getBlockId(str)
    if Cache[str] then
        return Cache[str]
    end
    local loc = table.find(Blocks, str)
    if not loc  then
        loc = 1
        return nil
    end
    Cache[str] = loc-1 
    return loc-1
end

function Block.awaitBlock(str)
    if not Loading then 
        return Block.getBlockId(str)
    end 
    Loading.Event:Wait()
    return Block.getBlockId(str)
end

function Block.getBlock(id)
    return Blocks[id+1] 
end

function Block.getResource(block,Id)
    local resource = ResourceHandler.getBlock(block)
    --//TODO: implement block ids
    return resource
end

function Block.getResourceFrom(block)
    local type,id = Block.decompress(block)
    local resource = ResourceHandler.getBlock(Blocks[type+1])
    --//TODO: implement block ids
    return resource
end

function Block.getDataFrom(blockName,variant)
    return BehaviorHandler.getBlockInfo(blockName, variant)
end

function Block.getData(block)
    local Id,Variant = Block.decompress(block)
    local str = Block.getBlock(Id)
    local data = Block.getDataFrom(str,Variant)
    return data
end

function Block.get(block,key)
    local Id,Variant = Block.decompress(block)
    local str = Block.getBlock(Id)
    local data = Block.getDataFrom(str,Variant)
    if not data then return end 
    return data[key]
end

function Block.getBaseData(block)
    local Id = Block.decompress(block)
    local str = Block.getBlock(Id)
    return BehaviorHandler.getBlock(str)
end

function Block.getEvent(block,event)
    local data = Block.getBaseData(block)
    if not data then return end 
    return data.events[event]
end


--//BlockId:14 bits , Variant: 7 bits , Extra Data/rot(3): 11
function Block.compress(blockID, variant, extra)
    variant = variant or 0
    extra = extra or 0
    
    if variant == 0 and extra == 0 then
        return blockID
    end
    
    local packedValue = bit32.bor(
        bit32.lshift(extra, 21),
        bit32.lshift(variant, 14),
        blockID
    )
    
    return packedValue
end

--[[
function block.compress(blockID, rotation, variant,extra)
    variant = variant or 0
    extra = extra or 0
    rotation = rotation or 0
    if extra == 0  and rotation == 0 then return blockID end 
    local packedValue = bit32.bor(bit32.lshift(variant, 22), bit32.lshift(rotation, 16), blockID)
    return packedValue
end


function block.decompress(packedValue)
    if packedValue <65536 then
		return packedValue,0,0
	end
    local other = bit32.rshift(bit32.band(packedValue, 4290772992), 22) -- 9
    local rotation = bit32.rshift(bit32.band(packedValue, 4128768), 16) -- 6
    local blockID = bit32.band(packedValue, 65535) -- 16
    return blockID, rotation, other
end


]]
--[[
   
]]
function Block.decompress(packedValue)
    if packedValue <16382 then
        return packedValue
    end
    local blockID = bit32.band(packedValue, 16383)  -- 13
    local variant = bit32.rshift(bit32.band(packedValue, 0b111111100000000000000), 14)  -- 8
    local extra = bit32.rshift(bit32.band(packedValue, 0b11111111111000000000000000000000), 21)  -- 11

    return blockID, variant, extra
end



function Block.parse(t)
    if type(t) == "table" then
        if t.Block then 
            return Block.compress(Block.getBlockId(t.Block), t.Id or 0, t.Rotation)
        else
            return Block.compress(Block.getBlockId(t[1]), t[2] or 0, t[3] or 0)
        end
    elseif type(t) == "number" then
        return t
    end
    return Block.getBlockId(t)
end

local initAlready = false
function Block.Init()
    if initAlready then return end 
    initAlready = true
    if Synchronizer.isActor() then
        Blocks = Synchronizer.getDataActor("BlockData")
    elseif Synchronizer.isClient() then
        Blocks = Synchronizer.getDataClient("BlockData")
    else
        local Saved = Synchronizer.getSavedData("BlockData")
        if Saved then
            Blocks = Saved
        end
        local newAdded = false
        for blockName,_ in BehaviorHandler.getAllData().Blocks do
            if Block.exists(blockName) then continue end 
            table.insert(Blocks,blockName)
            newAdded = true
        end
        if newAdded then
            Synchronizer.updateSavedData("BlockData",Blocks)
        end
        Synchronizer.setData("BlockData",Blocks)
    end
    local t = Loading
    Loading = nil
    t:Fire()
    return Block
end

return Block