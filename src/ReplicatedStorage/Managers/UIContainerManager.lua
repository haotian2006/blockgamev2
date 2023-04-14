local c = {}
local player = game.Players.LocalPlayer
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local runservice = game:GetService("RunService")
local dataHandler = require(game.ReplicatedStorage.DataHandler)
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local UpdateHolding = bridge.CreateBridge('UpdateHoldingItem')
c.OnGuiClick = Instance.new('BindableEvent',script)
local PEntity = dataHandler.GetLocalPlayer
local mouse = player and player:GetMouse()
local UserInput = game:GetService('UserInputService')
c.Uis = {}
UpdateHolding:Connect(function(player,index,amt)
    if runservice:IsClient() then return end 
    local plr = dataHandler.GetEntityFromPlayer(player)
    local pinv = plr.inventory
    if plr and pinv then
        plr.Container = plr.Container or {}
        if plr.Container.HoldingItem and index then
            local name,amount = plr.Container.HoldingItem[1],plr.Container.HoldingItem[2]
            if amt and name ~= plr.inventory[index][1] and plr.inventory[index] ~= '' then return end 
            if not amt then amt = amount end 
            local item,left = pinv:setAt(index,name,amt <=amount and amt or amount)
            if amt <=amount and item == name and amount-amt ~= 0 then
                left  = amount-amt
            end
            if left == 0 then
            plr.Container.HoldingItem = nil
            else
              plr.Container.HoldingItem = {item,left}
           
           end
        elseif pinv[index] ~= '' and index then
            local name,amount = pinv[index][1],pinv[index][2]
            if amt and amount > 1 then
                amount = math.round(amount/2)
                pinv[index][2] -= amount
            else
                pinv[index]= ''
            end
            plr.Container.HoldingItem = {name,amount}
        elseif not index and plr.Container.HoldingItem and plr.Container.HoldingItem[1] then
            pinv:add(plr.Container.HoldingItem[1],plr.Container.HoldingItem[2])
            plr.Container.HoldingItem = nil
        end
    end
end)
c.GetUI = function(name)
    if resourcehandler.GetUiContainer(name) and not c.Uis[name] then
        local a =resourcehandler.GetUiContainer(name):Clone()
        a.Parent = player.PlayerGui
        a.IgnoreGuiInset = true
        a.Enabled = false
        c.Uis[name] = a
    end
    return c.Uis[name]
end
if runservice:IsClient() then  
c.ResetUis = function()
    for i,v in c.Uis do

    
        c.disableUis(i)
    end
end
c.HoverFrame = nil
function c.HandlerClick(x,y,isright)
    local notsaved = PEntity().NotSaved
    local inv = PEntity().inventory
    local ui = player.PlayerGui:GetGuiObjectsAtPosition(x,y)
    local clickui = nil
    local index = nil
    local amt = nil
    for i,v:string in ui do
        local s = v.Name:split('.')
        if s[1] == 'Container' and s[2] == 'Inventory' then
            clickui = v
            index = tonumber(s[3])
            break
        end
    end
    if isright then
        amt = 1
    end
    if clickui and index then
        UpdateHolding:Fire(index,amt)
    end
end
UserInput.InputBegan:Connect(function(key)
    if not PEntity() or not PEntity().Ingui or not PEntity().inventory then return end 
    if key.UserInputType == Enum.UserInputType.MouseButton1 then
        c.HandlerClick(mouse.X,mouse.Y)
    elseif key.UserInputType == Enum.UserInputType.MouseButton2 then
        c.HandlerClick(mouse.X,mouse.Y,true)
    end
end)
runservice.Heartbeat:Connect(function(deltaTime)
    if not c.HoverFrame and resourcehandler.GetUI('HoverFrame') then 
    c.HoverFrame = resourcehandler.GetUI('HoverFrame'):Clone() 
    c.HoverFrame.Destroying:Connect(function()
        c.HoverFrame = nil
    end)
end 
    if not PEntity() or PEntity():GetState('Dead') then
        c.ResetUis()
        return
    end
    if PEntity() and PEntity().Ingui and c.HoverFrame then
        if c.Uis['HoldingFrame'] and c.Uis['HoldingFrame']['Holding'] then
        c.Uis['HoldingFrame'].Holding.Position = UDim2.new(0,mouse.X-2,0,mouse.Y+36)
        c.Uis['HoldingFrame'].Enabled = true
        local holding = c.Uis['HoldingFrame'].Holding
        local inframe = holding:FindFirstChild('IconTemp') or resourcehandler.GetUI('IconTemp') and resourcehandler.GetUI('IconTemp'):clone()
        if  inframe then
            inframe.Parent = holding
            local amt = 0
            PEntity().Container = PEntity().Container or {}
            local item = PEntity().Container.HoldingItem 
            if type(item) =="table" then
                amt = item[2]
                inframe.name.Text = qf.DecompressItemData(item[1],'T')
            else
                inframe.name.Text = ""
            end
            if amt == 0 or amt == 1 then
                inframe.Amount.Text = ""
            else
                inframe.Amount.Text = amt
            end
        end 
        end
        local ui = player.PlayerGui:GetGuiObjectsAtPosition(mouse.X,mouse.Y)
        for i,v:string in ui do
            local s = v.Name:split('.')
            if s[1] == 'Container' then
                if c.HoverFrame.Parent ~= v then
                    c.HoverFrame.Parent = v
                end
                return
            end
         end
         if c.HoverFrame and c.HoverFrame.Parent ~= script then
            c.HoverFrame.Parent = script
         end
    elseif c.HoverFrame and not c.HoverFrame.Parent == script then
        c.Uis['HoldingFrame'].Enabled = false
        c.HoverFrame.Parent = script
        if PEntity().Container.HoldingItem then
            UpdateHolding:Fire(nil)
        end
    elseif PEntity() and not PEntity().Ingui then
        if c.Uis['HoldingFrame'] then
            c.Uis['HoldingFrame'].Enabled = false
        end
        if PEntity().Container and PEntity().Container.HoldingItem then
            UpdateHolding:Fire(nil)
        end
    end
end)
c.enableUis = function(name)
    if c.GetUI(name) then
        c.GetUI('HoldingFrame')
        PEntity().Ingui = true
        c.GetUI(name).Enabled = true
        c.Uis['HoldingFrame'].Parent = script
        task.wait()
        c.Uis['HoldingFrame'].Parent = player.PlayerGui
    end
end
c.disableUis = function(name)
    if c.Uis[name] then
        if PEntity() then
        PEntity().Ingui = false
        end
        c.Uis[name].Enabled= false
    end
end
end
return c