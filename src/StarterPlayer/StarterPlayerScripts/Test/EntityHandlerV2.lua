local RunService = game:GetService("RunService")
local resource =require(game.ReplicatedStorage.ResourceHandler)
local function CreateModel(Data,ParentModel)
    local model = resource.GetEntity("Player").Model
    if model then
        model = model:Clone()
        local humanoid = model:FindFirstChildWhichIsA("Humanoid")  
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new('Animator',humanoid)
        humanoid.Name = "AnimationController"
        humanoid.RigType = Enum.HumanoidRigType.R6
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.RequiresNeck = false
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        model.Parent = ParentModel
        model.Name = "EntityModel"
        local weld = Instance.new("Motor6D",ParentModel.PrimaryPart)
        weld.Name = "EntityModelWeld"
        weld.Part0 = ParentModel.PrimaryPart
        weld.Part1 = model.PrimaryPart
        return model
    end
end

local Render = require(game.ReplicatedStorage.EntityHandlerV2.Render)
local Animator = require(game.ReplicatedStorage.EntityHandlerV2.Animator)
local Handler = require(game.ReplicatedStorage.EntityHandlerV2)
local Client = require(game.ReplicatedStorage.EntityHandlerV2.EntityReplicator.Client)
Client.Init()
local entity = Handler.new("Player")
entity.Position = Vector3.new(340,64,-80)
local part = Instance.new("Part")
do
    part.Anchored = true
part.Size = Vector3.new(0.6,1.79,.6)*3
part.Parent = workspace
entity.__ownership = game.Players.LocalPlayer.UserId
end
local M = Instance.new("Model",workspace)
do
    part.Parent = M
part.Transparency = .7
part.Name = "HitBox"
M.PrimaryPart = part
end
CreateModel(entity,M)
entity.__model = M
local fixedTick = 0
local FixedTime = 1/20
Animator.play(entity,"Roll")
local holder = require(game.ReplicatedStorage.EntityHandlerV2.EntityHolder)
holder.addEntity(entity)
RunService.Stepped:Connect(function(p,deltaTime)
    fixedTick += deltaTime
    Handler.update(entity,deltaTime,fixedTick)
   -- part.CFrame = CFrame.new( entity.Position*3)
    if fixedTick > FixedTime then
        fixedTick = 0
    end
end)
Render.createModel(entity)
Render.Init()
-- RunService.RenderStepped:Connect(function(deltaTime)
--     Render.updateRotation(entity)
-- end)
task.spawn(function()
    task.wait(10)
    Animator.stop(entity,"Roll")
    print(entity)
end)
return entity