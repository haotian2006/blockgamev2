local RunService = game:GetService("RunService")
local Handler = require(script.Parent)
local Updater = {}
local fixedTick = 0
local FixedTime = 1/20
local IS_CLIENT = RunService:IsClient()
local Render = require(script.Parent.Render)
local EntityHolder = require(script.Parent.EntityHolder)
local Runner = require(game.ReplicatedStorage.Runner)
local Init
function Updater.Init()
    if  Init then return end 
    if IS_CLIENT then 
        RunService.Heartbeat:Connect(function(deltaTime)
            for guid,entity in EntityHolder.getAllEntities() do
                if entity.__destroyed then continue end 
               task.spawn(Render.update,entity)
            end
        end)
    end
    Runner.bindToStepped("Updater",function(p,deltaTime)
        fixedTick += deltaTime
        for guid,entity in EntityHolder.getAllEntities() do
            if entity.__destroyed then continue end 
            task.spawn(Handler.update,entity,deltaTime,fixedTick)
        end
        if fixedTick > FixedTime then
            fixedTick = 0
        end
    end,5)

    Init = true
end
return table.freeze(Updater)