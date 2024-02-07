local ClientContainer = {}
local Item = require(game.ReplicatedStorage.Item)
local loadedContainers = {
   
}

local LocalPlayer = game:GetService("Players").LocalPlayer

local Container = require(game.ReplicatedStorage.Container)
local UiContainer = require(script.Parent.Ui.ContainerHandler)
local HotbarManager = require(script.Parent.Ui.HotbarManager)

HotbarManager.setContainer(ClientContainer)

local Events = game:GetService("ReplicatedStorage").Events.Container
local Send:RemoteEvent = Events.Send
local Update:RemoteEvent = Events.Update
local Request:RemoteFunction = Events.Request

function ClientContainer.getHolding()
    return loadedContainers["Holding"] and Container.get(loadedContainers["Holding"], 1)
end

function ClientContainer.getItemAt(container,idx)
    if not loadedContainers[container] then return end 
    return  Container.get( loadedContainers[container], tonumber(idx))
end

function ClientContainer.getContainer(container)
    return  loadedContainers[container] 
end

function ClientContainer.getAllContainers(container)
    return  loadedContainers
end

function ClientContainer.loadContainer(Name,data)
    loadedContainers[Name] = data
end

function ClientContainer.deloadContainer(Name)
    loadedContainers[Name] = nil
end

function ClientContainer.getPath(container)
   local parent = Container.getParent(container)
   if parent == tostring(LocalPlayer.UserId) then return container[1] end
   return {parent, container[1]}
end

UiContainer.init(ClientContainer)

function ClientContainer.getAndLoadFromServer(uuid,name)
    local cc = ClientContainer.getContainer( name)
    if cc then return cc end 
    local CData = Request:InvokeServer(uuid,name)
    CData[#CData+1] = {__Parent = uuid}
    ClientContainer.loadContainer(name, CData)
    return CData
end

Update.OnClientEvent:Connect(function(data)
    for i,changed in data do
        local uuid,name = changed[1],changed[2]
        local c = ClientContainer.getContainer(name)
        if not c then continue end 
        if Container.getParent(c) ~= uuid then continue end 
        for idx = 3,#changed do
            local newData = changed[idx]
            local index,nData = newData[1],newData[2]
            c[index+1] = nData
        end
    end
    UiContainer.updateAll()
    
    HotbarManager.UpdateSlot()
end)

ClientContainer.getAndLoadFromServer(tostring(LocalPlayer.UserId),"Crafting")
ClientContainer.getAndLoadFromServer(tostring(LocalPlayer.UserId),"Holding")
ClientContainer.getAndLoadFromServer(tostring(LocalPlayer.UserId),"Inventory")

return ClientContainer   