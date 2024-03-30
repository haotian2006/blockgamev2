local Items = {}
local Family
local function parseTexture(t)
    local type_ = typeof(t)

    if type_ == "table" then
        for face,texture in t do
            t[face] = parseTexture(texture)
        end
    elseif type_ == "Instance" and (t):IsA("Decal") then
        return (t::Decal).Texture
    end 
    return t
end

local function parseItem(name,data)
    local parsed = {}
    local default = data.default
    local family = {}
    if data.family then
        family = Family[data.family] or {}
    end
    local toCheck = default or data
    for i,v in family do 
        if toCheck[i] then continue end
        toCheck[i] = v
    end
    toCheck.Texture = parseTexture(toCheck.Texture)
    toCheck.Icon = parseTexture(toCheck.Icon)
    if not default then 
        data.__NoDefault = true
        return data 
    end 
    parsed.default = default
    local variants = data.variants or {default}
    --parsed.variants = variants
    for varoant,vData in next,variants do 
        vData.Texture = parseTexture(vData.Texture)
        vData.Icon = parseTexture(vData.Icon)
        for Attribue,value in default do
            if vData[Attribue] then 
                continue 
            end 
            vData[Attribue] = value
        end
        parsed[varoant] = vData
    end
    return parsed 
end

function Items.Init(Items,Family_)
    Family = Family_
    for i,v in Items do 
        Items[i] = parseItem(i,v)
    end
end

return Items