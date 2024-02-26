local Block = {}

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