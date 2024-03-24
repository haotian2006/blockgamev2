local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local InputService = require(script.Parent.Parent.InputHandler)
local UsrSettings = UserSettings():GetService("UserGameSettings")
local EntityUtils = require(game.ReplicatedStorage.EntityHandler.Utils)
local Render = require(game.ReplicatedStorage.EntityHandler.Render)
local Arms = require(script.Parent.Parent.core.Rendering.Arms)
local Ray = require(game.ReplicatedStorage.CollisionHandler.Ray)

local CurrentCamera = workspace.CurrentCamera
local CameraRotation = Vector2.new(0,0) 

local MAX_ROTY = math.rad(89.5)

local loc = Vector3.new(0,0,0)
local CameraCFrame = CFrame.new()
local Camera = {}

local PauseRotation = false
local Mode = "First"
local Subject
local IsPaused = false

function Camera.UpdateTransparency()
     if not Subject then return end 
     if Mode == "First" then
          Render.setTransparency(Subject, 1)
          Arms.setTransparency(0)
     else
          Render.setTransparency(Subject, 0)
          Arms.setTransparency(1)
     end
end

function Camera.bindToEntity(Entity)
     if Subject then
          Subject.__CameraMode = nil
     end
     Subject = Entity
     if Entity then
          local dir = EntityUtils.calculateLookAt(Entity)
          local cframe = CFrame.lookAt(Vector3.new(),dir)

          local lookVector = cframe.lookVector

          local rotationX = math.atan2(lookVector.Y, math.sqrt(lookVector.X^2 + lookVector.Z^2))
          local rotationY = math.atan2(-lookVector.X, -lookVector.Z)
   

          CameraRotation = Vector2.new(-rotationY,-rotationX)

     end
     Camera.setMode(Mode)
end

function Camera.getBaseCamera():Camera
     return CurrentCamera
end

function Camera.lookAt(lookVector)
     local rotationX = math.atan2(lookVector.Y, math.sqrt(lookVector.X^2 + lookVector.Z^2))
     local rotationY = math.atan2(-lookVector.X, -lookVector.Z)


     CameraRotation = Vector2.new(-rotationY,-rotationX)
end

function Camera.setPos(pos)
     loc = pos
end

function Camera.getCFrame()
     return CameraCFrame
end

function Camera.setMode(mode)
     if IsPaused then return end 
     Mode = mode or "First"
     Camera.UpdateTransparency()
     Arms.setMode(Mode)
end

function Camera.getMode(Mode)
     Mode = Mode 
end

function Camera.pause(unpause)
     IsPaused = not unpause
end

function Camera.isPaused()
     return IsPaused
end


function Camera.Update() 
     if IsPaused then return end
     CurrentCamera.CameraType =  Enum.CameraType.Scriptable
     UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
     if not PauseRotation then 
          CameraRotation = CameraRotation + UserInputService:GetMouseDelta() * math.rad( UserInputService.MouseDeltaSensitivity*UsrSettings.MouseSensitivity*3)
     end 
     local cameraRotationY = -CameraRotation.Y
     
     cameraRotationY = math.clamp(cameraRotationY, -MAX_ROTY, MAX_ROTY)

     CameraRotation = Vector2.new(CameraRotation.X, -cameraRotationY)

     if Subject  then
          loc = EntityUtils.getEyePosition(Subject)
          Subject.__CameraMode = Mode
     end
     CameraCFrame = CFrame.new(loc) * CFrame.Angles(0,-CameraRotation.X,0) * CFrame.Angles(cameraRotationY,0,0)
     local offset = CFrame.new()
     local toSet = CFrame.new(loc*3) * CameraCFrame.Rotation
     if Mode == "Third" then
          local distance = 15
          offset = CFrame.new(0,0,distance)
          local param = RaycastParams.new()
          param.FilterDescendantsInstances ={ workspace.Chunks}
          param.FilterType = Enum.RaycastFilterType.Include
          local hit = workspace:Blockcast(CFrame.new(loc*3),Vector3.new(.5,.5,.5), -CameraCFrame.LookVector*distance,param)
          --local block,hitpos = Ray.cast(loc, CameraCFrame.LookVector*-5)
          if hit then
               local mag = (hit.Position-loc*3).Magnitude
               offset = CFrame.new(0,0,mag-.30)--hit.Normal*.7
          end
          toSet*=offset
     elseif Mode == "Second"  then
          local distance = 15
          offset = CFrame.new(0,0,-distance)
          local param = RaycastParams.new()
          param.FilterDescendantsInstances ={ workspace.Chunks}
          param.FilterType = Enum.RaycastFilterType.Include
          local hit = workspace:Blockcast(CFrame.new(loc*3),Vector3.new(.5,.5,.5), toSet.LookVector*distance,param)
          --local block,hitpos = Ray.cast(loc, CameraCFrame.LookVector*-5)
          if hit then
               local mag = (hit.Position-loc*3).Magnitude
               offset = CFrame.new(0,0,-(mag-.30))--hit.Normal*.7
          end
          local pos = (toSet*offset).Position
          local lv = -toSet.LookVector
          toSet =  CFrame.lookAt(pos, pos+lv)
     end
     CurrentCamera.CFrame = toSet
end

RunService:BindToRenderStep("UpdateCamera-BaseCamera",1,Camera.Update)
 

return Camera