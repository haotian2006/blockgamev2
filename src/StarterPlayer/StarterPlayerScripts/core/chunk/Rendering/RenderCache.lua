local Storage = {}
local Cahce = workspace.RenderCache

local FarCFrame = CFrame.new(0,99999999,0)
local maxBlocks  = 30000
local NotInUseB = {}

local maxTextures  = 30000
local NotInUseT = {}

local texture = Instance.new("Texture")
texture.StudsPerTileU = 3.02
texture.StudsPerTileV = 3.02

local toClone = Instance.new("Part")
toClone.Anchored = true
toClone.Massless = true

do
    for i =1,maxBlocks do
        NotInUseB[i] = toClone:Clone()
        NotInUseB[i].Parent = script
    end
    task.wait()
    for i =1,maxTextures do
        NotInUseT[i] = texture:Clone()
        NotInUseT[i].Parent = script
    end
end

function Storage.getStats()
    return #NotInUseB,#NotInUseT
end

function Storage.getNextBlock()
    local p = NotInUseB[#NotInUseB]
    NotInUseB[#NotInUseB] = nil
    if not p then
        return toClone:Clone()
    end
    return p 
end

function Storage.getNextTexture()
    local p = NotInUseT[#NotInUseT]
    NotInUseT[#NotInUseT] = nil
    if  not p then
        return texture:Clone()
    end
    return p
end

function Storage.sendTextureBackToQueue(t)
    if #NotInUseT>maxTextures then 
        t:Destroy()
        return 
    end
    t.Parent = script
    NotInUseT[#NotInUseT+1] = t
end

function Storage.sendBlockBackToQueue(t)
    if #NotInUseB>maxBlocks then 
        t:Destroy()
        return 
    end
    t.Parent = script
    NotInUseB[#NotInUseB+1] = t
end

return Storage