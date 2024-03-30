local Block = {}

local function parseBlock(name,data)
    local parsed = {}
    local default = data.default
    if not default then 
        data.__NoDefault = true
        return data 
    end 
    parsed.default = default
    local variants = data.variants or {default}
    --parsed.variants = variants
    for varoant,vData in next,variants do 
        for Attribue,value in default do
            if vData[Attribue] then continue end 
            vData[Attribue] = value
        end
        parsed[varoant] = vData
    end

    return parsed
end

function Block.init(Blocks)
    for block,BlockInfo in Blocks do
        if block == "ISFOLDER" then continue end 
        local parsed = parseBlock(block,BlockInfo)
        Blocks[block] = parsed
    end
end



return table.freeze(Block)