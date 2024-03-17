local PlayerManager = {}

local Players = game:GetService("Players")
local DataStorehandler = require(game.ServerStorage.core.Other.DataStoreHandler)
local DataStore = DataStorehandler.getWorldStore()
local RunService = game:GetService("RunService")

local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local DataHandler = require(game.ReplicatedStorage.Data)
local ByteNet = require(game.ReplicatedStorage.Core.ByteNet)

local EntityParser = ByteNet.wrap(ByteNet.Types.entity)



local Data = {}


local function getData(player:Player)
    local info = DataStore:GetAsync(player.UserId.."Data") 
    if not info then return end 
    local c = EntityParser.desterilize(info.Entity)
    info.Entity = EntityHandler.fromData(c)

    return info
end

local function PlayerAdded(Player:Player)
   local data = getData(Player) or PlayerManager.createBaseData(Player)
   Data[Player] = data

   DataHandler.addEntity(data.Entity)
end

function PlayerManager.createBaseData(player:Player)
    local data ={

    }
    local Entity = EntityHandler.new("Player",player.UserId)
    Entity.Position = Vector3.new(0,100,0)
    EntityHandler.setOwner(Entity,player)
    data.Entity = Entity

    return data
end

function PlayerManager.save(Player)
    local data = Data[Player]
    if not data then return end 
    local Cloned = table.clone(data)
    print(Cloned.Entity)
    Cloned.Entity = EntityParser.sterilize(Cloned.Entity)

    DataStore:SetAsync(Player.UserId.."Data",Cloned) 
end



for i,v in Players:GetPlayers() do
    PlayerAdded(v)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    PlayerManager.save(player)
end)

game:BindToClose(function()
    for i,v in Players:GetPlayers() do
        --PlayerManager.save(v)
    end
end)


return PlayerManager