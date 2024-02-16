local mouse = {}

local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local Ray = require(game.ReplicatedStorage.CollisionHandler.Ray)
local DataHandler = require(game.ReplicatedStorage.Data)
local CurrentEntity = DataHandler.getPlayerEntity

local Camera = workspace.CurrentCamera
local EntityUtils = EntityHandler.Utils

local EnableHighlight = true
local CurrentRay = {}

local heightlight = Instance.new("Part",workspace)
heightlight.Size = Vector3.new(3,3,3)
heightlight.Anchored = true
heightlight.Transparency = 1
heightlight.Name = "SelectionPart"
local H = Instance.new("SelectionBox",heightlight)
H.Adornee = heightlight
H.LineThickness = .05

function mouse.enableHighlighting()
    EnableHighlight = true
end

function mouse.disableHightlighting()
    EnableHighlight = false
end

function mouse.getRay()
    return CurrentRay
end

function mouse.updateRay()
    local Entity = CurrentEntity()
    local block,Blockpos,hitpos,normal =  Ray.cast(EntityUtils.getEyePosition(Entity), (Camera.CFrame.LookVector*Vector3.new(1,1,1)).Unit*100)
    if block == -1 or not block then 
        CurrentRay = {}
        heightlight.Parent = script
        return 
    end 
    heightlight.Position = Blockpos*3
    heightlight.Parent = workspace
    CurrentRay = {
        Block = block,
        BlockPosition = Blockpos,
        HitPosition = hitpos,
        Normal = normal
    }   

end

function mouse.update()
    local Entity = CurrentEntity()
    if not Entity then return end 
    mouse.updateRay()
end

return mouse