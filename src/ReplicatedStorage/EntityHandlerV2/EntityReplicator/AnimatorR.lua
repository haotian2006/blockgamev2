local AnimatorR = {}
local Utils = require(script.Parent.Parent.Utils)
local BridgeNet = require(game.ReplicatedStorage.BridgeNet)
local AnimationBridge = BridgeNet.CreateBridge("AnimationBridge")
local Runservice = game:GetService("RunService")
local EntityHolder = require(script.Parent.Parent.EntityHolder)
local Animator: typeof(require(script.Parent.Parent.Animator))
local IS_CLIENT = Runservice:IsClient()
local Tasks = {
    'play',
    'stop',
    'stopAll',
    'adjustSpeed',
}
function AnimatorR.sendTask(entity,task,player,...)
    if entity.doReplication == false then return end 
    task = table.find(Tasks,task)
    if not task then return end 
    local guid = entity.Guid
    if IS_CLIENT then
        if not Utils.isOwner(entity,game.Players.LocalPlayer) then return end 
        if guid == tostring(game.Players.LocalPlayer.UserId) then
            guid = true
        end
        AnimationBridge:Fire(guid,task,...)
    else
        local ToFire = Utils.getPlayersNearEntity(entity)
        if player then 
            local idx = table.find(ToFire,player)
            if idx then 
                table.remove(ToFire,idx) 
            end 
         end 
         
        AnimationBridge:FireToMultiple(ToFire,guid,task,...)
    end
end

function AnimatorR.init(animator)
    Animator = animator
    if IS_CLIENT then

    AnimationBridge:Connect(function(uuid,task,...)
        local Entity = EntityHolder.getEntity(uuid)
        if not Entity then return end 
        Animator[Tasks[task]](Entity,...)
    end)
    
    else
    
    AnimationBridge:Connect(function(player,uuid,task,...)
        if uuid == true then
            uuid = tostring(player.UserId)
        end
        local Entity = EntityHolder.getEntity(uuid)
        if not Entity then return end 
        if not Utils.isOwner(Entity,player) then return end 
        if task == 1 then
            Animator.play2(Entity,...)
        elseif task == 2 then
            Animator.stop2(Entity,...)
        elseif task == 3 then
            Animator.stopAll2(Entity,...)
        elseif task == 4 then
            Animator.adjustSpeed2(Entity,...)
        end
      --  Animator[Tasks[task]](Entity,unpack(add))
    end)
        
    end
end
return AnimatorR