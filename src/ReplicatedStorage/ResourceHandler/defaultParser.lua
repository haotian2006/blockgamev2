local family
local function parse(name,data)
    local parsed = {}
    local default = data.default
    local family = {}
    if data.family then
        family = family[data.family]
    end
    local toCheck = default or data
    for i,v in family do 
        if toCheck[i] then continue end
        toCheck[i] = v
    end
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

return function (toParse,Family_)
    family = Family_
    for name,info in toParse do
        local parsed = parse(name,info)
        toParse[name] = parsed
    end
end

