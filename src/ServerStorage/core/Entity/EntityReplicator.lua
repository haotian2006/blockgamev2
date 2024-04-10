local Player = game:GetService("Players")
local RunService = game:GetService("RunService")
local Entity = game.ReplicatedStorage.EntityHandler
local Holder = require(Entity.EntityHolder)
local Utils = require(Entity.Utils)
local EntityHandler = require(Entity)
local ReplicationUtils = require(Entity.EntityReplicator.ReplicatorUtils)
local temp = ReplicationUtils.temp
local EntityTasks = require(Entity.EntityReplicator.TaskReplicator)

local UDP = Entity.EntityReplicator.EntityUDP
local TCP = Entity.EntityReplicator.EntityTCP

 
local Server = {}

local function replicateAll(entity)
    local str =`{entity.Guid}NEW!`
    if temp[str] then
        return  table.clone(temp[str] )
    end
   local newData = {
            M = 1,
            } 
   for i,v in entity do
    local Level = ReplicationUtils.REPLICATE_LEVEL[i]
    if Level == 1 then continue end 
    newData[i] = v
   end
   temp[str]  = newData
   return newData
end

local function getOtherData(entity)
    local str =`{entity.Guid}C!`
    if temp[str] then
        return temp[str] ~= 1 and table.clone(temp[str]) or nil
    end
    local newData = { M = 1}
    local changed = false
    for i,v in entity.__changed do
        local Level = ReplicationUtils.REPLICATE_LEVEL[i]
        if Level == 1 or Level == 2 then continue end 
        newData[i] = EntityHandler.get(entity,i)
        changed = true
    end
    table.clear(entity.__changed)
    --newData.__GUID = entity.Guid
    temp[str] = changed and newData or 1
    return changed and newData
end

local clientEntities = {} 

local function FindDiffrences(player,data,IsSecondTick)
    local ToRemove = {}
    local ToAdd = {}
    local Entities = clientEntities[player]

    for Guid in Entities do
        if not data[Guid] then
            ToRemove[Guid] = true
            Entities[Guid] = nil
        end
    end

    for Guid in data do
        if not Entities[Guid] then
            ToAdd[Guid] = true
            Entities[Guid] = true
        end
    end
    return ToAdd,ToRemove
end

function Server.isRenderedOnClient(player,guid)
    local e = clientEntities[player]
    return e and e[guid]
end

local RenderDistance = 64
function Server.replicate(IsSecondTick)
    table.clear(temp)
    local Entities = {}
    local PlayerTaskData = {}
    local EntitiesChecked = {}
    local Players = {}
    for i,v in Player:GetPlayers() do
        if clientEntities[v] then  
            Players[#Players+1] = v
        end 
    end
    for _,Player in Players do
        local ClientEntity = Holder.getEntity(tostring(Player.UserId))

        local PlayerTasks = {}
        local PlayerEntities = {}
        Entities[Player] = PlayerEntities
        PlayerTaskData[Player] = PlayerTasks
        local Nearby = {}
        if ClientEntity then
            Nearby = Utils.getEntitiesNear(ClientEntity,RenderDistance,true)
            table.insert(Nearby,ClientEntity)
        end
        for _,entity in Nearby do
            if entity.doReplication == false then continue end 
            local GUID = entity.Guid
            PlayerEntities[GUID] = 1
            if not Server.isRenderedOnClient(Player, GUID) then
                EntitiesChecked[GUID] = true
                PlayerEntities[GUID] = replicateAll(entity)
                continue 
            end
            if not IsSecondTick and not entity.__ownership then continue end 
            EntitiesChecked[GUID] = true
            local IsOwner = EntityHandler.isOwner(entity, Player)
            PlayerTasks[GUID] = EntityTasks.encode(GUID,IsOwner)
            local FastData,SlowData 
            SlowData = getOtherData(entity)
            if not IsOwner then
                FastData = ReplicationUtils.fastEncode(entity, SlowData or {})
            end

            if FastData or SlowData then
                if FastData and not SlowData then
                    PlayerEntities[GUID] = FastData
                else
                    SlowData.F = FastData or nil
                    PlayerEntities[GUID] = SlowData
                end
            end
        end

    end
    for i,v in EntitiesChecked do
        EntityTasks.clearDataFor(i)
    end
    local EntityReplicateData = {}
    local EntityReplicateDataUDP = {}
    local checkedGUIDS = {}
    for Player,data in Entities do
        local PlayerData = {}
        local PlayerDataUDP = {}
        local current 
        EntityReplicateData[Player] = PlayerData
        EntityReplicateDataUDP[Player] = PlayerDataUDP
        local _,toRemove = FindDiffrences(Player,data,IsSecondTick)
        for Guid in toRemove do
            local id =  Holder.getIdFromGuid(Guid)
            checkedGUIDS[Guid] = true
            table.insert(PlayerData,id)
        end
        for Guid,eData in data do
            if eData == 1 then continue end 
            local Id =  Holder.getIdFromGuid(Guid)
            checkedGUIDS[Guid] = true
            if not Id then continue end 
            if eData.M then
                eData.I = Id
                eData.M = nil
                table.insert(PlayerData,eData) 
            else
                --print(Id)
                eData[1] = Vector2.new(Id-32767,eData[1][2])
                if not current then
                    current = {}
                    table.insert(PlayerDataUDP,current)
                elseif #current > 10 then
                    current = {}
                    table.insert(PlayerDataUDP,current)
                end
                table.insert(current,eData) 
                
            end
        end
    end
    local newTaskData = {}
    for i,v in PlayerTaskData do
        if next(v) == nil then continue end 
        newTaskData[i] = {}
        for uuid,data in v do
            local sId = Holder.getIdFromGuid(uuid)
            if not sId then continue end 
            newTaskData[i][tostring(sId)] = data
        end
    end
    for i,v in Players do
        local playerD = EntityReplicateData[v]
        local udpData = EntityReplicateDataUDP[v]
        playerD = next(playerD or {}) and playerD or nil
        local taskd = newTaskData[v]
        taskd = next(taskd or {}) and taskd or nil
        if (playerD or task) then
            TCP:FireClient(v,playerD,taskd)
        end
        if udpData and (next(udpData)) then
           for i,packets in udpData do
                UDP:FireClient(v,packets)
           end
        end
    end
    if IsSecondTick then
        table.clear(Holder.Removed)
    end
end

UDP.OnServerEvent:Connect(function(player,data)
    for i,entity in data or {} do
        local id =tostring(player.UserId)
        if entity and  typeof(entity[1]) =="Vector2" then
            id = entity[1].X
            if id == -69 then 
                id =tostring(player.UserId)
            else
                local entity_ = Holder.getEntityFromLink(id)
                if not entity_ then continue end 
                id = entity_.Guid
            end
        end
        local rEntity = Holder.getEntity(id)
        if not rEntity then continue  end
        local decode = ReplicationUtils.fastDecode(entity,rEntity)
    
        for i,v in decode do
            rEntity[i] = v
        end
        EntityHandler.updateChunk(rEntity)
    end
end)
TCP.OnServerEvent:Connect(function(player,otherData)
    if otherData == "CONNECTED" then
        clientEntities[player] = {}
        return
    end
    for idx,data in otherData or {} do
        local uuid 
        if  data[2] == false then
            uuid = tostring(player.UserId)
        else
            local entity = Holder.getEntityFromLink(data[2])
            if not entity then continue end 
            uuid = entity.Guid
        end

        EntityTasks.decode(uuid,data[1],player)
    end
end)

local clock = 0
RunService.Heartbeat:Connect(function(deltaTime)
    clock += deltaTime
    local secondtick = false
    if clock >= 1/30 then
        clock = 0
        secondtick =true
    end
   
    Server.replicate(secondtick)
end)

local SlotRemote:RemoteEvent = game.ReplicatedStorage.Events.SwapSlot
SlotRemote.OnServerEvent:Connect(function(plr,newSlot)
    local Entity = Holder.getEntity(tostring(plr.UserId))
    if not Entity or not tonumber(newSlot) then return end 

    EntityHandler.setSlot(Entity, `Inventory.{newSlot}`)
end)

return Server