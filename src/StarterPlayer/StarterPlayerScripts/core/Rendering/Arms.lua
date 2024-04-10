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
local RenderHand 
local CurrentEntity 
local HealthChanged  

local Highlight:Highlight? 

local lastThread

local function OnChange(e)
    if HealthChanged then
        HealthChanged:Disconnect()
    end
    if not e then return end 
    HealthChanged = EntityHandler.getPropertyChanged(e, "Health")
    HealthChanged = HealthChanged:Connect(function(new,old)
        if (new < old) and Highlight then

            if lastThread and coroutine.status(lastThread) == "running" then
                task.cancel(lastThread)
            end
            Highlight.Enabled = true
            local t = task.delay(.3, function()
                Highlight.Enabled = false
            end)

            lastThread = t
        end
    end)
end

function Arms.update(dt)
    local Entity = PlayerEntity() 
    if CurrentEntity ~= Entity then
        OnChange(Entity)
        CurrentEntity = Entity
    end
    if not CurrentArms or not  CurrentEntity then return end 
    local Model:Model = CurrentArms.model
    local Head =  Model.Head
    Head.Anchored = true
    Head.CFrame = Camera.CFrame*CFrame.new(-.6,1.7,2.5)
    local aw = Model.Body["Right Arm"]
    local scale = Model:GetScale()
    if scale >=.9 then
        Model:ScaleTo(.15)
    end
    local Holding,data = EntityRender.renderHolding(CurrentArms,CurrentEntity.Holding,function(item)
        if CurrentArms.__CameraMode ~= "First" and item then
            EntityRender.setTransparencyOfModel(item.Parent,1)
        end
        if not item then
            Model:ScaleTo(1)
        else
            Model:ScaleTo(.15)
        end
    end)
    if Holding and Holding ~= "" and data then
        if type(data) == "table" then
            RenderHand = data.RenderHand
            if data.RenderHand == false or CurrentArms.__CameraMode ~= "First" then
                aw.Part1.LocalTransparencyModifier = 1
            else
                aw.Part1.LocalTransparencyModifier = 0
            end
        else
            RenderHand = true
        end
           aw.C0 = CurrentArms.OriginalC0 *CFrame.new(.85,-2,-3) *CFrame.Angles(math.rad(90),0,math.rad(20)) -- *CFrame.new(.85,-2,-3)
    elseif  not Holding or Holding == "" then
        aw.C0 = CurrentArms.OriginalC0*CFrame.new(.85,-2.1,-3) *CFrame.Angles(math.rad(130),0,math.rad(20))*CFrame.Angles(0,math.rad(70),0)
        RenderHand = true
        if CurrentArms.__CameraMode ~= "First" then return end 
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
    EntityHandler.set(CurrentArms, "model",Model)


    Model:ScaleTo(.15)

    Highlight = ResourceHandler.getAsset("DamageHighlight")

    if Highlight then
        Highlight.Enabled = false
        Highlight.Parent = Model
    end

    Model.Parent = Camera

    local aw = Model.Body["Right Arm"]
    CurrentArms.OriginalC0 = aw.C0

        
end

function Arms.setTransparency(value)
    if not CurrentArms then return end 
    EntityRender.setTransparency(CurrentArms, value)

    if value == 0 and   (RenderHand == false)  then
        CurrentArms.model["Right Arm"].LocalTransparencyModifier = 1
    end
end

function Arms.setMode(mode)
    if CurrentArms then 
        CurrentArms.__CameraMode = mode
    end
end

function Arms.isPlaying(ani)
    if not CurrentArms then return false end 
    return Animator.isPlaying(CurrentArms, ani)
end

function Arms.playAnimation(ani,fadeTime,weight,speed,loop)
    if not CurrentArms then return end 
    Animator.playLocal(CurrentArms, ani,fadeTime,weight,speed,loop)
    local Entity = PlayerEntity()
    if not Entity then return end 
    Animator.play(Entity, ani,fadeTime,weight,speed,loop)
end

function Arms.stopAnimation(ani,fadeTime)
    if not CurrentArms then return end 
    Animator.stop(CurrentArms, ani,fadeTime)
    local Entity = PlayerEntity()
    if not Entity then return end 
    Animator.stop(Entity, ani,fadeTime)
end




game:GetService("RunService").RenderStepped:Connect(Arms.update)

return Arms