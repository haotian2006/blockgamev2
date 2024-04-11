local core = require(game.ReplicatedStorage.Core)
if core[`{"init"}`] then
    core[`{"init"}`]()
end


local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
BehaviorHandler.Init()
local RunService = game:GetService("RunService")

local WorldConfig = require(game.ReplicatedStorage.WorldConfig)


local Synchronizer = require(game.ReplicatedStorage.Synchronizer).Init(WorldConfig.WorldGuid)
WorldConfig.Init()

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
local Data = require(game.ReplicatedStorage.Data)
local EntityUpdater = require(game.ReplicatedStorage.EntityHandler.Updater)
EntityUpdater.Init()
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
IndexUtils.preComputeAll()

require(game.ServerStorage.core.ServerContainer)
require(game.ServerStorage.core.Chunk)
task.delay(15, function()
 for i =1,1 do
    local Item = Handler.new("Npc")
    Item.Position = Vector3.new(0, 90, 0)
    --Item.Item = "c:GodStick"
 
  -- print("added")
    Data.addEntity(Item)
 end
end)

local Item = Handler.new("c:Item")
Item.Position = Vector3.new(254, 257.395999908447266, 143)
Item.Item = "c:GodStick"

local EntityContainer = require(game.ReplicatedStorage.EntityHandler.EntityContainerManager)
local ItemHandler = require(game.ReplicatedStorage.Item)
local Container = require(game.ReplicatedStorage.Container)
require(game.ReplicatedStorage.Libs.Crafting).Init()

require(game.ServerStorage.core.Replication.Entity)
require(game.ReplicatedStorage.Libs.Stats)

ItemHandler.Init()

local Blocks = require(game.ReplicatedStorage.Handler.Block).Init()
require(game.ReplicatedStorage.Handler.Biomes).init()

local PlayerManager = require(game.ServerStorage.core.Other.PlayerManager)

local Serializer = require(game.ReplicatedStorage.Core.Serializer)
local EntityWrapper = Serializer.wrap(Serializer.Types.entity)


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
 task.wait(6)
 print(entity)

end


-- for i,v in game:GetService("Players"):GetPlayers() do
--   OnPlayerAdded(v)
-- end
-- game.Players.PlayerAdded:Connect(OnPlayerAdded)