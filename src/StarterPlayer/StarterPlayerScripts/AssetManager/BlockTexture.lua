local BTexture = {}

local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)

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

function BTexture.init()
    local AllBlocks = ResourceHandler.getAllBlocks()
    for block,BlockInfo in AllBlocks do
        if block == "ISFOLDER" then continue end 
        if not BlockInfo.Default then 
            BlockInfo.Texture = parseTexture(BlockInfo.Texture)
            continue
        end
        for _,Data in BlockInfo do
            if not Data.Texture then 
                for _,sub in Data do
                    if not sub.Texture then  continue end 
                    sub.Texture = parseTexture(sub.Texture)
                end
                continue
            end 
            Data.Texture = parseTexture(Data.Texture)
        end
    end
end

return BTexture