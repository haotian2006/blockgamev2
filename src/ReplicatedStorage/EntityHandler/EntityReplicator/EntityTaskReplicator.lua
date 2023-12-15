local tasks = {}
local RunService = game:GetService("RunService")
local IS_CLIENT = RunService:IsClient()
local EntityV2 = game.ReplicatedStorage.EntityHandler
local EntityHolder = require(EntityV2.EntityHolder)
local EntityHandler 
local TaskReplicator = require(script.Parent.TaskReplicator)
local TaskOrder = {
    "Crouch"
}
local decodeFunctions = {
    Crouch = function(Entity,data)
        local value1 = bit32.band(data.Y, 1)
        local value2 = bit32.band(bit32.rshift(data.Y, 1), 1)
        EntityHandler.crouch(Entity,value1 == 1, value2 == 1)
    end
}
local encodeFunctions = {
    Crouch = function(Entity,isDown,fromClient)
        local v = isDown and 1 or 0
        local v2 = fromClient and 1 or 0
        return Vector2int16.new(1,bit32.bor(v, bit32.lshift(v2, 1)))
    end
}


function tasks.doTask(Entity,task,SendToOwner,...)
    local encodeFunction = encodeFunctions[task]
    if not encodeFunction then return false end 
    if IS_CLIENT then 
        TaskReplicator.attachDataTo(Entity.Guid,"Task",encodeFunction(Entity,...))
    else
        TaskReplicator.attachDataTo(Entity.Guid,"Task",encodeFunction(Entity,...),SendToOwner)
    end
    return true
end

local function handleTask(uuid,data)
    local Entity = EntityHolder.getEntity(uuid)
    if not Entity then return end 
    local defunc 
    if type(data) == "table" then
        defunc= decodeFunctions[TaskOrder[data[1].X]]
    else
        defunc= decodeFunctions[TaskOrder[data.X]]
    end
    defunc(Entity,data)
end

function tasks.Init(handler)
    EntityHandler = handler
end
TaskReplicator.bind("Task",handleTask)
return table.freeze(tasks)