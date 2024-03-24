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
local function InitServer()
    local Simulated = Data.getSimulated()
    local BehaviorHandler = require(game.ServerStorage.core.Entity.EntityBehaviorHandler)
    local tick = 0
    local framesUntilTick = 0
    local SimulatedEntities = {}
    local WhenToRun = {}
    local function updateInfo()
        table.clear(SimulatedEntities)
        table.clear(WhenToRun)
        for chunk in Simulated do
            local C = Data.getChunkFrom(chunk)
            if not C then continue end 
            for i,v in C.Entities do
                table.insert(SimulatedEntities,v)
            end
        end
        local amtPerChunk = math.ceil(#SimulatedEntities/3)
        local idx = 1
        local passes = 0
        local t = {}
        WhenToRun[idx] = t
        for _,v in SimulatedEntities do
            if passes >= amtPerChunk then
                idx +=1
                passes = 0
                t = {}
                WhenToRun[idx] = t
            end
            t[v] = true
            passes+=1
        end
    end
    local deltatime = {

    }
    local function run()
        framesUntilTick+=1
        if framesUntilTick>=3 then
            framesUntilTick = 0
            updateInfo()
        end
        local LastTime = deltatime[framesUntilTick+1] or os.clock()-1/20
        local current = os.clock()
        deltatime[framesUntilTick+1] = current
        local dt  = current-LastTime
      

        for i,v in Players:GetPlayers() do
            local e = Data.getEntityFromPlayer(v)
            if not e then return end 
            Handler.updateChunk(e)
        end
        local torun = WhenToRun[framesUntilTick+1] or {}
        for v in torun do
            debug.profilebegin("Update")
            if torun[v] then
                BehaviorHandler.run(v) 
            end
            debug.profileend()
            Handler.update(v, dt)
        end
    end
    updateInfo()
    Runner.bindToHeartbeat("Updater",function(p,dt)
        Runner.runParallel(run,0,p)
    end,5)
end

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
        InitServer()
    end

    Init = true
end
return table.freeze(Updater)