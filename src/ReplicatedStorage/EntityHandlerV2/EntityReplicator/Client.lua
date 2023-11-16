local RunService = game:GetService("RunService")
local BridgeNet = require(game.ReplicatedStorage.BridgeNet)
local EntityBridge = BridgeNet.CreateBridge("EntityBridgeR")
local EntityV2 = game.ReplicatedStorage.EntityHandlerV2
local ReplicationUtils = require(EntityV2.EntityReplicator.ReplicatorUtils)
local EntityHolder = require(EntityV2.EntityHolder)
local EntityHandler = require(EntityV2)
local math = require(game.ReplicatedStorage.Libarys.MathFunctions)
local Render = require(script.Parent.Parent.Render)
local LOCAL_PLAYER = game.Players.LocalPlayer
local Client = {}
local key = {}
local toInterpolate = {}
local overRide = {Position = true,Rotation = true,HeadRotation = true}
function Client.createEntityFrom(data)
    local Entity = EntityHandler.new(data.Type,data.Guid)
    for i,v in data do
        Entity[i] = v
    end
    return Entity
end
function Client.updateEntity(Guid,data)
    local Entity = EntityHolder.getEntity(Guid)
    if not Entity then return end 
    local toInterpolate = toInterpolate[Guid] or {}
    for i,v in data do
        Entity[i] = v
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
        toInterpolate[id][i] = v
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
        EntityHolder.addEntity(Entity)
        Render.createModel(Entity)
    else
        if data.f then
            Client.handleFast(data.f,Guid)
            data.f = nil
        end
        local Updated = Client.updateEntity(Guid,data)
        if not Updated then return end 
        if data.Hitbox or data.EyeLevel then
            Render.updateHitbox(EntityHolder.getEntity(Guid),
                EntityHandler.get(Updated,"Hitbox"), 
                EntityHandler.get(Updated,"EyeLevel"))
        end
        if data.__components then
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
            table.remove(key,table.find(key,id))
        end
    end
end
local Const =6
function Client.updateInterpolate(dt)
    local LerpRate = dt*Const
    for guid,target in toInterpolate do
        local Entity = EntityHolder.getEntity(guid)
        if not Entity then return end 
        if target.Position then
            local dif = math.lerp(Entity.Position,target.Position,LerpRate)
            local reached =   (Entity.Position-target.Position).Magnitude <=.01 
            Entity.Position = dif
            if reached then
                target.Position = nil 
            end
        end
        if target.Rotation then
            local dif,reached = math.slerpAngle(Entity.Rotation,target.Rotation,LerpRate)
            Entity.Rotation = dif
            if reached then
                target.Rotation = nil 
            end
        end
        if target.HeadRotation then
            local x,Xreached = math.slerpAngle(Entity.HeadRotation.X,target.HeadRotation.X,LerpRate)
            local y,Yreached = math.slerpAngle(Entity.HeadRotation.Y,target.HeadRotation.Y,LerpRate)
            Entity.HeadRotation = Vector2.new(x,y)
            if Xreached and Yreached then
                target.HeadRotation = nil 
            end
        end
        if next(target) == nil then toInterpolate[guid] = nil end 
    end
end
function Client.replicateToServer()
    local toReplicate = {}
    table.clear(ReplicationUtils.temp) 
    for id,entity in EntityHolder.getAllEntities() do
        if not EntityHandler.isOwner(entity,game.Players.LocalPlayer) then continue end 
        local data = ReplicationUtils.fastEncode(entity)
        if not data then return end 
        if id == tostring(LOCAL_PLAYER.UserId)  then
            data[1] = data[1][2] and Vector2.new(0,data[1][2]) or false 
        else
            data[1] = data[1][2] and {data[1],Vector2.new(0,data[1][2])} or data
        end
        table.insert(toReplicate,data)
    end
    if #toReplicate >0 then
        EntityBridge:Fire(toReplicate)
    end
end
local Connection 
function Client.Init()
    if Connection then return end 
    EntityBridge:Connect(function(Entities,Key)
       if Key then Client.readKey(Key) end 
        for i,v in Entities do
            Client.handleData(v)
        end
    end)
    Connection = RunService.RenderStepped:Connect(function(deltaTime)
        Client.updateInterpolate(deltaTime)
    end)
    local clock1 = 0
    RunService.Heartbeat:Connect(function(deltaTime)
        clock1 += deltaTime
        if clock1 >= 1/20 then
            Client.replicateToServer()
            clock1 = 0
        end
    end)
    EntityBridge:Fire("CONNECTED")
end
return Client