local Family
local function parse(name,data)
    local parsed = {}
    local Default = data.Default
    local family = {}
    if data.Family then
        family = Family[data.Family]
    end
    local toCheck = Default or data
    for i,v in family do 
        if toCheck[i] then continue end
        toCheck[i] = v
    end
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

return function (toParse,Family_)
    Family = Family_
    for name,info in toParse do
        local parsed = parse(name,info)
        toParse[name] = parsed
    end
end

