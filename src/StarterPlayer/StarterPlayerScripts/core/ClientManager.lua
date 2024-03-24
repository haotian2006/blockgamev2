local client = {}

local DataHandler = require(game.ReplicatedStorage.Data)
local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local Controller = require(script.Parent.Parent.Controller)
local UiManager = require(script.Parent.Ui)
local Events = require(game.ReplicatedStorage.Events)

local tweenService = game:GetService("TweenService")

local camera = Controller.getCamera()

local connection
local tween 
local thread 

DataHandler.PlayerEntityChanged:Connect(function(entity)  
    if not entity then return end 
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if tween then
        tween:Stop()
        tween = nil
    end
    if thread then
        task.cancel(thread)
        thread = nil
    end
    UiManager.close("DeathScreen")
    EntityHandler.getPropertyChanged(entity, "model"):Connect(function(a0, a1) 
        if not a0 then return end 
        task.wait(.5)
        camera.pause(true)
        Controller.setCameraTo(entity)
        camera.setMode()

    end)
    connection = EntityHandler.getPropertyChanged(entity, "died"):Connect(function(new,old)
        if not new then return end 
        UiManager.closeAll() 
        connection:Disconnect()
        connection = nil
        camera.setMode("Third")
        camera.Update()
        Controller.setCameraTo(nil)

        camera.pause()
    
        local DeathScreen = UiManager.open("DeathScreen")
        local currentCamera = camera.getBaseCamera()
        local cameraCFrame = currentCamera.CFrame
        thread = task.spawn(function()
            cameraCFrame*=CFrame.new(0,2,5)
            -- tween = tweenService:Create(currentCamera, TweenInfo.new(2), {CFrame = cameraCFrame})
            -- tween:Play()
            -- tween.Completed:Wait()

            thread = nil
            tween = nil
        end)
    end)
end)

function client.SendRespawnEvent()
    Events.RespawnEntity.send()
end

return client