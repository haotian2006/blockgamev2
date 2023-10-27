local RunService = game:GetService("RunService")
local Entity = require(script.Parent)
local Updater = {}
local fixedTick = 0
local FixedTime = 1/20
local IS_CLIENT = RunService:IsClient()
local Render = require(script.Parent.Render)
RunService.Heartbeat:Connect(function(deltaTime)
    fixedTick += deltaTime
    if fixedTick > FixedTime then
        fixedTick = 0
    end
end)
return Updater