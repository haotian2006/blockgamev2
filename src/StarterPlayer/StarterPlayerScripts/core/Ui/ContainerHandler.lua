--!nocheck
local handler = {}
local EnabledGUi = {

}

local OpenedGUi = {}

local Rendered = 0

local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")

local resourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local ItemHandler = require(game.ReplicatedStorage.Item)
local ContinerClass = require(game.ReplicatedStorage.Container)
local Signal = require(game.ReplicatedStorage.Libarys.Signal)
local Data = require(game.ReplicatedStorage.Data)

local Events = game:GetService("ReplicatedStorage").Events.Container
local Send:RemoteEvent = Events.Send

local ClientContainer = {}

local DEFAULTICON = resourceHandler.getUI("IconFrame")

local frames = {}

local getItemAt = function(name,item)
    
end

local function getFrameInfo(name)
    local first, middle,id = name:match("^(.-)%.(.-)%.([^%.]+)$")
    if not first then return end 
    return middle,tonumber(id)
end

function handler.init(c)
    ClientContainer = c
    getItemAt = ClientContainer.getItemAt
end

function handler.getOrCreateFrame(name,isContainer)
    if frames[name] then return frames[name] end 
    if isContainer then 
        local F = resourceHandler.getUiContainer(name)
        if not F then return end 
        frames[name] = F.Frame:Clone()
    else
        local F = resourceHandler.getUI(name):Clone()
        if not F then return end 
        frames[name] = F:Clone()
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
 

local Containers = {
    Crafting = {
        {"c:GrassBlock",2}
    },
    Holding =  {"c:GrassBlock",2}
}
local function getTextureId(c)
    if typeof(c) == "Instance" then 
        if c:IsA("Texture") or c:IsA("Decal") then
            return c.Texture
        end
    end
    return c
end

local function getFrameParentAndData(frame:Frame)
    local screenGui = frame:FindFirstAncestorWhichIsA("ScreenGui")
    if not screenGui then return end 
    local data = resourceHandler.getUiContainer(screenGui.Name)
    return screenGui.Name,data
end

function handler.openContainer()
    
end

function handler.closeContainer()
    
end

function handler.getContainerAt(x,y)
    local UisAt = Player.PlayerGui:GetGuiObjectsAtPosition(x, y)
    for i,frame:Frame in UisAt do
        local first, middle, last = frame.Name:match("^(.-)%.(.-)%.([^%.]+)$")
        if first ~= "Container" then continue end 
        return frame,middle,last
    end
    return 
end



local LastDisplayed
function handler.displayInfo(x,y)
    local ItemInfoFrame = handler.getOrCreateFrame("ItemInfoFrame",false)
    ItemInfoFrame.Main.Position = UDim2.new(0,x+handler.getOrCreateFrame("HoldingFrame",true).Main.AbsoluteSize.X,0,y+30)
    local frame,middle,last = handler.getContainerAt(x, y)
    if not frame then
        ItemInfoFrame.Enabled = false
        LastDisplayed = nil
        return
    end
    local _,FData = getFrameParentAndData(frame)
    if FData and FData.CanHover == false then return end 
    local info = getItemAt(middle, last)
    if not info or info == "" then
        ItemInfoFrame.Enabled = false
        LastDisplayed = nil
        return
    end
    if info[1] == LastDisplayed then
        return
    end
    local data = ItemHandler.getItemInfoR(info[1])
    ItemInfoFrame.Main.DisplayName.Text = data.DisplayName 
    ItemInfoFrame.Main.RealName.Text =  data.Name
    ItemInfoFrame.Enabled  = true
    LastDisplayed = info[1]
end

local LastFrame
function handler.displayHover(x,y,override)
    local HoverFrame = handler.getOrCreateFrame("HoverFrame",false)
    local frame = handler.getContainerAt(x, y)
    if not frame then
        HoverFrame.Visible = false
        HoverFrame.Parent = Player.PlayerGui
        LastFrame = nil
        return
    end

    local _,FData = getFrameParentAndData(frame)
    if FData and FData.CanHover == false then return end 

    if LastFrame == frame and not override then
        return 
    end
    LastFrame = frame
    HoverFrame.Parent = frame
    HoverFrame.Visible = true
end

local lastHolding
function handler.updateHolding(x,y,override)
    local holding = handler.getOrCreateFrame("HoldingFrame",true)
    local current = ClientContainer.getHolding()
    if not current then
        holding.Enabled = false
        lastHolding = nil
        return
    end

    holding.Main.Position = UDim2.new(0,x,0,y+36)

    if lastHolding == current and not override then
        return
    end
    lastHolding = current
    if not current or current =="" then
        handler.clearFrame(holding.Main)
        holding.Enabled = false
        return
    end
    holding.Enabled = true
    handler.renderFrame(holding.Main, current[1], current[2], nil,0)
end

function handler.renderIcon(Icon,item,amount,percentage)
    local data = ItemHandler.getItemInfoR(item)
    local icon = data.Icon
    local DisplayName = data.DisplayName

    local IconDisplay = Icon:FindFirstChild("Icon")     
    local Amount = Icon:FindFirstChild("Amount")     
    local Name = Icon:FindFirstChild("Name")
    Icon.Visible = true
    if IconDisplay then
        Amount.Text = amount
        if not icon then
            Name.Text = DisplayName
            IconDisplay.Image = ""
        else
            Name.Text = ""
            IconDisplay.Image = icon
        end
    end
end

function handler.clearIcon(Icon:Frame) 
    Icon.Visible = false
end

function handler.renderFrame(frame:Frame,item,amount,ToUse,percentage)
    local Icon = frame:FindFirstChild("Icon")
    if not Icon then 
        Icon = (ToUse or DEFAULTICON):Clone()
        Icon.Name = "Icon"
        Icon.Parent = frame
    end
    handler.renderIcon(Icon, item, amount, percentage)
end

function handler.clearFrame(frame:Frame)
    local Icon = frame:FindFirstChild("Icon")
    if not Icon then return end 
    handler.clearIcon(Icon)
end

function handler.update(gui,name)
    local container = resourceHandler.getUiContainer(name)
    if not gui then return end 
    for i,v in gui:GetDescendants() do -- Cache this in the future
        local first, middle, last = v.Name:match("^(.-)%.(.-)%.([^%.]+)$")
        if first ~= "Container" then continue end 
        local data = getItemAt(middle, last)
        if not data or data == "" then 
            handler.clearFrame(v)
            continue 
        end 
        handler.renderFrame(v, data[1], data[2], container[middle], 0)
    end
end

function handler.updateAll()
    local m = Player:GetMouse()
    local x,y = m.X, m.Y
    for name,gui in EnabledGUi do
        handler.update(gui, name)
    end
    handler.updateHolding(x,y, true)
    handler.displayHover(x,y,true)
end

handler.OnOpen = Signal.new()
handler.OnClose = Signal.new()

function handler.open(name)
    handler.close(name,true,true)
    local container = resourceHandler.getUiContainer(name)
    local gui:ScreenGui = container.Frame:Clone()
    if container.Init then
        container.Init(gui,ClientContainer.getAllContainers())
    end
    handler.OnOpen:Fire(name)
    handler.update(gui, name)

    gui.Enabled = true
    gui.Parent = Player.PlayerGui:WaitForChild("Containers")

    EnabledGUi[name] = gui

    if not container.AlwaysOpen then
        table.insert(OpenedGUi,name)
    end

    local holding = handler.getOrCreateFrame("HoldingFrame",true)
    holding.Parent = script
    holding.Parent = Player.PlayerGui

    return gui

end 

function handler.close(name,forceClose,fromOpen)
    if not  EnabledGUi[name] then return end 
    local container = resourceHandler.getUiContainer(name)
    if container.OnClose then
        container.OnClose( EnabledGUi[name])
    end
    handler.OnClose:Fire(name)
    if not container.AlwaysOpen or forceClose then
        EnabledGUi[name]:Destroy()
        EnabledGUi[name] = nil

        local Index = table.find(OpenedGUi, name)
        if Index then 
            table.remove(OpenedGUi,Index)
        end
        if #OpenedGUi == 0 and not fromOpen then
            Send:FireServer(3)
        end
    end
end

local open = false
game:GetService("UserInputService").InputBegan:Connect(function(a0: InputObject, a1: boolean)  
    if a0.KeyCode == Enum.KeyCode.E then
        if open then
            handler.open("InventoryFrame")
        else
            handler.close("InventoryFrame")
        end
        open = not open
    end
end)

function handler.processLeft(frame,mainFound)
    if not frame then return end 
    local container,idx = getFrameInfo(frame.Name)
    local click = ClientContainer.getContainer(container)
    local Holding = ClientContainer.getContainer("Holding")

    Send:FireServer(1,ClientContainer.getPath(Holding),ClientContainer.getPath(click),1,idx)

    --ContinerClass.swap(Holding, click, 1, idx, true)
end

function handler.processRight(frame,mainFound)
    if not frame then return end 
    local container,idx = getFrameInfo(frame.Name)
    local click = ClientContainer.getContainer(container)
   
    Send:FireServer(2,ClientContainer.getPath(click),idx)
end

local Debounce = 1/20
local timeC = time()
function handler.onClick(x,y,isRightClick)
    if time() - timeC < Debounce then
        return
    end
    timeC = time()
    local all = ClientContainer.getAllContainers()
    local UisAt = Player.PlayerGui:GetGuiObjectsAtPosition(x, y)
    local mainFound = false
    local ContainerFound = false
    for i,frame:Frame in UisAt do
        if ContainerFound and mainFound then
            break
        end
        if not mainFound and frame.Name == "BoundingBox" then
            mainFound = true
            continue
        end
        if ContainerFound then continue end 
        local first, middle = frame.Name:match("^(.-)%.(.-)%.([^%.]+)$")
        if first ~= "Container" or not all[middle]  then continue end 
        ContainerFound = frame
    end

    if ContainerFound then
        local _,sData = getFrameParentAndData(ContainerFound)
        if sData and sData.CanClick == false then return end 
    end

    if isRightClick then
        handler.processRight(ContainerFound,mainFound)
    else
        handler.processLeft(ContainerFound,mainFound)
    end
    --if not ContainerFound then return end 
end

UserInputService.InputBegan:Connect(function(keyCode: InputObject, a1: boolean) 
    local p = keyCode.Position
    if keyCode.UserInputType == Enum.UserInputType.MouseButton1 then
        handler.onClick(p.X,p.Y,false)
    elseif keyCode.UserInputType == Enum.UserInputType.MouseButton2 then
        handler.onClick(p.X,p.Y,true)
    end
end)

local rate = 1/20
local total = 0

game:GetService("RunService").RenderStepped:Connect(function(dt: number)  
    total+=dt
    if total < rate then
        total = 0 
        return 
    end 
    local m = Player:GetMouse()
    local x,y = m.X,m.Y
    handler.displayInfo(x,y)
    handler.displayHover(x,y)
    handler.updateHolding(x,y)
end)


return handler