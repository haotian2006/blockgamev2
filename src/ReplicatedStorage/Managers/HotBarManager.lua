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
    local hotbartemp = resourcehandler.GetUI('HotbarTemp')
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
    if PEntity() then 
        PEntity():VisuliseHandItem()
    end
end
function manager.UpdateOne(index)
    if not PEntity() then return nil end 
    local inventory = PEntity().inventory or {}
    local frame = manager.Uis[index]
    local item = inventory.Data[index]
    local amt = 0
    if type(item) =="table" then
        amt = item[2]
        frame.Text = qf.DecompressItemData(item[1],'Type')
    else
        frame.Text = ""
    end
    if amt == 0 or amt == 1 then
        frame.Amount.Text = ""
    else
        frame.Amount.Text = amt
    end
end
function manager.GetUI()
    return player.PlayerGui:WaitForChild("Hud").HotBar
end
function manager.UpdateAll()
    if not PEntity() or not PEntity().inventory then return end 
    for i = 1,9 do
        manager.UpdateOne(i)
    end
    manager.UpdateSelect(PEntity().CurrentSlot or 1)
end
function manager.UpdateSelect(index)
    for i,v in manager.Uis do
        v.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    end
    manager.Visulise(index)
    manager.Uis[index].BackgroundColor3 = Color3.fromRGB(85, 255, 255)
end
return manager