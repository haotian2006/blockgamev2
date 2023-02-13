local manager = {}
local player = game.Players.LocalPlayer
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local runservice = game:GetService("RunService")
local dataHandler = require(game.ReplicatedStorage.DataHandler)
manager.Uis = {}
if runservice:IsServer() then return {} end 
local PEntity = dataHandler.GetLocalPlayer
function manager:Init()
    local hotbargui = player.PlayerGui:WaitForChild("Hud").HotBar
    local hotbartemp = resourcehandler.Ui.HotBarTemp
    for i,v in manager.Uis do
        v:Destroy()
    end
    manager.Uis = {}
    if not hotbartemp then return end
    for i = 1,9 do
        local c = hotbartemp:clone()
        c.Name = i
        c.Parent = hotbargui
        manager.Uis[i] = c
        c.MouseButton1Click:Connect(function() manager.UpdateSelect(i)end)
    end
    manager.UpdateSelect(1)
    manager.UpdateAll()
end
function manager.Visulise(index)
    local inventory = PEntity().inventory or {}
    local item = inventory[index]
    local attachment = nil
end
function manager.UpdateOne(index)
    local inventory = PEntity().inventory or {}
    local frame = manager.Uis[index]
    local item = inventory[index]
    local amt = 0
    if type(item) =="table" then
        amt = item[2]
        frame.Text = item[1]
    else
        frame.Text = ""
    end
    if amt == 0 then
        frame.Amount.Text = ""
    else
        frame.Amount.Text = amt
    end
end
function manager.UpdateAll()
    for i = 1,9 do
        manager.UpdateOne(i)
    end
end
function manager.UpdateSelect(index)
    for i,v in manager.Uis do
        v.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    end
    manager.Uis[index].BackgroundColor3 = Color3.fromRGB(85, 255, 255)
end
return manager