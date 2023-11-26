local tasks = {}
local RunService = game:GetService("RunService")
local BridgeNet = require(game.ReplicatedStorage.BridgeNet)
local EntityTasksBridge = BridgeNet.CreateBridge("EntityBridgeT")
local IS_CLIENT = RunService:IsClient()
local EntityV2 = game.ReplicatedStorage.EntityHandlerV2
local EntityHolder = require(EntityV2.EntityHolder)
local EntityHandler = require(EntityV2)
local Tasks = {}
if IS_CLIENT then
else

function Tasks.Crouch(Entity,IsDown,player)
    EntityHandler.crouch(Entity,IsDown,player)
end


end
function tasks.doTask(Entity,task,data)
    if IS_CLIENT then 
        EntityTasksBridge:Fire(Entity.Guid,task,data)
    else
        local owner = EntityHandler.getOwner(Entity)
        if not owner then return false end
        EntityTasksBridge:FireTo(owner,Entity.Guid,task,data)
    end
    return true
end
function tasks.init()
    if IS_CLIENT then

    else
        EntityTasksBridge:Connect(function(player,uuid,task,data)
            local Entity = EntityHolder.getEntity(uuid)
            if not Entity then return end 
            if not EntityHandler.isOwner(Entity,player) then return end 
            if Tasks[task] then
                Tasks[task](Entity,data,player)
            end
        end)
    end
end
return table.freeze(tasks)