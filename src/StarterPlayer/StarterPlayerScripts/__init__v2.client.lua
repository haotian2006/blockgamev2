local controller = require(script.Parent:WaitForChild("Controller"))
local EntityV2 = game.ReplicatedStorage.EntityHandlerV2
local Client = require(EntityV2.EntityReplicator.Client)
local Updater = require(EntityV2.Updater)
Client.Init()
Updater.Init()
controller.createBinds()