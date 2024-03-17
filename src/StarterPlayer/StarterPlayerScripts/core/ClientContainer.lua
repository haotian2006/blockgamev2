local ClientContainer = {}
local Item = require(game.ReplicatedStorage.Item)

local loadedContainers = {
   
}



local LocalPlayer = game:GetService("Players").LocalPlayer

local Container = require(game.ReplicatedStorage.Container)
local UiContainer = require(script.Parent.Ui.ContainerHandler)
local HotbarManager = require(script.Parent.Ui.HotbarManager)
local Signal = require(game.ReplicatedStorage.Libarys.Signal)

local ContainerAdded = Signal.new()
local ContainerRemoved = Signal.new()

HotbarManager.setContainer(ClientContainer)

local Events = game:GetService("ReplicatedStorage").Events.Container
local Send:RemoteEvent = Events.Send
local Update:RemoteEvent = Events.Update
local Request:RemoteFunction = Events.Request

ClientContainer.ContainerAdded = ContainerAdded
ClientContainer.ContainerRemoved = ContainerAdded

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
    if data then
        ContainerAdded:Fire(Name,data)
    elseif loadedContainers[Name]then
        ContainerRemoved:Fire(Name, loadedContainers[Name] )
    end
    loadedContainers[Name] = data
end

function ClientContainer.deloadContainer(Name)
    if loadedContainers[Name]then
        ContainerRemoved:Fire(Name, loadedContainers[Name] )
    end
    loadedContainers[Name] = nil
end

function ClientContainer.send(type,...)
    Send:FireServer(type,...)
end


function ClientContainer.getPath(container)
   local parent = Container.getParent(container)
   local Name = Container.getName(container)
   if parent == tostring(LocalPlayer.UserId) then return Name end
   return {parent,Name}
end

function ClientContainer.awaitContainer(name,MaxTime,suppressWarning)
    local container = loadedContainers[name]
    if container then
        return container
    end
    local running = coroutine.running()
    local delay_ 
    local WaitThread = task.spawn(function()
        container = loadedContainers[name]
        local name_
        while name_ == name or container do 
            name_ = ContainerAdded:Wait()
            container = loadedContainers[name]
        end  
        task.cancel(delay_)
        coroutine.resume(running)
    end)
    delay_ = task.delay(MaxTime or 5, function()
        task.cancel(WaitThread)
        if not suppressWarning then
            warn(`TimeOut Warning | Container '{name}'`)
        end
        coroutine.resume(running)
    end)
    if container then
        return container
    end
    coroutine.yield()
    return container
end

UiContainer.init(ClientContainer)

function ClientContainer.getAndLoadFromServer(uuid,name)
    local cc = ClientContainer.getContainer( name)
    if cc then return cc end 
    local CData = Request:InvokeServer(uuid,name)
    CData[#CData+1] = {__Parent = uuid,__Name = name}
    ClientContainer.loadContainer(name, CData)
    return CData
end

Send.OnClientEvent:Connect(function(name,CData,uuid,containerName)
    if not CData then
        ClientContainer.deloadContainer(name)
        return
    end
    CData[#CData+1] = {__Parent = uuid,__Name = containerName}
    ClientContainer.loadContainer(name, CData)
end)

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
task.wait(1)

ClientContainer.getAndLoadFromServer(tostring(LocalPlayer.UserId),"Crafting")
ClientContainer.getAndLoadFromServer(tostring(LocalPlayer.UserId),"Holding")
ClientContainer.getAndLoadFromServer(tostring(LocalPlayer.UserId),"Inventory")

return ClientContainer   