local manager = {}
local player = game.Players.LocalPlayer
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local runservice = game:GetService("RunService")
local dataHandler = require(game.ReplicatedStorage.DataHandler)
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local inventorybrige = bridge.CreateBridge('Inventory')
local Manager = require(script.Parent)
manager.Uis = {}
if runservice:IsClient() then   
local PEntity = dataHandler.GetLocalPlayer
local GetIconTemp =  function () return resourcehandler.GetUI('IconTemp') end 
function manager.getFrame()
    return resourcehandler.GetUI("InventoryFrame")
end
manager.Frame = nil
manager.LastInventory = nil
manager.Doll = nil
manager.iframes = {}
manager.OtherFrames = {}
function manager.UpdateHotbarF()
    local inv = PEntity().inventory.Data
    local HBFrame = manager.Frame:FindFirstChild('HotBar',true)
    local IF = qf.FindFirstChild(manager.Frame,'Assests','ItemFrame')
    if not IF or not HBFrame then return end 
    for i = 1 , 9 do
        local f = manager.iframes[i] or manager.Frame:FindFirstChild('Container.Inventory.'..i,true)
        if inv[i] and not f   then
            f = IF:clone()
            f.Name = 'Container.Inventory.'..i
            f.Visible = true
            f.Parent = HBFrame
        elseif not inv[i] and f then
            f:Destroy()
            f = nil
        end
        manager.iframes[i] = f
    end
end
function manager.UpdateOne(index)
    if not PEntity() or not PEntity().inventory then return nil end 
    local inventory = PEntity().inventory or {Data = {}}
    local frame = manager.iframes[index]
    if not frame then return end
    local item = inventory[index]
    Manager.UIContainerManager.UpdateOne(frame,item)
    -- if type(item) =="table" then
    --     amt = item[2]
    --     inframe.name.Text = qf.DecompressItemData(item[1],'T')
    -- else
    --     inframe.name.Text = ""
    -- end
    -- if amt == 0 or amt == 1 then
    --     inframe.Amount.Text = ""
    -- else
    --     inframe.Amount.Text = amt
    -- end 
end
function manager.UpdateIcons()
    local changes = false
    for i,v in PEntity().inventory.Data do
        if not qf.CompareTables(v,manager.LastInventory and manager.LastInventory[i]) then
            manager.UpdateOne(i)
            changes = true
        end
    end
    return changes
end
function manager.UpdateInventoryF()
    local inv = PEntity().inventory.Data
    local IVFrame = manager.Frame:FindFirstChild('Inventory',true)
    local IF =  qf.FindFirstChild(manager.Frame,'Assests','ItemFrame') or resourcehandler.GetUI("ItemFrame")
    if not IF or not IVFrame then return end 
    for i = 10 , #inv do
        local f = manager.iframes[i] or manager.Frame:FindFirstChild('Container.Inventory.'..i,true)
        if inv[i] and not f   then
            f = IF:clone()
            f.Name = 'Container.Inventory.'..i
            f.Visible = true
            f.Parent = IVFrame
        elseif not inv[i] and f then
            f:Destroy()
            f = nil
        end
        manager.iframes[i] = f
    end
end
runservice.Heartbeat:Connect(function(deltaTime)
    if manager.Frame and manager.Frame.Enabled then
        manager.UpdateFrame()
    end
end)
function manager.Enable(value)
    if not value then
        Manager.UIContainerManager.disableUis('InventoryFrame')
    else
        Manager.UIContainerManager.enableUis('InventoryFrame')
        manager.UpdateFrame()
    end
end
function manager.UpdateFrame()
    if PEntity().inventory then
        local c = false
        if not manager.LastInventory or manager.LastInventory:GetReallen() ~= PEntity().inventory:GetReallen() then
            manager.UpdateHotbarF()
            manager.UpdateInventoryF()
            c = true
        end
        if  manager.UpdateIcons() or c then
            manager.LastInventory = PEntity().inventory:Clone()
        end
    end
    for c,v in  manager.OtherFrames do
        for id, frame in v do
            if PEntity().Container and PEntity().Container[c] then
                local c = PEntity().Container[c] or {}
                -- if frame.Name == "Container.Crafting.Output" then 
                --     print(c,c[id],id)
                -- end
                Manager.UIContainerManager.UpdateOne(frame,c[id] or "")
            end
        end
    end
end
function manager:Init()
    manager.Frame = Manager.UIContainerManager.GetUI('InventoryFrame')
    manager.Frame.Enabled = false
    for i,v in manager.Frame:GetDescendants()do
        local i = v.Name
        local splitted =i:split('.')
        if splitted[1] == "Container" and splitted[2] and splitted[2]:lower() ~= "inventory" and splitted[3] then
            splitted[2] = splitted[2]:lower()
            manager.OtherFrames[splitted[2]] = manager.OtherFrames[splitted[2]] or {}
            manager.OtherFrames[splitted[2]][(tonumber(splitted[3]) or splitted[3])] = v
        end

    end
    -- if manager.Frame:FindFirstChild('PlayerDoll',true) then
    --     local doll = Manager.PlayerDollHandler.new(manager)
    --     doll:Update()
    -- end

    return manager
end
else

end
return manager