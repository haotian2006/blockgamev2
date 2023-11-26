local Animator = {}
local Utils = require(script.Parent.Utils)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local Runservice = game:GetService("RunService")
local EntityHolder = require(script.Parent.EntityHolder)
local IS_CLIENT = Runservice:IsClient()
local AnimatorR = require(script.Parent.EntityReplicator.AnimatorR)
AnimatorR.init(Animator)

function Animator.loadAnimation(self,animationName)
    if not IS_CLIENT then return warn("[METHOD] loadAnimation cannot be called from the server") end
    local model = self.__model 
    self.__loadedAnimations = self.__loadedAnimations or {}
    if not model then return end 
    local animator:Animator = model:FindFirstChild("AnimationController",true):FindFirstChildOfClass("Animator")
    --Utils.getDataFromResource(self,"Model")
    local AniPaths = (ResourceHandler.GetEntityModel("Player") or{}).Animations or {}
    local ani = AniPaths[animationName]
    if not ani or not animator then return warn(`Animation [{animationName}] or Animator does not exist`) end 
    ani = type(ani) == "string" and ResourceHandler.GetAnimationFromName(ani) or ani
    self.__loadedAnimations[animationName] = animator:LoadAnimation(ani)
    return self.__loadedAnimations[animationName] 
end
function Animator.getOrLoad(self,animation)
    if not IS_CLIENT then return end 
    self.__loadedAnimations = self.__loadedAnimations or {}
    return self.__loadedAnimations[animation]  or Animator.loadAnimation(self,animation)
end
function Animator.remove(self,animation,fadeTime)
    if IS_CLIENT then 
        Animator.stop(self,animation,fadeTime)
    end
    self.__animations[animation] = nil
end
function Animator.isPlaying(self,animation)
    return  self.__animations[animation]
end
function Animator.stop(self,animation,fadeTime,Player)
    if IS_CLIENT and self.__loadedAnimations[animation] then
        self.__loadedAnimations[animation]:Stop(fadeTime)
    end
    if  self.__animations[animation] ~= -1 then 
        AnimatorR.sendTask(self,"stop",Player,animation,fadeTime)
    end
    self.__animations[animation] = nil
end
function Animator.stopAll(self,fadeTime,player)
    for i,v in self.__loadedAnimations or {} do
        v:Stop(fadeTime)
    end
    table.clear(self.__animations)
    AnimatorR.sendTask(self,"stopAll",player,fadeTime)
end
function Animator.playLocal(self,animation,fadeTime,weight,speed)
    if IS_CLIENT then
        local ani = Animator.getOrLoad(self,animation)
        ani:Play(fadeTime,weight,speed)
        self.__animations[animation] = -1
    end
end
function Animator.adjustSpeedLocal(self,animation,speed)
    if IS_CLIENT then
        Animator.getOrLoad(self,animation):AdjustSpeed(speed or 0)
    end
end
function Animator.stopLocal(self,animation,fadeTime)
    if IS_CLIENT and self.__loadedAnimations[animation] then
        self.__loadedAnimations[animation]:Stop(fadeTime)
    end
    self.__animations[animation] = nil
end

function Animator.play(self,animation,fadeTime,weight,speed,Player)
    if IS_CLIENT then
        Animator.getOrLoad(self,animation):Play(fadeTime,weight,speed)
    end
    self.__animations[animation] = speed or 1
    AnimatorR.sendTask(self,"play",Player,animation,fadeTime,weight,speed)
end
function Animator.adjustSpeed(self,animation,speed,Player)
    if IS_CLIENT then
        Animator.getOrLoad(self,animation):AdjustSpeed(speed or 0)
    end
    self.__animations[animation] = 1
    AnimatorR.sendTask(self,"adjustSpeed",Player,animation,speed)
end
function Animator.clear(self)
    table.clear(self.__animations)
    if IS_CLIENT then
        Animator.stopAll(self)
        table.clear(self.__loadedAnimations)
    end
end

function Animator.play2(self,animation,fadeTime,weight,speed)
    if IS_CLIENT then
        Animator.getOrLoad(self,animation):Play(fadeTime,weight,speed)
    end
    self.__animations[animation] = speed or 1
    AnimatorR.sendTask(self,"play",Utils.getOwner(self),animation,fadeTime,weight,speed)
end
function Animator.stop2(self,animation,fadeTime)
    if IS_CLIENT and self.__loadedAnimations[animation] then
        self.__loadedAnimations[animation]:Stop(fadeTime)
    end
    if  self.__animations[animation] ~= -1 then 
        AnimatorR.sendTask(self,"stop",Utils.getOwner(self),animation,fadeTime)
    end
    self.__animations[animation] = nil
end
function Animator.stopAll2(self,fadeTime)
    for i,v in self.__loadedAnimations or {} do
        v:Stop(fadeTime)
    end
    table.clear(self.__animations)
    AnimatorR.sendTask(self,"stopAll",Utils.getOwner(self),fadeTime)
end
function Animator.adjustSpeed2(self,animation,speed)
    if IS_CLIENT then
        Animator.getOrLoad(self,animation):AdjustSpeed(speed or 1)
    end
    speed = speed or 1
    if speed ==  self.__animations[animation]  then return end 
    self.__animations[animation] = speed or 1
    AnimatorR.sendTask(self,"adjustSpeed",Utils.getOwner(self),animation,speed)
end
return Animator