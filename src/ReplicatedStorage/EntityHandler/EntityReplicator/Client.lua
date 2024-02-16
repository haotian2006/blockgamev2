local RunService = game:GetService("RunService")
local EntityV2 = game.ReplicatedStorage.EntityHandler
local ReplicationUtils = require(EntityV2.EntityReplicator.ReplicatorUtils)
local EntityHolder = require(EntityV2.EntityHolder)
local EntityHandler = require(EntityV2)
local math = require(game.ReplicatedStorage.Libarys.MathFunctions)
local Data = require(game.ReplicatedStorage.Data)
local Render = require(script.Parent.Parent.Render)
local Animator = require(script.Parent.Parent.Animator)
local EntityTasks = require(script.Parent.TaskReplicator)
local Signal = require(game.ReplicatedStorage.Libarys.Signal)

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
    if data.Guid == tostring(LOCAL_PLAYER.UserId) then
        Data.setPlayerEntity(Entity)
    end
    for i,v in data do
        Entity[i] = v
    end
    if data.__animations then
        for i,v in data.__animations do
            Animator.play(Entity,i)
        end
    end
    return Entity
end
function Client.updateEntity(Guid,data)
    local Entity = EntityHolder.getEntity(Guid)
    if not Entity then return end 
    local toInterpolate = toInterpolate[Guid] or {}
    local hasOwner = EntityHandler.isOwner(Entity,LOCAL_PLAYER)
    for i,v in data do
        if hasOwner and ReplicationUtils.REPLICATE_LEVEL[i] == 3 then continue end 
        Entity[i] = v
        if UpdateEvents[i] then UpdateEvents[i]:Fire(Entity,v) end 
        if overRide[i] then toInterpolate[i] = nil end --Prevents lerping from messing up stuff
    end
    return Entity
end
function Client.handleFast(data,id)
    local old = EntityHolder.getEntity(id)
    if not old then return end 
    local normal = ReplicationUtils.fastDecode(data,old)
    old.Chunk = normal.Chunk or old.Chunk
    for i,v in normal do
        if not toInterpolate[id] then toInterpolate[id] = {} end 
                            --{target,origiank}
        toInterpolate[id][i] = {v,old[i]}
    end
end
function Client.handleData(data)
    if data[1] then --fast
        local id = key[data[1].X+32767]
        Client.handleFast(data,id)
        return
    end
    local type,idx = data._.X,data._.Y
    local Guid = key[idx]
    data.Guid = Guid
    if type == 1 then -- all
        local Entity = Client.createEntityFrom(data)
        if not Entity then return end 
        EntityHolder.addEntity(Entity)
        Render.createModel(Entity)
    else
        if data.f then
            Client.handleFast(data.f,Guid)
            data.f = nil
        end
        local Updated = Client.updateEntity(Guid,data)
        if not Updated then return end 
        if data.__components then
            print("changed")
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
            local idx = table.find(key,id)
            if not idx then continue end 
            table.remove(key,idx)
            --delete entity
        end
    end
end
local Const = 6
local TIME = .1

function Client.updateInterpolate(dt)
    local LerpRate = dt*Const
    for guid,target in toInterpolate do
        local Entity = EntityHolder.getEntity(guid)
        if not Entity then return end 
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
        TaskReplicator.clearDataFor(id)
        if not data then 
            if tasks then
                table.insert(OtherTasks,{tasks,if id == tostring(LOCAL_PLAYER.UserId) then false else id})
            end
            continue 
        end 
        if id == tostring(LOCAL_PLAYER.UserId)  then
            data[1] = data[1][2] and Vector2.new(-69,data[1][2]) or false 
        else
            data[1] = data[1][2] and {data[1],Vector2.new(0,data[1][2])} or data[1]
        end
        table.insert(toReplicate,data)
        if tasks then
            table.insert(OtherTasks,{tasks,if id == tostring(LOCAL_PLAYER.UserId) then false else id})
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
function Client.readData(Entities,Key,taskData)
    if Key then Client.readKey(Key) end 
    for i:number,v in Entities or {} do
        Client.handleData(v)
    end
    for i,v in taskData or {} do
        EntityTasks.decode(key[tonumber(i) or 1],v)
    end
end
function Client.Init()
    if Connection then return end 
    TCP.OnClientEvent:Connect(Client.readData)
    UDP.OnClientEvent:Connect(function(entityEncoded)
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