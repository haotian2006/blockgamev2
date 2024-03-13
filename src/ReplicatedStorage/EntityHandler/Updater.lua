local RunService = game:GetService("RunService")
local Handler = require(script.Parent)
local Updater = {}
local fixedTick = 0
local FixedTime = 1/20
local IS_CLIENT = RunService:IsClient()
local Render = require(script.Parent.Render)
local EntityHolder = require(script.Parent.EntityHolder)
local Runner = require(game.ReplicatedStorage.Runner)
local Data = require(game.ReplicatedStorage.Data)
local Players = game:GetService("Players")


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
        Runner.bindToStepped("Updater",function(p,deltaTime)
            for guid,entity in EntityHolder.getAllEntities() do
                if entity.__destroyed then continue end 
               Handler.update(entity,deltaTime)
            end
        end,5)
    else
        local Simulated = Data.getSimulated()
        local BehaviorHandler = require(game.ServerStorage.core.Entity.EntityBehaviorHandler)
        Runner.bindToStepped("Updater",function(p,deltaTime)
            for i,v in Players:GetPlayers() do
                local e = Data.getEntityFromPlayer(v)
                if not e then return end 
                Handler.updateChunk(e)
            end
           for chunk in Simulated do
            local C = Data.getChunkFrom(chunk)
            if not C then continue end 
            for i,v in C.Entities do
                BehaviorHandler.run(v)
                Handler.update(v, deltaTime)
            end
           end
        end,5)
    end

    Init = true
end
return table.freeze(Updater)