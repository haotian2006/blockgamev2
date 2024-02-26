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
    toCheck.Texture = parseTexture(toCheck.Texture)
    toCheck.Icon = parseTexture(toCheck.Icon)
    if not Default then 
        data.__NoDefault = true
        return data 
    end 
    parsed.Default = Default
    local Variants = data.Variants or {Default}
    --parsed.Variants = Variants
    for varoant,vData in next,Variants do 
        vData.Texture = parseTexture(vData.Texture)
        vData.Icon = parseTexture(vData.Icon)
        for Attribue,value in Default do
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