local handler = {}
local EnabledGUi = {

}
local Player = game:GetService("Players").LocalPlayer
local resourceHandler = require(game.ReplicatedStorage.ResourceHandler)

local DefaultIcon = resourceHandler.getUI("IconFrame")


local frames = {}
function handler.getOrCreateFrame(name,isContainer)
    if frames[name] then return frames[name] end 
    if isContainer then 
        frames[name] = resourceHandler.getUiContainer(name):Clone()
    else
        frames[name] = resourceHandler.getUI(name):Clone()
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
function handler.getItemAt(container,Id)
    if not Containers[container] then return end 
    return  Containers[container][tonumber(Id)]
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
    local info = handler.getItemAt(middle, last)
    if not info then
        ItemInfoFrame.Enabled = false
        LastDisplayed = nil
        return
    end
    if info[1] == LastDisplayed then
        return
    end
    local data = resourceHandler.getItem(info[1])
    ItemInfoFrame.Main.DisplayName.Text = data.DisplayName or info[1]
    ItemInfoFrame.Main.RealName.Text =  info[1]
    ItemInfoFrame.Enabled  = true
    LastDisplayed = info[1]
end

local LastFrame
function handler.displayHover(x,y)
    local HoverFrame = handler.getOrCreateFrame("HoverFrame",false)
    local frame = handler.getContainerAt(x, y)
    if not frame then
        HoverFrame.Visible = false
        HoverFrame.Parent = Player.PlayerGui
        LastFrame = nil
        return
    end
    if LastFrame == frame then
        return 
    end
    LastFrame = frame
    HoverFrame.Parent = frame
    HoverFrame.Visible = true
end

local lastHolding
function handler.updateHolding(x,y)
    local holding = handler.getOrCreateFrame("HoldingFrame",true)
    local current = Containers.Holding
    if not current then
        holding.Enabled = false
        lastHolding = nil
        return
    end
    holding.Main.Position = UDim2.new(0,x,0,y+36)
    if lastHolding == current then
        return
    end
    lastHolding = current
    holding.Enabled = true
    handler.renderFrame(holding.Main, current[1], current[2], nil,0)
end

function handler.renderIcon(Icon,item,amount,percentage)
    local data = resourceHandler.getItem(item)
    local icon = getTextureId(data.Icon) or ""
    local DisplayName = data.DisplayName or ""

    local IconDisplay = Icon:FindFirstChild("Icon")     
    local Amount = Icon:FindFirstChild("Amount")     
    local Name = Icon:FindFirstChild("Name")

    if IconDisplay then
        IconDisplay.Image = icon
        Amount.Text = amount
        if not icon then
            Name.Text = DisplayName
        else
            Name.Text = ""
        end
    end
end
function handler.renderFrame(frame:Frame,item,amount,ToUse,percentage)
    local Icon = frame:FindFirstChild("Icon")
    if not Icon then 
        Icon = (ToUse or DefaultIcon):Clone()
        Icon.Parent = frame
    end
    handler.renderIcon(Icon, item, amount, percentage)
end

function handler.update(gui,name)
    local container = resourceHandler.getUiContainer(name)
    if not gui then return end 
    for i,v in gui:GetDescendants() do
        local first, middle, last = v.Name:match("^(.-)%.(.-)%.([^%.]+)$")
        if first ~= "Container" then continue end 
        if Containers[middle] and Containers[middle][tonumber(last)] then
            local data = Containers[middle][tonumber(last)]
            handler.renderFrame(v, data[1], data[2], container[middle], 0)
        end
    end
end
function handler.open(name)
    handler.close(name)
    local container = resourceHandler.getUiContainer(name)
    local gui:ScreenGui = container.Frame:Clone()
    if container.Init then
        container.Init(gui)
    end
    handler.update(gui, name)
    gui.Enabled = true
    gui.Parent = Player.PlayerGui:WaitForChild("Containers")
    EnabledGUi[name] = gui

    local holding = handler.getOrCreateFrame("HoldingFrame",true)
    holding.Parent = script
    holding.Parent = Player.PlayerGui
end

function handler.close(name)
    if not  EnabledGUi[name] then return end 
    EnabledGUi[name]:Destroy()
    EnabledGUi[name] = nil
end
local open = false
game:GetService("UserInputService").InputBegan:Connect(function(a0: InputObject, a1: boolean)  
    if a0.KeyCode == Enum.KeyCode.Q then
        if open then
            handler.open("InventoryFrame")
        else
            handler.close("InventoryFrame")
        end
        open = not open
    end
end)

local rate = 1/20
local total = 0
game:GetService("RunService").RenderStepped:Connect(function(dt: number)  
    total+=dt
    if total < rate then return end 
    local m = Player:GetMouse()
    handler.displayInfo(m.X,m.Y)
    handler.displayHover(m.X,m.Y)
    handler.updateHolding(m.X,m.Y)
end)

function handler.onClick(x,y,isRightClick)
    local UisAt = Player.PlayerGui:GetGuiObjectsAtPosition(x, y)
    for i,frame:Frame in UisAt do
        local first, middle, last = frame.Name:match("^(.-)%.(.-)%.([^%.]+)$")
        if first ~= "Container" then continue end 
        if Containers[middle] then 
            
        end
        break
    end
end
return handler