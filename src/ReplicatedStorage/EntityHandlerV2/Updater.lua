local RunService = game:GetService("RunService")
local Handler = require(script.Parent)
local Updater = {}
local fixedTick = 0
local FixedTime = 1/20
local IS_CLIENT = RunService:IsClient()
local Render = require(script.Parent.Render)
local EntityHolder = require(script.Parent.EntityHolder)
local Connection
function Updater.Init()
    if  Connection then return end 
    if IS_CLIENT then 
        RunService.RenderStepped:Connect(function(deltaTime)
            for guid,entity in EntityHolder.getAllEntities() do
               task.spawn(Render.update,entity)
            end
        end)
    end
    Connection = RunService.Stepped:Connect(function(p,deltaTime)
        fixedTick += deltaTime
        for guid,entity in EntityHolder.getAllEntities() do
            task.spawn(Handler.update,entity,deltaTime,fixedTick)
        end
        if fixedTick > FixedTime then
            fixedTick = 0
        end
    end)
end
return Updater