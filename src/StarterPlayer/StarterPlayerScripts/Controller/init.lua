local Controller = {}
local InputHandler = require(script.Parent:WaitForChild("InputHandler"))
local Camera = workspace.CurrentCamera
local IsMoving = false 
local Data = require(game.ReplicatedStorage.Data)
local LPE = Data.getPlayerEntity
local EntityV2 = game.ReplicatedStorage.EntityHandler
local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local EntityUtils = EntityHandler.Utils
local MathLib = require(game.ReplicatedStorage.Libarys.MathFunctions)
local EntityTaskReplicator = require(game.ReplicatedStorage.EntityHandler.EntityReplicator.EntityTaskReplicator)
local Animator = require(EntityV2.Animator)
local Funcs = {}
function Funcs.Crouch(key,IsDown,GPE,inputs)
    local Player = LPE()
    if EntityHandler.isDead(Player) or  Player.Crouching or not IsDown then return end 
    EntityHandler.crouch(Player,true)
    repeat
        task.wait()
    until (not InputHandler.isDown("Crouch") and   EntityHandler.canCrouch(Player,true))
    EntityHandler.crouch(Player,false)
end

local ray = require(game.ReplicatedStorage.CollisionHandler.Ray)


local hitPos = Instance.new("Part",workspace)
hitPos.Size = Vector3.one 
hitPos.Color = Color3.new(0.960784, 0.803922, 0.513725)
hitPos.Anchored = true
local heightlight = Instance.new("Part",workspace)
heightlight.Size = Vector3.new(3,3,3)
heightlight.Anchored = true
local H = Instance.new("Highlight",heightlight)
H.Adornee = heightlight

function Funcs.HitBoxs(key,IsDown,GPE,inputs)
    if not IsDown then return end 
    local Camera = workspace.CurrentCamera
    local block,Blockpos,hitpos,normal =  ray.cast(Camera.CFrame.Position/3, (Camera.CFrame.LookVector*Vector3.new(1,1,1)).Unit*100)
    if block == -1 or not block then return end 
    heightlight.Position = Blockpos*3
   -- hitPos.Position = hitpos*3

end

function  Controller.createBinds()
    InputHandler.bindToRender("#Controller-Handler",function(dt)
        local Entity = LPE()
        if EntityHandler.isDead(Entity) then return end 
        local F = InputHandler.isDown("Foward")
        local B = InputHandler.isDown("Back")
        local L = InputHandler.isDown("Left")
        local R = InputHandler.isDown("Right")
        local CameraCFrame = Camera.CFrame
        local LookVector = CameraCFrame.LookVector
        local RightVector = CameraCFrame.RightVector
        LookVector = Vector3.new(LookVector.X,0,LookVector.Z).Unit -- Vector3.new(1,0,0)
        RightVector = Vector3.new(RightVector.X,0,RightVector.Z).Unit --Vector3.new(0,0,1)
        local foward = LookVector*(F and 1 or 0)
        local Back = -LookVector*(B and 1 or 0)
        local Left = -RightVector*(L and 1 or 0)
        local Right = RightVector*(R and 1 or 0)
        local velocity = foward + Back + Left+ Right
        local v2 = foward + Back*-1 + (B and -1 or 1)*(Left+ Right)
        velocity = ((velocity.Unit ~= velocity.Unit) and Vector3.new(0,0,0) or velocity.Unit)
        v2 = ((v2.Unit ~= v2.Unit) and Vector3.new(0,0,0) or v2.Unit)
        if velocity:FuzzyEq(Vector3.zero,0.01) then
           IsMoving = false
        else
           IsMoving = true
        end
        
        EntityHandler.setMoveDireaction(Entity,velocity) 
        local pitch,yaw = MathLib.GetP_YawFromVector3((CameraCFrame.LookVector))
        EntityUtils.rotateHeadTo(Entity,Vector2.new(pitch,yaw))
        if InputHandler.isDown("Jump") then
            EntityHandler.jump(Entity)
        end
    end)
    
    for i,v in Funcs do
        InputHandler.bindFunctionTo(`{i}-Controller`,v,i)
    end
end
function Controller.setCameraTo(entity)
   if entity and entity.__model and entity.__model:FindFirstChild("Eye") then
    Camera.CameraSubject = entity.__model.Eye
   end
end
function Controller.destroyBinds()
    InputHandler.unbindFromRender("#Controller-Handler")
    for i,v in Funcs do
        InputHandler.unbindFunction(`{i}-Controller`)
    end
end
return Controller