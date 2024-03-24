local UI = {}

local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Container = require(script.ContainerHandler)
local resourceHandler = require(game.ReplicatedStorage.ResourceHandler)

local PlayerGui = Player:WaitForChild("PlayerGui")
local frames = {}
local EnabledGUi = {}

function UI.closeAll()
    Container.closeAll()
end

function UI.getOrCreateFrame(name,isContainer)
    if frames[name] then return frames[name] end 
    if isContainer then 
        local uiContainter = resourceHandler.getUiContainer(name)
        if not uiContainter then return end 
        frames[name] = uiContainter.Frame:Clone()
    else
        local uiContainter = resourceHandler.getUI(name):Clone()
        if not uiContainter then return end 
        frames[name] = uiContainter:Clone()
    end
    if not frames[name] then return end 
    frames[name].Parent =  Player.PlayerGui
    frames[name].AncestryChanged:Connect(function()
        if frames[name].Parent == nil then
            frames[name] = nil
        end
    end)
    return frames[name]
end

function UI.open(name)
    local gui =  UI.getOrCreateFrame(name)
    if not gui then return end 
    --TODO: Fire open function

    gui.Enabled = true
    gui.Parent = PlayerGui

    EnabledGUi[name] = gui

    return gui
end 

function UI.close(name)
    if not EnabledGUi[name] then return end 
    --TODO: Fire open function
    local gui = EnabledGUi[name]
    gui.Enabled = false
    gui.Parent = PlayerGui

    EnabledGUi[name] = nil
    
    return gui
end 

return UI