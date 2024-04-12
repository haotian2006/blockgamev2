local RunService = game:GetService("RunService")
local EntityV2 = game.ReplicatedStorage.Handler.EntityHandler
local ReplicationUtils = require(EntityV2.EntityReplicator.ReplicatorUtils)
local EntityHolder = require(EntityV2.EntityHolder)
local EntityHandler = require(EntityV2)
local math = require(game.ReplicatedStorage.Libs.MathFunctions)
local Data = require(game.ReplicatedStorage.Data)
local Render = require(script.Parent.Parent.Render)
local Animator = require(script.Parent.Parent.Animator)
local EntityTasks = require(script.Parent.TaskReplicator)
local Signal = require(game.ReplicatedStorage.Libs.Signal)

local LOCAL_PLAYER = game.Players.LocalPlayer
local Client = {}
local key = {}
local toInterpolate = {}
local overRide = {Position = true,Rotation = true,HeadRotation = true}

local UpdateEvents = {}

local UDP = EntityV2.EntityReplicator.EntityUDP
local TCP = EntityV2.EntityReplicator.EntityTCP

function Client.getUpdateEvent(key)
    if UpdateEvents[key] then return UpdateEvents[key] end 
    local event = Signal.new()
    UpdateEvents[key] = event
    return event
end

function Client.getGuidFrom(Key)
    return key[Key]
end
function Client.createEntityFrom(data)
    local Entity = EntityHandler.new(data.Type,data.Guid)
    if not Entity then return end 
    for i,v in data do
        Entity[i] = v
    end
    if data.Guid == tostring(LOCAL_PLAYER.UserId) then
        Data.setPlayerEntity(Entity)
    end
    for i,v in data do
        EntityHandler.set(Entity, i,v)
    end
    return Entity
end
function Client.updateEntity(Guid,data)
    local Entity = EntityHolder.getEntity(Guid)
    if not Entity then return end 
    local toInterpolate_ = toInterpolate[Guid] or {}
    local hasOwner = EntityHandler.isOwner(Entity,LOCAL_PLAYER)
    for i,v in data do
        if hasOwner and ReplicationUtils.REPLICATE_LEVEL[i] == 3 then continue end 
        EntityHandler.set(Entity, i, v)
        if UpdateEvents[i] then UpdateEvents[i]:Fire(Entity,v) end 
        if overRide[i] then toInterpolate_[i] = nil end --Prevents lerping from messing up stuff
    end
    return Entity
end
function Client.handleFast(data,id)
    local old = EntityHolder.getEntity(id)
    if not old then return end 
    local normal = ReplicationUtils.fastDecode(data,old)
    old.Chunk = normal.Chunk or old.Chunk
    if normal.Position then
        if normal.Position.Y == 0 then
            normal.Position = Vector3.new(normal.Position.X,old.Position.Y,normal.Position.Z)
        end
    end
    for i,v in normal do
        if not toInterpolate[id] then toInterpolate[id] = {} end 
                            --{target,origiank}
                            --old[i] = v
        toInterpolate[id][i] = {v,old[i] or v}
    end
end
function Client.handleData(data)
    if type(data) == "number" then
        local Entity = EntityHolder.getEntityFromLink(data)

        if not Entity then return end 

        local Guid = Entity.Guid
        EntityHolder.removeEntity(Guid)
        EntityHolder.unLink(data)
        if Guid == tostring(LOCAL_PLAYER.UserId) then
            Data.setPlayerEntity(nil)
        end
        EntityHandler.destroy(Entity)
        if Entity and Entity.model then
            Entity.model:Destroy()
        end
        return
    end
    if data[1] then --fast
        local Entity = EntityHolder.getEntityFromLink(data[1].X+32767)
        if not Entity then return end 
        local Guid = Entity.Guid
        Client.handleFast(data,Guid)
        return
    end
    local IsNew = data.Guid 
    local idx = data.I
    data.I = nil
    if IsNew then -- all
        local Entity = Client.createEntityFrom(data)

        if not Entity then return end 
        Entity.__NetworkId = idx
        EntityHolder.addEntity(Entity)

        EntityHolder.linkEntity(idx,Entity)
        Render.createModel(Entity)

        if data.__animations then
            for i,v in data.__animations do
                Animator.play(Entity,i,v)
            end
        end
    else
        local Entity = EntityHolder.getEntityFromLink(idx)
        if not Entity then return end 
        local Guid = Entity.Guid
        data.Guid = Guid
        if data.F then
            Client.handleFast(data.F,Guid)
            data.F = nil
        end
        local Updated = Client.updateEntity(Guid,data)
        if not Updated then return end 
        if data.__components then
            table.clear(Updated.__cachedData)
            Render.createModel(Updated)

        end
    --slow 
    end
end

function Client.readKey(keyData)
    for idx,key_ in keyData do
        local id,todo = key_:match("([^,]*),?([^,]*)")
        if todo == '1' then
            table.insert(key,id)
        else
            local idx_ = table.find(key,id)
            if not idx_ then continue end 
            local Guid = key[idx_]
            table.remove(key,idx_)
            local Entity = EntityHolder.getEntity(Guid)
            EntityHolder.removeEntity(Guid)
            if Entity and Entity.model then
                Entity.model:Destroy()
            end
            --delete entity
        end
    end
end
local Const = 6
local TIME = .1
local p = Instance.new("Part")
p.Parent = workspace
p.Anchored = true
function Client.updateInterpolate(dt)
    local LerpRate = dt*Const
    for guid,target in toInterpolate do
        local Entity = EntityHolder.getEntity(guid)
        if not Entity then 
            toInterpolate[guid] = nil
            continue 
        end 
        if EntityHandler.isOwner(Entity,LOCAL_PLAYER) then
            toInterpolate[guid] = nil 
            continue
        end
        if target.Position then
            local targetV = target.Position[1]
            local maxDistance = (target.Position[2] - targetV).Magnitude
            local rate = maxDistance/TIME
            local moveDistance =rate*dt
            local direction = (targetV - Entity.Position)
            local new = Entity.Position + direction.Unit * moveDistance
          --  p.Position = target.Position[2]*3
            if (target.Position[2]- new).Magnitude < maxDistance then 
                Entity.Position = new
            else
                Entity.Position = targetV
                target.Position = nil
            end
            
        end
        if target.Rotation then
            local targetV = target.Rotation[1]
            local dif,reached = math.slerpAngle(Entity.Rotation,targetV,LerpRate*2.5)
            Entity.Rotation = dif
            if reached then
                target.Rotation = nil 
            end
        end
        if target.HeadRotation then
            local targetV = target.HeadRotation[1]
            local x,Xreached = math.slerpAngle(Entity.HeadRotation.X,targetV.X,LerpRate*2.5)
            local y,Yreached = math.slerpAngle(Entity.HeadRotation.Y,targetV.Y,LerpRate*2.5)
            Entity.HeadRotation = Vector2.new(x,y)
            if Xreached and Yreached then
                target.HeadRotation = nil 
            end
        end
        if next(target) == nil then toInterpolate[guid] = nil end 
    end
end

local TaskReplicator = require(script.Parent.TaskReplicator)
function Client.replicateToServer()
    local toReplicate = {}
    local OtherTasks = {}
    table.clear(ReplicationUtils.temp) 
    for id,entity in EntityHolder.getAllEntities() do
        if not EntityHandler.isOwner(entity,game.Players.LocalPlayer) or entity.doReplication == false then continue end 
        local data = ReplicationUtils.fastEncode(entity)
        local tasks = TaskReplicator.encode(id)
        local ReplicationId = entity.__NetworkId
        TaskReplicator.clearDataFor(id)
        if not data then 
            if tasks then
                table.insert(OtherTasks,{tasks,if id == tostring(LOCAL_PLAYER.UserId) then false else ReplicationId})
            end
            continue 
        end 
      
        if id == tostring(LOCAL_PLAYER.UserId)  then
            data[1] = data[1][2] and Vector2.new(-69,data[1][2]) or false 
        else
            data[1] = data[1][2] and {Vector2.new(ReplicationId,data[1][2]),Vector2.new(0,data[1][2])} or data[1]
        end
        table.insert(toReplicate,data)
        if tasks then
            table.insert(OtherTasks,{tasks,if id == tostring(LOCAL_PLAYER.UserId) then false else ReplicationId})
        end
    end
    if #toReplicate >0 then
        UDP:FireServer(toReplicate)
    end
    if #OtherTasks >0 then
        TCP:FireServer(OtherTasks)
    end
end

local Connection 
function Client.readData(Entities,taskData)
    --if Key then Client.readKey(Key) end 
    for i:number,v in Entities or {} do
        Client.handleData(v)
    end
    for i,v in taskData or {} do
        local entity_ = EntityHolder.getEntityFromLink(tonumber(i))
        if not entity_ then continue end 
        local id = entity_.Guid
        EntityTasks.decode(id,v)
    end
end
function Client.Init()
    if Connection then return end 
    TCP.OnClientEvent:Connect(Client.readData)
    UDP.OnClientEvent:Connect(function(entityEncoded)
      --  print(entityEncoded)
        for i,v in entityEncoded or {} do
            Client.handleData(v)
        end
    end)
    Connection = RunService.RenderStepped:Connect(function(deltaTime)
        Client.updateInterpolate(deltaTime)
    end)
    local clock1 = 0
    RunService.Heartbeat:Connect(function(deltaTime)
        clock1 += deltaTime
        if clock1 >= 1/30 then
            Client.replicateToServer()
            clock1 = 0
        end
    end)
    task.delay(3, function()
        TCP:FireServer("CONNECTED")
    end)
end
return table.freeze(Client)