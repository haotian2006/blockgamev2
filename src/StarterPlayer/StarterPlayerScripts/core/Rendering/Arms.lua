--!nocheck
local Arms = {}
local Data = require(game.ReplicatedStorage.Data)
local PlayerEntity = Data.getPlayerEntity
local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local EntityRender = require(game.ReplicatedStorage.EntityHandler.Render)
local Animator = require(game.ReplicatedStorage.EntityHandler.Animator)

local Camera = workspace.CurrentCamera

local CurrentArms

function Arms.update(dt)
    local CurrentEntity = PlayerEntity() 
    if not CurrentArms or not  CurrentEntity then return end 
    local Model:Model = CurrentArms.__model
    local Head =  Model.Head
    Head.Anchored = true
    Head.CFrame = Camera.CFrame*CFrame.new(-.6,1.7,2.5)
    local aw = Model.Body["Right Arm"]
    local scale = Model:GetScale()
    if scale >=.9 then
        Model:ScaleTo(.15)
    end
    local Holding,data = EntityRender.renderHolding(CurrentArms,CurrentEntity.Holding,function(item)
        if not item then
            Model:ScaleTo(1)
        else
            Model:ScaleTo(.15)
        end
    end)
    if Holding and Holding ~= "" and data then
        if type(data) == "table" then
            if data.RenderHand == false then
                aw.Part1.LocalTransparencyModifier = 1
            else
                aw.Part1.LocalTransparencyModifier = 0
            end
        end
           aw.C0 = CurrentArms.OriginalC0 *CFrame.new(.85,-2,-3) *CFrame.Angles(math.rad(90),0,math.rad(20)) -- *CFrame.new(.85,-2,-3)
    elseif  not Holding or Holding == "" then
        aw.C0 = CurrentArms.OriginalC0*CFrame.new(.85,-2.1,-3) *CFrame.Angles(math.rad(130),0,math.rad(20))*CFrame.Angles(0,math.rad(70),0)
        aw.Part1.LocalTransparencyModifier = 0
    end
end

function Arms.getCurrent()
    return CurrentArms
end

function Arms.Init()
    local Entity = PlayerEntity()
    
    CurrentArms = EntityHandler.new("Special:Arm",-12345)

    local Model:Model = EntityRender.findModelFrom(CurrentArms)
    if not Model then return end 

    Model = Model:Clone()
    CurrentArms.__model = Model
    Model:ScaleTo(.15)

    Model.Parent = Camera

    local aw = Model.Body["Right Arm"]
    CurrentArms.OriginalC0 = aw.C0

        
end

function Arms.playerAnimation(ani)
    Animator.playLocal(CurrentArms, "Attack")
    local Entity = PlayerEntity()
    if not Entity then return end 
    Animator.play(Entity, ani)
end

game:GetService("UserInputService").InputBegan:Connect(function(k)
    if not CurrentArms or k.UserInputType ~= Enum.UserInputType.MouseButton1 then return end 

    Arms.playerAnimation("Attack")
end)

game:GetService("RunService").RenderStepped:Connect(Arms.update)

return Arms