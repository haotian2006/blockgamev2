local hud = {}

local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local HudScreen = PlayerGui:WaitForChild("Hud")

local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local DataHandler = require(game.ReplicatedStorage.Data)

local Frames = {}

local function initFrame(Name,frame)
    local f  = ResourceHandler.getUI(frame)
    if f then
        f = f:Clone()
        f.Parent = HudScreen
    end
    Frames[Name] = f
    return f
end

function hud.update()
    for i,v:Frame in Frames do
        local Update = v:FindFirstChild("MainScript",true)
        if not Update or not Update:IsA("ModuleScript") then
            continue
        end
        local data = require(Update)
        if type(data) ~= "table" then return end 
        if type(data.update) == "function"  then
            data.update()
        end
    end
end

function hud.Init()
    initFrame("Health","HealthFrame")

    hud.update()
    DataHandler.PlayerEntityChanged:Connect(hud.update)
end

return hud