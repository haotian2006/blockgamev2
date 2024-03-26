local PlayerManager = {}

local Players = game:GetService("Players")
local DataStorehandler = require(game.ServerStorage.core.Other.DataStoreHandler)
local DataStore = DataStorehandler.getWorldStore()
local RunService = game:GetService("RunService")

local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local DataHandler = require(game.ReplicatedStorage.Data)
local Serializer = require(game.ReplicatedStorage.Core.Serializer)
local Events = require(game.ReplicatedStorage.Events)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)

local EntityParser = Serializer.wrap(Serializer.Types.entity)

local IsClosing = false

local Data = {}

local Saving = {}
local BDC = {}

local LoadedPlayers = {}

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

local ServerContainerManager = require(script.Parent.Parent.ServerContainer)

local function PlayerAdded(Player:Player)
    local success = PlayerManager.awaitPlayerLoaded(Player) 
    if not success then return end 
    local data = getData(Player) or PlayerManager.createBaseData(Player)
    Data[Player] = data

    DataHandler.addEntity(data.Entity)
       
    ServerContainerManager.sendEntity(data.Entity, Player)

  
end


function PlayerManager.awaitPlayerLoaded(player)
    if LoadedPlayers[player] then return true end 
    local value = OtherUtils.timeOut(60, function()
        repeat
            local _,PlayerAdded = Events.PlayerFullyLoaded:wait()
            LoadedPlayers[PlayerAdded] = true
        until LoadedPlayers[player]
        return true
    end)
    return value and true or false
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


function PlayerManager.respawn(Player)
    local data = Data[Player]
    if not data then return end 
    local Entity = data.Entity

    DataHandler.removeEntity(Entity)
    EntityHandler.destroy(Entity)
    data.AttemptingToRespawn  = true
    task.wait(1)
    local new =  EntityHandler.new("Player",Player.UserId)
    new.Position = Vector3.new(0,100,0)
    EntityHandler.setOwner(new,Player)
    DataHandler.addEntity(new)
    ServerContainerManager.sendEntity(new, Player)

    data.Entity = new
    data.AttemptingToRespawn  = false
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
    LoadedPlayers[player] = nil
end)

Events.RespawnEntity.listen(function(_,player)
    local data = Data[player]
    if not data then return end 
    local Entity = data.Entity
    if EntityHandler.isDead(Entity) and not data.AttemptingToRespawn then
        PlayerManager.respawn(player)
    end
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