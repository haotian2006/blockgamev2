local AnimatorR = {}
local Utils = require(script.Parent.Parent.Utils)
local Runservice = game:GetService("RunService")
local EntityHolder = require(script.Parent.Parent.EntityHolder)
local Animator
local IS_CLIENT = Runservice:IsClient()
local TaskReplicator = require(script.Parent.TaskReplicator)

local Tasks = {
    'play',
    'stop',
    'stopAll',
    'adjustSpeed',
    'adjustWeight',
}

local encodeFunc = {
    play = function(animation,fadeTime,weight,speed,looped)
        local v2 = if fadeTime or weight then Vector2.new(fadeTime or 0.100000001,weight or 1) else nil
        return {Vector2.new(1,speed or 1),animation,v2,looped}
    end,
    stop = function(animation,fadeTime)
        return {Vector2.new(2,fadeTime or 0.100000001),animation}
    end,
    stopAll = function(fadeTime)
        return Vector2.new(3,fadeTime or 0.100000001)
    end,
    adjustSpeed = function(animation,speed)
        return {Vector2.new(4,speed or 1),animation}
    end,
    adjustWeight = function(animation,weight)
        return {Vector2.new(5,weight or 1),animation}
    end,
}

local decodeFunc = {
    play = function(entity,data)
        local a = data[3] or {}

        Animator.play(entity,data[2],data[4],a.X,a.Y,data[1].Y,data)
    end,
    stop = function(entity,data)

        Animator.stop(entity,data[2],data[1].Y)
    end,
    stopAll = function(entity,data)
        Animator.stopAll(entity,data.Y)
    end,
    adjustSpeed = function(entity,data)
        Animator.adjustSpeed(entity,data[2],data[1].Y)
    end,
    adjustWeight = function(entity,data)
        Animator.adjustWeight(entity,data[2],data[1].Y)
    end,
}

local decodeFuncLocal = {
    play = function(entity,data)
        local a = data[3] or {}
        Animator.playLocal(entity,data[2],data[4],a.X,a.Y,data[1].Y)
    end,
    stop = function(entity,data)
        Animator.stopLocal(entity,data[2],data[1].Y)
    end,
    stopAll = function(entity,data)
        Animator.stopAll(entity,data.Y)
    end,
    adjustSpeed = function(entity,data)
        Animator.adjustSpeedLocal(entity,data[2],data[1].Y)
    end,
    adjustWeight = function(entity,data)
        Animator.adjustWeightLocal(entity,data[2],data[1].Y)
    end,
}

function AnimatorR.sendTask(entity,task,SendToOwner,...)
    if entity.doReplication == false then return end 
    local func = encodeFunc[task]
    if not func then return end 
    local guid = entity.Guid
    if IS_CLIENT then
       TaskReplicator.attachDataTo(guid,"Animator",func(...))
    else
        TaskReplicator.attachDataTo(guid,"Animator",func(...),SendToOwner)
    end
end

local function Receive(uuid,data)
    local Entity = EntityHolder.getEntity(uuid)
    if not Entity then return end 
    local decodedFunction
    if IS_CLIENT then
        if type(data) == "table" then
            decodedFunction= decodeFunc[Tasks[data[1].X]]
        else
            decodedFunction= decodeFunc[Tasks[data.X]]
        end
        decodedFunction(Entity,data)
    else
        if type(data) == "table" then
            decodedFunction= decodeFuncLocal[Tasks[data[1].X]]
        else
            decodedFunction= decodeFuncLocal[Tasks[data.X]]
        end
        decodedFunction(Entity,data)
        TaskReplicator.attachDataTo(uuid,"Animator",data)
    end
end

function AnimatorR.init(animator)
    Animator = animator
end

TaskReplicator.bind("Animator",Receive)

return AnimatorR