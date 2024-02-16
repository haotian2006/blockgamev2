local Animator = {}
local Utils = require(script.Parent.Utils)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local Runservice = game:GetService("RunService")
local EntityHolder = require(script.Parent.EntityHolder)
local IS_CLIENT = Runservice:IsClient()
local AnimatorR = require(script.Parent.EntityReplicator.AnimatorR)
local ClientUtils = require(script.Parent.ClientUtils)
AnimatorR.init(Animator)

local a = Instance.new("Animation",script)

function Animator.loadAnimation(self,animationName)
    if not IS_CLIENT then return warn("[METHOD] loadAnimation cannot be called from the server") end
    local model = self.__model 
    self.__loadedAnimations = self.__loadedAnimations or {}
    if not model then return end 
    local animator:Animator = model:FindFirstChild("AnimationController",true):FindFirstChildOfClass("Animator")
    local AniPaths = ClientUtils.getAndCache(self, "Animations") or {}
    local ani = AniPaths[animationName]
    if not ani or not animator then 
        return --warn(`Animation [{animationName}] or Animator does not exist`) 
    end 
    ani = type(ani) == "string" and ResourceHandler.getAnimationFromName(ani) or ani
    self.__loadedAnimations[animationName] = animator:LoadAnimation(ani)
    return self.__loadedAnimations[animationName] 
end
function Animator.getOrLoad(self,animation)
    if not IS_CLIENT then return end 
    self.__loadedAnimations = self.__loadedAnimations or {}
    return self.__loadedAnimations[animation]  or Animator.loadAnimation(self,animation) 
end
function Animator.get(self,animation)
    if not IS_CLIENT then return end 
    return self.__loadedAnimations[animation]
end
function Animator.remove(self,animation,fadeTime)
    if IS_CLIENT then 
        Animator.stop(self,animation,fadeTime)
    end
    self.__animations[animation] = nil
end
function Animator.getSpeed(self,Animation)
    return  self.__animations[Animation]
end
function Animator.clear(self)
    table.clear(self.__animations)
    if IS_CLIENT then
        Animator.stopAll(self)
        table.clear(self.__loadedAnimations)
    end
end

function Animator.isPlaying(self,animation)
    return  self.__animations[animation] and true or false
end
function Animator.play2(self,animation,fadeTime,weight,speed,SendToOwner)
    SendToOwner = if SendToOwner ==nil then true else false
    if IS_CLIENT then
        local Ani =  Animator.getOrLoad(self,animation)
        if Ani then
            Ani:Play(fadeTime,weight,speed)
        end
    end
    self.__animations[animation] = speed or 1
    AnimatorR.sendTask(self,"play",SendToOwner,animation,fadeTime,weight,speed)
end
function Animator.adjustSpeed2(self,animation,speed,SendToOwner)
    SendToOwner = if SendToOwner ==nil then true else false
    if IS_CLIENT then
        local Ani =  Animator.getOrLoad(self,animation)
        if Ani then
            Ani:AdjustSpeed(speed or 1)
        end
    end
    self.__animations[animation] = 1
    AnimatorR.sendTask(self,"adjustSpeed",SendToOwner,animation,speed)
end
function Animator.adjustWeight2(self,animation,weight,SendToOwner)
    SendToOwner = if SendToOwner ==nil then true else false
    if IS_CLIENT then
        local Ani =  Animator.getOrLoad(self,animation)
        if Ani then
            Ani:AdjustWeight(weight or 1)
        end
    end
    AnimatorR.sendTask(self,"adjustWeight",SendToOwner,animation,weight)
end

function Animator.stop2(self,animation,fadeTime,SendToOwner)
    SendToOwner = if SendToOwner ==nil then true else false
    if IS_CLIENT and self.__loadedAnimations[animation] then
        self.__loadedAnimations[animation]:Stop(fadeTime)
    end
    AnimatorR.sendTask(self,"stop",SendToOwner,animation,fadeTime)
    self.__animations[animation] = nil
end

function Animator.stopAll2(self,fadeTime,SendToOwner)
    SendToOwner = if SendToOwner ==nil then true else false
    for i,v in self.__loadedAnimations or {} do
        v:Stop(fadeTime)
    end
    table.clear(self.__animations)
    AnimatorR.sendTask(self,"stopAll",SendToOwner,fadeTime)
end

function Animator.playLocal(self,animation,fadeTime,weight,speed)
    if IS_CLIENT then
        local ani = Animator.getOrLoad(self,animation)
        if not ani then return end 
        ani:Play(fadeTime,weight,speed)
        self.__animations[animation] = speed or 1
    end
end
function Animator.adjustSpeedLocal(self,animation,speed)
    if IS_CLIENT then
        local Ani =  Animator.getOrLoad(self,animation)
        if Ani then
            Ani:AdjustSpeed(speed or 1)
        end
    end
end
function Animator.adjustWeightLocal(self,animation,weight)
    if IS_CLIENT then
        local Ani =  Animator.getOrLoad(self,animation)
        if Ani then
            Ani:AdjustWeight(weight or 1)
        end
    end
end
function Animator.stopLocal(self,animation,fadeTime)
    if IS_CLIENT and self.__loadedAnimations[animation] then
        self.__loadedAnimations[animation]:Stop(fadeTime)
        self.__animations[animation] = nil
    end
end


function Animator.play(self,animation,fadeTime,weight,speed)
    if IS_CLIENT then
        local Ani =  Animator.getOrLoad(self,animation)
        if Ani then
            Ani:Play(fadeTime,weight,speed)
        end
    end
    self.__animations[animation] = speed or 1
    AnimatorR.sendTask(self,"play",false,animation,fadeTime,weight,speed)
end
function Animator.stop(self,animation,fadeTime)
    if IS_CLIENT and self.__loadedAnimations[animation] then
        self.__loadedAnimations[animation]:Stop(fadeTime)
    end
    if  self.__animations[animation] ~= -1 then 
        AnimatorR.sendTask(self,"stop",false,animation,fadeTime)
    end
    self.__animations[animation] = nil
end
function Animator.stopAll(self,fadeTime)
    for i,v in self.__loadedAnimations or {} do
        v:Stop(fadeTime)
    end
    table.clear(self.__animations)
    AnimatorR.sendTask(self,"stopAll",false,fadeTime)
end
function Animator.adjustSpeed(self,animation,speed)
    if IS_CLIENT then
        local Ani =  Animator.getOrLoad(self,animation)
        if Ani then
            Ani:AdjustSpeed(speed or 1)
        end
    end
    speed = speed or 1
    if speed ==  self.__animations[animation]  then return end 
    self.__animations[animation] = speed or 1
    AnimatorR.sendTask(self,"adjustSpeed",true,animation,speed)
end
function Animator.adjustWeight(self,animation,weight)
    if IS_CLIENT then
        local Ani =  Animator.getOrLoad(self,animation)
        if Ani then
            Ani:AdjustWeight(weight or 1)
        end
    end
    AnimatorR.sendTask(self,"adjustWeight",false,animation,weight)
end
return Animator