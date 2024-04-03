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

local highlight = Instance.new("Part",workspace)
highlight.Size = Vector3.new(3,3,3)
highlight.Anchored = true
highlight.Transparency = 1
highlight.Name = "SelectionPart"
local H = Instance.new("SelectionBox",highlight)
H.Adornee = highlight
H.LineThickness = .05

local length = 5

function mouse.setHighlighting(value)
    EnableHighlight = value or false
end

function mouse.isHighlighting()
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
    local Results =  Ray.cast(EntityUtils.getEyePosition(Entity), (CameraCFrame.LookVector*Vector3.new(1,1,1)).Unit*length,RayParams)
    local block = Results.block
    local BlockPos = Results.grid
    if block == -1 or not block then 
        H.Visible = false 
    else
        highlight.Position = BlockPos*3
        H.Visible = EnableHighlight
    end 
    CurrentRay = Results

end

function mouse.update()
    local Entity = CurrentEntity()
    if not Entity then return end 
    mouse.updateRay()
end

return mouse