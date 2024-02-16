local Block = {}
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local Blocks = ResourceHandler.getAllBlocks()

local function parseBlock(name,data)
    local parsed = {}
    local Default = data.Default
    if not Default then 
        data.__NoDefault = true
        return data 
    end 
    parsed.Default = Default
    local Variants = data.Variants or {Default}
    --parsed.Variants = Variants
    for varoant,vData in next,Variants do 
        for Attribue,value in Default do
            if vData[Attribue] then continue end 
            vData[Attribue] = value
        end
        parsed[varoant] = vData
    end

    -- local BVariants = data.BiomeVarients or {}
    -- parsed.BiomeVarients = {}
    -- for biome,vData in BVariants do
    --     if type(vData) == "table" then
    --         for Attribue,value in Default do
    --             if vData[Attribue] then continue end 
    --             vData[Attribue] = value
    --         end
    --         parsed[biome] = vData
    --     else
    --         parsed[biome] = Variants[vData] or Default
    --     end
    -- end
    
    return parsed
end

function Block.init()
    for block,BlockInfo in Blocks do
        if block == "ISFOLDER" then continue end 
        local parsed = parseBlock(block,BlockInfo)
        Blocks[block] = parsed
    end
end

function Block.getBlockData(name,id)
    local blockData = Blocks[name]
    if not blockData then 
        return 
    end 
    if blockData.__NoDefault then
        return blockData
    end
    
    -- if biome and blockData[biome] then
    --     return blockData[biome]
    -- end
    if not id or id == 0 then
        return  blockData.Default
    end

    return blockData[(id and id or "1")] or blockData.Default
end

function Block.getAllBlocks()
    return Blocks
end

return table.freeze(Block)