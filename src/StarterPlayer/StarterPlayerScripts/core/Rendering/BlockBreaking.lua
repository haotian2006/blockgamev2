local Breaking = {}
local BreakingBlocks = Instance.new("Folder",workspace)
BreakingBlocks.Name = "BlocksBreaking"

local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)

local getAssets = ResourceHandler.getAsset

function Breaking.createBlock()
    local data = {}
    local Block = Instance.new("Part")
    Block.Size = Vector3.one*3.02
    local Faces = {}
    data.Block = Block
    data.Faces = Faces
    Block.Transparency = 1
    Block.Position = Vector3.new(0,10000,0)
    Block.Anchored = true
    for i,v in Enum.NormalId:GetEnumItems() do
        local decal = Instance.new("Decal",Block)
        decal.Transparency = 0
        decal.Face = v
        Faces[i] = decal
    end
    Block.Parent = BreakingBlocks
    return data
end
 
function Breaking.updateLocation(data,grid)
    data.Block.Position = grid*3
end

function Breaking.setTexture(data,id)
    for i,v:Decal in data.Faces do
        v.Texture = id
    end
end

local Textures 

function Breaking.getNumOfFrames()
    Textures =  Textures or  ResourceHandler.getAsset("BlockBreakTextures")
    return #Textures
end

function Breaking.getTextureFromStage(stage)
    Textures =  Textures or  ResourceHandler.getAsset("BlockBreakTextures")
   if not Textures then return "" end 
    return Textures[stage] or Textures[#Textures] or ""

end

function Breaking.destroy(data)
    data.Block:Destroy()
end

local Breakers = {

}
local primaryL,primaryS 
function Breaking.setPrimary(location,stage)
    primaryL = location
    primaryS = stage
end

function Breaking.Update(locations)
    if primaryL then
        locations[primaryL] = primaryS
    end
    for i,stage in locations do
        local BreakerData = Breakers[i]
        if not BreakerData then
            BreakerData = Breaking.createBlock()
            Breakers[i] = BreakerData
            Breaking.updateLocation(BreakerData,i)
        end
        local t = Breaking.getTextureFromStage(stage)
        Breaking.setTexture(BreakerData,t)
    end
    for i,v in Breakers do
        if locations[i] then continue end 
        Breaking.destroy(v)
        Breakers[i] = nil
    end
end

return Breaking