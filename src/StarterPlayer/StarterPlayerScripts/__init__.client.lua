--// rojo sourcemap default.project.json --output sourcemap.json
local LocalPlayer =  game:GetService("Players").LocalPlayer
local _ = game.Loaded or game.Loaded:Wait()
task.wait(2)
local Synchronizer = require(game.ReplicatedStorage.Synchronizer).Init()
local Blocks = require(game.ReplicatedStorage.Block).Init()
local controller = require(script.Parent:WaitForChild("Controller"))
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
BehaviorHandler.Init()
require(game.ReplicatedStorage.Biomes).init()
local AssetManager = require(script.Parent.AssetManager)
AssetManager.init()

local EntityV2 = game.ReplicatedStorage.EntityHandler
local Client = require(EntityV2.EntityReplicator.Client)
local Updater = require(EntityV2.Updater)
Client.Init()
Updater.Init()
controller.createBinds()

local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
IndexUtils.preComputeAll()
--local Render = require(script.Parent.Render).Init() 
require(script.Parent.core.chunk)
require(game.Players.LocalPlayer.PlayerScripts.core.ClientContainer)

require(game:GetService("Players").LocalPlayer.PlayerScripts.core.Rendering.Arms).Init()
require(game:GetService("Players").LocalPlayer.PlayerScripts.core.Ui.HotbarManager).Init()