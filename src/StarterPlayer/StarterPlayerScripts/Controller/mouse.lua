local mouse = {}

local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local Ray = require(game.ReplicatedStorage.CollisionHandler.Ray)
local DataHandler = require(game.ReplicatedStorage.Data)
local CustomCamera = require(script.Parent.Camera)

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

local length = 5

function mouse.setHighlighting(value)
    EnableHighlight = value or false
end

function mouse.getHighlighting()
    return EnableHighlight  
end



function mouse.setRayLength(Length)
    length = Length or 5
    mouse.updateRay()
end

function mouse.getRay()
    return CurrentRay
end

function mouse.updateRay()
    local Entity = CurrentEntity()
    if not Entity then return end 
    local RayParams = Ray.createEntityParams({Entity.Guid})
    local CameraCFrame = CustomCamera.getCFrame()
    local block,Blockpos,hitpos,normal =  Ray.cast(EntityUtils.getEyePosition(Entity), (CameraCFrame.LookVector*Vector3.new(1,1,1)).Unit*length,RayParams)
    if block == -1 or not block then 
        CurrentRay = {}
        H.Visible = false
        return 
    end 
    heightlight.Position = Blockpos*3
    H.Visible = EnableHighlight
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