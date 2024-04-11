local UI = {}

local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Container = require(script.ContainerHandler)
local resourceHandler = require(game.ReplicatedStorage.ResourceHandler)

local PlayerGui = Player:WaitForChild("PlayerGui")
local frames = {}
local EnabledGUi = {}
local InGui = {}
Container.initInGUi(InGui)

function UI.closeAll()
    Container.closeAll()
end

function UI.getOrCreateFrame(name,isContainer)
    if frames[name] then return frames[name] end 
    if isContainer then 
        local uiContainer = resourceHandler.getUiContainer(name)
        if not uiContainer then return end 
        frames[name] = uiContainer.Frame:Clone()
    else
        local uiContainer = resourceHandler.getUI(name):Clone()
        if not uiContainer then return end 
        frames[name] = uiContainer:Clone()
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

local function getModule(frame:Frame)
    local Init = frame:FindFirstChild("MainScript",true)
    if not Init then return end 
    if typeof(Init) == "Instance" and Init:IsA("ModuleScript") then
        return require(Init)
    end
    return 
end

function UI.open(name)
    local gui =  UI.getOrCreateFrame(name)
    if not gui then return end 
    local module = getModule(gui)
    if module and module.open then
        module.open()
    end

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

    local module = getModule(gui)
    if module and module.close then
        module.close()
    end

    EnabledGUi[name] = nil
    
    return gui
end 

return UI