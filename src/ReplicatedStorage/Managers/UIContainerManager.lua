local c = {}
local player = game.Players.LocalPlayer
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local runservice = game:GetService("RunService")
local dataHandler = require(game.ReplicatedStorage.DataHandler)
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local manager = require(game.ReplicatedStorage.Managers)
local UpdateHolding = bridge.CreateBridge('UpdateHoldingItem')
local CreateContainer = bridge.CreateBridge('CreateContainer')
local DropItem = bridge.CreateBridge('DropItem')
c.OnGuiClick = Instance.new('BindableEvent',script)
local PEntity = dataHandler.GetLocalPlayer
local mouse = player and player:GetMouse()
local UserInput = game:GetService('UserInputService')
local GetIconTemp =  function () return resourcehandler.GetUI('IconTemp') end 
c.Uis = {}
local craftingmanager = manager.CraftingManager
CreateContainer:Connect(function(plr,type,amt)
    if runservice:IsClient() then return end 
    local plr = dataHandler.GetEntityFromPlayer(plr)
    local entityatt = require(game.ServerStorage.EntityAttributesCreator).Find(type)
    if not plr or not entityatt then return end 
    plr.Container = plr.Container or {}
    plr.Container[type] = entityatt.new(amt)
end)
function c.DropItem(plr,index,amt)
    if typeof(plr) == "Instance" then
        plr = dataHandler.GetEntityFromPlayer(plr)
    end
    if not index then return end 
    local path,lasti = plr,nil
    local split = index:split('.')
    for i,v in split do
        if i == #split then lasti = v
        else
            if path[v] == nil then return end 
            path =path[v]
        end
    end
    if path[lasti] ~= "" and path[lasti] and path[lasti][2] then
        local max = math.min(path[lasti][2],amt or 999999)
        plr:DropItem(path[lasti][1],max)
        if path[lasti][2] - max == 0 then
            path[lasti] = ""
        else
            path[lasti][2] -= max
        end
    end
end
function c.OnCloseGui(player,index,amt)
    if runservice:IsClient() then return end 
    local plr 
    if typeof(player) == "Instance" then
        plr = dataHandler.GetEntityFromPlayer(player)
    else
        plr = player
    end
    if not plr or plr:GetState('Dead')  then    return end 
    local pinv = plr.inventory
    if plr and pinv then
        local typec = type(index) == 'table' and index[1] or 'inventory'
        index = type(index) == 'table' and index[2] or index
        typec =typec:lower()
        plr.Container = plr.Container or {}
        local continerobj = plr[typec] or plr.Container[typec]
        if plr.Container.HoldingItem and plr.Container.HoldingItem ~= "" and index and continerobj then
            if continerobj.HandleClickOnIndex and continerobj:HandleClickOnIndex(index,amt,plr.Container) then return end 
            local name,amount = plr.Container.HoldingItem[1],plr.Container.HoldingItem[2]
            if amt and name ~= continerobj[index][1] and continerobj[index] ~= '' then return end 
            if not amount then amount= 0 end 
            if not amt then amt = amount end 
            local item,left,notchanged = continerobj:setAt(index,name,amt <=amount and amt or amount)
            if amt <=amount and item == name and amount-amt ~= 0  then
                left  = amount-amt
                if notchanged then
                    left = amount
                end
            end
            if left == 0 then
            plr.Container.HoldingItem = ""
            else
              plr.Container.HoldingItem = {item,left}
           
           end
        elseif continerobj[index] ~= '' and index then
            if continerobj.HandleClickOnIndex and continerobj:HandleClickOnIndex(index,amt,plr.Container) then

            else

                if not continerobj[index] then return end 
                local name,amount = continerobj[index][1],continerobj[index][2]
                if amt and amount > 1 then
                    amount = math.round(amount/2)
                    continerobj[index][2] -= amount
                else
                    continerobj[index]= ''
                end
                plr.Container.HoldingItem = {name,amount}
            end
        elseif continerobj[index] ~= '' then
            for i,v in plr.Container or {} do
              --  print(i)
                if type(v) == "table" and v.Type == "EntityAttribute" then
                  --  print(i)
                    for z,y in v do
                        if z ~= "Output" then
                            pinv:add(y[1],y[2])
                        end
                        plr.Container[i][z] = ""
                    end
                elseif type(v) == "table" then
                    pinv:add(v[1],v[2])
                    plr.Container[i] = ""
                else
                end
            end

        end
        
    end
end
DropItem:Connect(c.DropItem)
UpdateHolding:Connect(c.OnCloseGui)
c.CreateContainer = function(type,amt)
    CreateContainer:Fire(type,amt)
end
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
    local foundmain
    for i,v:string in ui do
        local s = v.Name:split('.')
        if s[1] == 'Container' and not index then
            clickui = v
            index = {s[2],tonumber(s[3]) or s[3]}
        end
        if v.Name == "Main" then
            foundmain = true
        end
    end
    if not foundmain then
        DropItem:Fire("Container.HoldingItem")
        return 
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
           c.UpdateOne(holding,item)
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
function c.UpdateOne(frame,item)
    if not PEntity() or not PEntity().inventory then return nil end 
    local inventory = PEntity().inventory or {}
    if not frame then return end
    local amt = 0
    local inframe = frame:FindFirstChild('IconTemp') or GetIconTemp() and GetIconTemp():clone()
    if not inframe then return end 
    inframe.Parent = frame
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
c.enableUis = function(name)
    if c.GetUI(name) then
        c.CreateContainer('crafting',4)
        c.GetUI('HoldingFrame')
        PEntity().Ingui = name
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
        UpdateHolding:Fire()
    end
end
end
return c