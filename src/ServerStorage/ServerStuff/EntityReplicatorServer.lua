local RunService = game:GetService("RunService")
local Server ={}
Server.FAST_RATE = 1/30
Server.NORMAL_RATE = 1/20
Server.CHUNK_RANGE = 9
local EntityV2 = game.ReplicatedStorage.EntityHandlerV2
local ReplicationUtils = require(EntityV2.EntityReplicator.ReplicatorUtils)
local BridgeNet = require(game.ReplicatedStorage.BridgeNet)
local EntityBridge = BridgeNet.CreateBridge("EntityBridgeR")
local EntityHolder = require(EntityV2.EntityHolder)
local EntityHandler = require(EntityV2)
local EntityTasks = require(EntityV2.EntityReplicator.TaskReplicator)
local clientEntities = {} 
local temp = ReplicationUtils.temp
function Server.GetIdLocationFrom(player,Id)
    return  clientEntities[player][Id]
end
function Server.GetLocationTable(player)
    return  clientEntities[player] 
end
function Server.UpdateLocationTable(player,t)
    clientEntities[player] = t 
end
function Server.replicateAll(entity)
    local str =`{entity.Guid}NEW!`
    if temp[str] then
        return  temp[str] 
    end
   local newData = {_=1,i = entity.Guid} 
   for i,v in entity do
    local Level = ReplicationUtils.REPLICATE_LEVEL[i]
    if Level == 1 then continue end 
    newData[i] = v
   end
   temp[str]  = newData
   return newData
end
function Server.getOtherData(entity)
    local str =`{entity.Guid}C!`
    if temp[str] then
        return temp[str] 
    end
    local newData = {_=0}
    local changed = false
    for i,v in entity.__changed do
        local Level = ReplicationUtils.REPLICATE_LEVEL[i]
        if Level == 1 or Level == 2 then continue end 
        newData[i] = EntityHandler.get(entity,i)
        changed = true
    end
    table.clear(entity.__changed)
    newData.i = entity.Guid
    temp[str] = changed and newData
    return changed and newData
end
local lastfire = os.clock()
function Server.Replicate(secondTick)
    local playerData = {}
    local playerKey = {}
    local ToRemove = {}
    local PlayerTaskData = {}
    local pt = game.Players:GetPlayers()
    local Players = {}
    for i,v in pt do
        if clientEntities[v] then  
            Players[#Players+1] = v
        end 
    end

    table.clear(temp)
    for uuid,entity in EntityHolder.getAllEntities() do
        if entity.doReplication == false then continue end 
        for i,player in Players do
            local location = Server.GetIdLocationFrom(player,uuid)
            local PlayerTable = playerData[player] or {}
            playerData[player] = PlayerTable
            local playerKey1 = playerKey[player] or {}
            playerKey[player] = playerKey1
            PlayerTaskData[player] =   PlayerTaskData[player] or {}
            local isOwner = EntityHandler.isOwner(entity,player)
            PlayerTaskData[player][uuid] = EntityTasks.encode(uuid,isOwner)
            if not location then 
                table.insert( playerKey[player],uuid)
                table.insert(PlayerTable,Server.replicateAll(entity) ) 
                continue 
            end 
            local fast,slow 
            if secondTick then
                slow = Server.getOtherData(entity)
            end
            if not isOwner then
                fast = ReplicationUtils.fastEncode(entity,slow or {})
            end
            if fast or slow then
                if fast and not slow then
                    table.insert(PlayerTable,fast)
                else
                    slow.f = fast or nil 
                    slow.i = uuid
                    table.insert(PlayerTable,slow)
                end
            end
            table.insert( playerKey[player],uuid)
        end
        EntityTasks.clearDataFor(uuid)
    end
    --compare keys 
    --[[LOGIC 
        get old keys 
            if old keys does not exist
                use the new key 
        compare new with old 
            if old key is missing 
                the entity is new
        compare old with new
            if new key is missing
                the entity should be removed 
    ]]
    for player,keys in playerKey do
        local function compare(new,old)
            local Changes = {}
            local changed = false
            for uuid,loc in new do
                if not old[uuid] then 
                    table.insert(Changes,{uuid,1})
                    changed = true
                end
            end
            for uuid,v in old do
                if not new[uuid] then
                    table.insert(Changes,{uuid,0})
                    changed = true
                end
            end
            return changed and Changes
        end
        local oldKeys =  Server.GetLocationTable(player) or {}
        local swapedKeys = ReplicationUtils.swapKeyPairs(keys)
        local changes = compare(swapedKeys,oldKeys)
        if changes then 
            local swappedOld = ReplicationUtils.swapKeyPairs(oldKeys)
            for idx,change in changes do

                if change[2] == 1 then
                    table.insert(swappedOld,change[1])
                else
                    table.remove(swappedOld,oldKeys[change[1]])
                end
                changes[idx] = `{change[1]},{change[2]}`
            end
            Server.UpdateLocationTable(player,ReplicationUtils.swapKeyPairs(swappedOld))
        end
        local new = Server.GetLocationTable(player) 
        for i,data in playerData[player] do
            if data.i then
                if not new[data.i] then playerData[player][i] = nil end 
                data._ = Vector2int16.new(data._,new[data.i])
                data.i = nil
            elseif data[1] then
                if not new[data[1][1]] then playerData[player][i] = nil end 
                data[1] = Vector2.new(new[data[1][1]]-32767,data[1][2])
            end
        end
        playerKey[player] = changes or nil
    end
    local newTaskData = {}
    for i,v in PlayerTaskData do
        if next(v) == nil then continue end 
        newTaskData[i] = {}
        for uuid,data in v do
            local sId = Server.GetIdLocationFrom(i,uuid)
            if not sId then continue end 
            newTaskData[i][tostring(sId)] = data
        end
    end
    for i,v in Players do
        if not playerData[v] or #playerData[v] == 0 then 
            playerData[v] = nil
        end 
        if not (playerData[v] or playerKey[v] or newTaskData[v]) then
             continue
        end
        EntityBridge:FireTo(v,playerData[v],playerKey[v],newTaskData[v])
    end
end
local Connection 
function Server.Init()
    if Connection then return end
    local clock1 = 0
    local clock2 = 0
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        clock1 += deltaTime--; clock2 += deltaTime
        local secondtick = false
        -- if clock2 >= Server.NORMAL_RATE then
        --     clock2 = 0
        --     secondtick =true
        -- end
        if clock1 >= Server.NORMAL_RATE then
            Server.Replicate(true)
            clock1 = 0
        end
    end)
    EntityBridge:Connect(function(player,data,otherData)
        if data == "CONNECTED" then
            clientEntities[player] = {}
            return
        end
        local ids = {}
        for i,entity in data or {} do
            if type(entity) ~= "table" then
                if not entity then 
                    ids[i] = tostring(player.UserId)
                    continue
                end
                ids[i] = entity
                continue
            end
            local id 
            if typeof(entity[1]) =="Vector2" then
                id = tostring(entity[1].X)
                if id == "-69" then 
                    id =tostring(player.UserId)
                end
            elseif entity[1] == false then
                id = tostring(player.UserId)
            else
                id = tostring(entity[1][1])
                entity[1] = Vector2.new(0,entity[1][2])
            end
            ids[i] = id
            local rEntity = EntityHolder.getEntity(id)
            if not rEntity then continue  end
            local decode = ReplicationUtils.fastDecode(entity,rEntity)
            for i,v in decode do
                rEntity[i] = v
            end
        end
        for idx,data in otherData or {} do
            local uuid = ids[idx]

            EntityTasks.decode(uuid,data)
        end
    end)
end
return Server