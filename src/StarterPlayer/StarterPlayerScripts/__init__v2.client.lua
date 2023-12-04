
-- local resource = require(game.ReplicatedStorage.ResourceHandler)
-- resource:Init()
-- local itemhand = require(game.ReplicatedStorage.ItemHandler):Init()
-- require(game.ReplicatedStorage.BehaviorHandler):Init()
-- local managers = require(game.ReplicatedStorage.Managers):Init()
-- local bridge = require(game.ReplicatedStorage.BridgeNet)

-- local RenderHandler = require(script.Parent.Render):Init()


local controller = require(script.Parent:WaitForChild("Controller"))
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandlerV2)
BehaviorHandler.Init()
local EntityV2 = game.ReplicatedStorage.EntityHandlerV2
local Client = require(EntityV2.EntityReplicator.Client)
local Updater = require(EntityV2.Updater)
Client.Init()
Updater.Init()
controller.createBinds()

local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
IndexUtils.preCompute()
local Render = require(script.Parent.RenderV2).Init()