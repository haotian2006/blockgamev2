local core = require(game.ReplicatedStorage.Core)
if core[`{"init"}`] then
    core[`{"init"}`]()
end


local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
BehaviorHandler.Init()
local RunService = game:GetService("RunService")

local Synchronizer = require(game.ReplicatedStorage.Synchronizer).Init()

require(game.ServerStorage.core.Replication.Block)
local FieldType = require(game.ReplicatedStorage.EntityHandler.EntityFieldTypes)
FieldType.Init()
local resource =require(game.ReplicatedStorage.ResourceHandler)
local ServerReplicator = require(game.ServerStorage.core.Entity.EntityReplicator)
local Utils = require(game.ReplicatedStorage.EntityHandler.Utils)
--ServerReplicator.Init()
local hold = require(game.ReplicatedStorage.EntityHandler.EntityHolder)
local Handler = require(game.ReplicatedStorage.EntityHandler)
local EntityBehavior = require(game.ServerStorage.core.Entity.EntityBehaviorHandler)
EntityBehavior.Init()
local EntityUpdater = require(game.ReplicatedStorage.EntityHandler.Updater)
EntityUpdater.Init()
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
IndexUtils.preComputeAll()

require(game.ServerStorage.core.ServerContainer)
require(game.ServerStorage.core.Chunk)
local NPC = Handler.new("Npc")
NPC.Guid = "t"
NPC.Position = Vector3.new(254, 257.395999908447266, 140)
--hold.addEntity(NPC)

local Item = Handler.new("c:Item")
Item.Position = Vector3.new(254, 257.395999908447266, 143)
Item.Item = "c:GodStick"
--hold.addEntity(Item)

local EntityContainer = require(game.ReplicatedStorage.EntityHandler.EntityContainerManager)
local ItemHandler = require(game.ReplicatedStorage.Item)
local Container = require(game.ReplicatedStorage.Container)
require(game.ReplicatedStorage.Libarys.Crafting).Init()

ItemHandler.Init()

local Blocks = require(game.ReplicatedStorage.Block).Init()
require(game.ReplicatedStorage.Biomes).init()

local ByteNet = require(game.ReplicatedStorage.Core.ByteNet)
local EntityWrapper = ByteNet.wrap(ByteNet.Types.entity)
local function OnPlayerAdded(player)
  local entity = Handler.new("Player",player.UserId)
  --entity.Position = Vector3.new(522//3, 257.395999908447266, -671.44//3)
  entity.Position = Vector3.new(254, 257.395999908447266, 132)
--  entity.Position = Vector3.new(1, 257.395999908447266, 1)
  Handler.setOwner(entity,player)
  hold.addEntity(entity)

  local craftingContainer = EntityContainer.getContainer(entity, "Crafting")
  Container.set(craftingContainer, 2, ItemHandler.new("c:dirt"), 75)
  -- local p = Instance.new("Part",workspace)
  -- p.Size = Vector3.new(2,3,2)
  -- p.Anchored = true
  -- while task.wait() do
  --     p.Position = entity.Position*3 
  -- end

 -- Handler.addComponent(NPC,"ManFaceMan")

end

for i,v in game:GetService("Players"):GetPlayers() do
  OnPlayerAdded(v)
end
game.Players.PlayerAdded:Connect(OnPlayerAdded)