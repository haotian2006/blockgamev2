local ClientContainer = {}
local Item = require(game.ReplicatedStorage.Item)

local LocalPlayer = game:GetService("Players").LocalPlayer

local Container = require(game.ReplicatedStorage.Container)
local UiContainer = require(script.Parent.Ui.ContainerHandler)
local HotbarManager = require(script.Parent.Ui.HotbarManager)
local Signal = require(game.ReplicatedStorage.Libarys.Signal)
local Datahandler = require(game.ReplicatedStorage.Data)

local ContainerAdded = Signal.new()
local ContainerRemoved = Signal.new()

HotbarManager.setContainer(ClientContainer)

local Events = game:GetService("ReplicatedStorage").Events.Container
local Send:RemoteEvent = Events.Send
local Update:RemoteEvent = Events.Update
local Request:RemoteFunction = Events.Request

ClientContainer.ContainerAdded = ContainerAdded
ClientContainer.ContainerRemoved = ContainerAdded

local LoadedContainers = {}
local NameContainerPairs = {}

local function Wrap(container)
    return {container}
end

local function getContainer(wrapped)
    return wrapped[1]
end


function ClientContainer.removeContainer(space,name)
    
end

function ClientContainer.removeEntity(Entity)
    local Guid = Entity.Guid

end