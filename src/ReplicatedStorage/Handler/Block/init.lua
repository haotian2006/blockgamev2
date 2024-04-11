local block = {}
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

function block.exists(str)
    if Cache[str] then
        return true
    end
    local loc = table.find(Blocks, str)
    Cache[str] = if loc then loc-1 else nil
    return if loc then true else false 
end

function block.getBlockId(str)
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

function block.awaitBlock(str)
    if not Loading then 
        return block.getBlockId(str)
    end 
    Loading.Event:Wait()
    return block.getBlockId(str)
end

function block.getBlock(id)
    return Blocks[id+1] 
end

function block.getResource(Block,Id)
    local resource = ResourceHandler.getBlock(Block)
    --//TODO: implement block ids
    return resource
end

function block.getResourceFrom(compressedBlock)
    local type,id = block.decompress(compressedBlock)
    local resource = ResourceHandler.getBlock(Blocks[type+1])
    --//TODO: implement block ids
    return resource
end

function block.getDataFrom(BlockName,variant)
    return BehaviorHandler.getBlockInfo(BlockName, variant)
end

function block.getData(CompressedBLock)
    local Id,Variant = block.decompress(CompressedBLock)
    local str = block.getBlock(Id)
    local data = block.getDataFrom(str,Variant)
    return data
end

function block.get(BLOCK,key)
    local Id,Variant = block.decompress(BLOCK)
    local str = block.getBlock(Id)
    local data = block.getDataFrom(str,Variant)
    if not data then return end 
    return data[key]
end



--//BlockId:14 bits , Variant: 7 bits , Extra Data/rot(3): 11
function block.compress(blockID, variant, extra)
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
function block.decompress(packedValue)
    if packedValue <16382 then
        return packedValue
    end
    local blockID = bit32.band(packedValue, 16383)  -- 13
    local variant = bit32.rshift(bit32.band(packedValue, 0b111111100000000000000), 14)  -- 8
    local extra = bit32.rshift(bit32.band(packedValue, 0b11111111111000000000000000000000), 21)  -- 11

    return blockID, variant, extra
end



function block.parse(t)
    if type(t) == "table" then
        if t.Block then 
            return block.compress(block.getBlockId(t.Block), t.Id or 0, t.Rotation)
        else
            return block.compress(block.getBlockId(t[1]), t[2] or 0, t[3] or 0)
        end
    elseif type(t) == "number" then
        return t
    end
    return block.getBlockId(t)
end

local initAlready = false
function block.Init()
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
            if block.exists(blockName) then continue end 
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
    return block
end

return block