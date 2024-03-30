local ClientContainer = {}
local Item = require(game.ReplicatedStorage.Item)

local LocalPlayer = game:GetService("Players").LocalPlayer

local Container = require(game.ReplicatedStorage.Container)
local UiContainer = require(script.Parent.Ui.ContainerHandler)
local HotbarManager = require(script.Parent.Ui.HotbarManager)
local Signal = require(game.ReplicatedStorage.Libs.Signal)
local Datahandler = require(game.ReplicatedStorage.Data)

local ContainerAdded = Signal.protected()
local ContainerRemoved = Signal.protected()
local ContainerUpdated = Signal.protected()


local Events = game:GetService("ReplicatedStorage").Events.Container
local Send:RemoteEvent = Events.Send
local Update:RemoteEvent = Events.Update
local Request:RemoteFunction = Events.Request

ClientContainer.ContainerAdded = ContainerAdded.Event
ClientContainer.ContainerRemoved = ContainerRemoved.Event
ClientContainer.ContainerUpdated = ContainerUpdated.Event

HotbarManager.setContainer(ClientContainer)

local LoadedContainers = {}
local KeyPairs = {}

local function addToPairs(uuid,name,container)
    if not KeyPairs[uuid] then
        KeyPairs[uuid] = {}
    end
    KeyPairs[uuid][name] = container
end

local function removeFromPairs(uuid,name)
    if not KeyPairs[uuid] then
        return 
    end
    KeyPairs[uuid][name] = nil
    if not next(KeyPairs[uuid]) then
        KeyPairs[uuid] = nil
    end
    ContainerUpdated:Fire()
end

local function getFromPairs(uuid,name)
    if not KeyPairs[uuid] then
        return 
    end
    return  KeyPairs[uuid][name] 
end

function ClientContainer.getAllContainers()
    return LoadedContainers
end

function ClientContainer.getHolding()
    return LoadedContainers["Holding"] and Container.get(LoadedContainers["Holding"], 1)
end

function ClientContainer.getItemAt(container,idx,x)
    if not LoadedContainers[container] then return end 
    if x then 
        print(LoadedContainers[container])
    end
    return  Container.get( LoadedContainers[container], tonumber(idx))
end


function ClientContainer.load(name,container)
    LoadedContainers[name] = container
end

function ClientContainer.create(uuid,name,data)
    data[#data+1] = {__Parent = uuid,__Name = name}
end

function ClientContainer.remove(name)
    local container =  LoadedContainers[name]
    if not container then return end 
    local Data = container[#container]
    removeFromPairs(Data.__Parent, Data.__Name)
    LoadedContainers[name] = nil
end

function ClientContainer.remove2(guid,name)
    for i,v in LoadedContainers do
        local extra = v[#v]
        if extra.__Parent == guid and extra.__Name == name then
            LoadedContainers[i] = nil
        end
    end
    removeFromPairs(guid,name)
end

function ClientContainer.removeAllRelatedTo(Guid)
    for i,v in LoadedContainers do
        local last = v[#v]
        if last.__Parent == Guid then
            LoadedContainers[i] = nil
        end
    end
    KeyPairs[Guid] = nil
    ContainerUpdated:Fire()
end

function ClientContainer.get(name)
    return LoadedContainers[name]
end

function ClientContainer.get2(gui,name)
    if KeyPairs[gui] then
        return KeyPairs[gui][name]
    end
    return 
end

function ClientContainer.createPath(container)
    local parent = Container.getParent(container)
    local Name = Container.getName(container)
    if parent == tostring(LocalPlayer.UserId) then return Name end
    return {parent,Name}
 end

function ClientContainer.send(type,...)
    Send:FireServer(type,...)
end

local tasks = {
    [1] = function(Guid,display,name,container) --Load
        ClientContainer.create(Guid,name,container)
        display = display or name
        LoadedContainers[display] = container
        addToPairs(Guid,name,container)

        ContainerUpdated:Fire()
    end,
    [2] = function(name) -- remove
        local container =  LoadedContainers[name]
        if not container then return end 
        local Data = container[#container]
        removeFromPairs(Data.__Parent, Data.__Name)
        LoadedContainers[name] = nil
    end,
    [3] = function(guid) -- removeall
        ClientContainer.removeAllRelatedTo(guid)
    end
}

Send.OnClientEvent:Connect(function(type,...)
    if tasks[type] then
        tasks[type](...)
    end
end)

Update.OnClientEvent:Connect(function(data)
    for i,changed in data do
        local uuid,name = changed[1],changed[2]
        local c = ClientContainer.get2(uuid,name)
        if not c then continue end 
        if Container.getParent(c) ~= uuid then continue end 
        for idx = 3,#changed do
            local newData = changed[idx]
            local index,nData = newData[1],newData[2]
            c[index+1] = nData
        end
    end

    ContainerUpdated:Fire()
end)


UiContainer.init(ClientContainer)

return ClientContainer