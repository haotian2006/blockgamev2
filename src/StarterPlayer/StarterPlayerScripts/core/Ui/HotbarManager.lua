local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local ContainerHandler = require(script.Parent.ContainerHandler)
local Client = require(game.ReplicatedStorage.Handler.EntityHandler.EntityReplicator.Client)
local Render = require(game.ReplicatedStorage.Handler.EntityHandler.Render)
local Data = require(game.ReplicatedStorage.Data)
local EntityHandler = require(game.ReplicatedStorage.Handler.EntityHandler)
local InputHandler = require(script.Parent.Parent.Parent:WaitForChild("InputHandler"))
local ClientContainer



local GetLocalPlayer = Data.getPlayerEntity

local SlotRemote:RemoteEvent = game.ReplicatedStorage.Events.SwapSlot

local Hotbar = {}

local Player = game:GetService("Players").LocalPlayer

local HotBarGUI:ScreenGui
local HotBarSelect:Frame

function Hotbar.setContainer(c)
    ClientContainer = c
    c.ContainerUpdated:Connect(Hotbar.UpdateSlot)
end

function Hotbar.UpdateRender(Entity)
    if not Entity then return end 
    Render.renderHolding(Entity)
end

local lastEntity 
local lastSlot = 1
function Hotbar.UpdateSlot(slot)
    slot = slot or lastSlot
    lastSlot = slot 
    SlotRemote:FireServer(slot)

    local Entity = GetLocalPlayer()
    if not Entity then return end 
    if Entity ~= lastEntity then
        lastEntity = Entity
        local _,s = EntityHandler.getSlot(Entity)
        slot = s or slot
        lastSlot = slot 
    end
    local Inventory = ClientContainer.get("Inventory")
    if not Entity or not Inventory then return end
    local Item = Inventory[slot+1]
    EntityHandler.hold(Entity,type(Item) == "table" and Item[1] or "")
    Hotbar.UpdateRender(Entity)
    if HotBarSelect then
        local Frame = HotBarGUI:FindFirstChild(`Container.Inventory.{slot}`,true)
        if not Frame then return end 
        HotBarSelect.Parent = Frame
        HotBarSelect.Visible = true
    end
end
Data.PlayerEntityChanged:Connect(function()
    
    task.delay(.5,function()
        Hotbar.UpdateSlot()
        ContainerHandler.updateAll()
    end)
    task.delay(.5,function()
        -- Hotbar.UpdateSlot(3)
        -- Hotbar.UpdateSlot(1)
    end)
end)

InputHandler.getOrCreateEventTo("HotBarUpdate"):Connect(function(input,isDown,isTyping,keys)
    if isTyping or not isDown then return end 
    local slot = keys[1] or ""
    local Value = slot:match("%d+")
    if not Value then return end 

    Hotbar.UpdateSlot(tonumber(Value))
end)

InputHandler.bindFunctionTo("HotBarScroll",function(input,isDown,isTyping,keys) 
    if isTyping or not isDown then return end 
    local isUp = input.Position.Z < 0
    local slot = lastSlot
    if isUp then
        slot +=1 
        if slot >= 10 then
            slot = 1
        end
    else
        slot -=1 
        if slot <= 0 then
            slot = 9
        end
    end
    Hotbar.UpdateSlot(slot)
end,"HotBarUpdateWheel",200)




Client.getUpdateEvent("Holding"):Connect(Hotbar.UpdateRender)

function Hotbar.Init() 
    HotBarGUI = ContainerHandler.open("Hotbar",true)
    HotBarSelect = ResourceHandler.getUI("HotbarSelect")
    if not HotBarGUI then return end 
    if HotBarSelect then
        HotBarSelect.Visible = false
        HotBarSelect.Parent = HotBarGUI
    end
    local HotbarTemp = ResourceHandler.getUI("HotbarIconFrame")
    if not HotbarTemp then return end 
    local ClonedLocation = HotBarGUI:FindFirstChild("ClonedLocation",true)
    if not ClonedLocation then return end 
    for i=1,9 do
        local Cloned:GuiButton = HotbarTemp:Clone()
        Cloned.Name = `Container.Inventory.{i}`
        Cloned.Parent = ClonedLocation
        if not Cloned:IsA("GuiButton") then continue end 

        Cloned.Activated:Connect(function()
            Hotbar.UpdateSlot(i)
        end)
    end
    ContainerHandler.update(HotBarGUI, "Hotbar")
end

ContainerHandler.OnOpen:Connect(function(name)
    if name == "Hotbar" or not HotBarGUI then return end 
    HotBarGUI.Enabled = false
end)

ContainerHandler.OnClose:Connect(function(name)
    if name == "Hotbar"or not HotBarGUI then return end 
    HotBarGUI.Enabled = true
end)

return Hotbar