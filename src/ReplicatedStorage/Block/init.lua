local block = {}
--block.VOID = 65535
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local Synchronizer = require(game.ReplicatedStorage.Synchronizer)

local Blocks = {
    'c:air',
    'c:stone',
    'c:grass',
    'c:dirt'
}

local Cache = {}
local Debris = require(game.ReplicatedStorage.Libarys.Debris)
local BlockFolder = Debris.getOrCreateFolder("BlockFolder", 10)

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
        error(`'{str}' is not a valid block`)
    end
    Cache[str] = loc-1
    return loc-1
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
    local type,rot,id = block.decompress(compressedBlock)
    local resource = ResourceHandler.getBlock(Blocks[type+1])
    --//TODO: implement block ids
    return resource
end

function block.compress(blockID, rotation, otherData)
    if otherData == 0 and rotation == 0 then return blockID end 
    local packedValue = bit32.bor(bit32.lshift(otherData, 22), bit32.lshift(rotation, 16), blockID)
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

function block.decompressCache(packedValue)
    local current = BlockFolder:get(packedValue+3)
    if  current then return  unpack(current) end 
    local x,y,z = block.decompress(packedValue)
    BlockFolder:add(packedValue+3,{x,y,z}) 
    return x,y,z
end

function block.Init()
    if Synchronizer.isActor() then
        Blocks = Synchronizer.getDataActor("BlockData")
    elseif Synchronizer.isClient() then
        Blocks = Synchronizer.getDataClient("BlockData")
    else
        for blockName,_ in BehaviorHandler.getAllData().Blocks do
            if block.exists(blockName) then continue end 
            table.insert(Blocks,blockName)
        end
        Synchronizer.setData("BlockData",Blocks)
    end
    return block
end

return block