

--// rojo sourcemap default.project.json --output sourcemap.json
local Events = require(game.ReplicatedStorage.Events)

local LocalPlayer =  game:GetService("Players").LocalPlayer

task.wait(2)

local core = require(game.ReplicatedStorage.Core)

if core[`{"init"}`] then
    core[`{"init"}`]()
end


local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
BehaviorHandler.Init()
require(game.ReplicatedStorage.ResourceHandler).Init()
require(game.Players.LocalPlayer.PlayerScripts.core.ClientContainer)

local Synchronizer = require(game.ReplicatedStorage.Synchronizer).Init()
local Blocks = require(game.ReplicatedStorage.Handler.Block).Init()
local Item = require(game.ReplicatedStorage.Handler.Item).Init()
local controller = require(script.Parent:WaitForChild("Controller"))
require(game.ReplicatedStorage.Handler.Biomes).init()
local FieldType = require(game.ReplicatedStorage.Handler.EntityHandler.EntityFieldTypes)
FieldType.Init()

local EntityV2 = game.ReplicatedStorage.Handler.EntityHandler
local Client = require(EntityV2.EntityReplicator.Client)
local Updater = require(EntityV2.Updater)
Client.Init()
Updater.Init()
controller.createBinds()

local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
IndexUtils.preComputeAll()
--local Render = require(script.Parent.Render).Init() 
require(script.Parent.core.chunk)

local Core = game:GetService("Players").LocalPlayer.PlayerScripts.core

require(Core.Ui.HudManager).Init()
require(Core.Rendering.Arms).Init()
require(Core.Ui.HotbarManager).Init()

require(Core.ClientManager)
require(game.ReplicatedStorage.Libs.Stats)

Events.PlayerFullyLoaded:send(true)