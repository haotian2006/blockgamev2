local PlayerManager = {}

local Players = game:GetService("Players")
local DataStorehandler = require(game.ServerStorage.core.Other.DataStoreHandler)
local DataStore = DataStorehandler.getWorldStore()
local RunService = game:GetService("RunService")

local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local DataHandler = require(game.ReplicatedStorage.Data)
local Serializer = require(game.ReplicatedStorage.Core.Serializer)

local EntityParser = Serializer.wrap(Serializer.Types.entity)

local IsClosing = false

local Data = {}

local Saving = {}
local BDC = {}

local function getData(player:Player)
    if Data[player] then
        return Data[player]
    end
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

    Cloned.Entity = EntityParser.sterilize(Cloned.Entity)
    if Saving[Player] then
        return
    end
    Saving[Player] = true
    DataStore:SetAsync(Player.UserId.."Data",Cloned) 
    Saving[Player] = nil


end

game.ReplicatedStorage.Events.DoSmt.OnServerEvent:Connect(function(p)
    local x = DataHandler.getEntityFromPlayer(p)
    local h =     EntityHandler.get(x, "Health")
    EntityHandler.set(x, "Health", h-5)
end)


for i,v in Players:GetPlayers() do
    PlayerAdded(v)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    PlayerManager.save(player)
    local data = Data[player]
    if not data then return end 
    EntityHandler.destroy(data.Entity)
    Data[player] = nil
end)

local LastTime = os.time()+15
game:GetService("RunService").Heartbeat:Connect(function(a0: number)  
    if os.time()-LastTime >= 30 then
        LastTime= os.time()
        for i,v in Players:GetPlayers() do
            PlayerManager.save(v)
        end 
    end
end)

game:BindToClose(function()
    IsClosing = true
    for i,v in Players:GetPlayers() do
        task.spawn(function()
            PlayerManager.save(v)
        end)
    end
    while next(Saving) do task.wait() end 

end)


return PlayerManager