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
local function getSpeed(speed)
    return if speed  == -69 then nil else speed
end

function Animator.loadAnimation(self,animationName)
    if not IS_CLIENT then return warn("[METHOD] loadAnimation cannot be called from the server") end
    local model = self.model 
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

function Animator.playLocal(self,animation,looped,fadeTime,weight,speed)
    if IS_CLIENT then
        local ani = Animator.getOrLoad(self,animation)
        if not ani then return end 
        if looped then
            ani.Looped = looped
        end
        ani:Play(fadeTime,weight,getSpeed(speed))
        self.__animations[animation] = speed or  -69
    else
        self.__animations[animation] = speed or  -69
    end
end

function Animator.adjustSpeedLocal(self,animation,speed)
    if IS_CLIENT then
        local Ani =  Animator.getOrLoad(self,animation)
        if Ani then
            Ani:AdjustSpeed(getSpeed(speed))
        end
    else
        self.__animations[animation] = speed or  -69
    end
end

function Animator.adjustWeightLocal(self,animation,weight)
    if IS_CLIENT then
        local Ani =  Animator.getOrLoad(self,animation)
        if Ani then
            Ani:AdjustWeight(weight or 1)
        end
    else

    end
end

function Animator.stopLocal(self,animation,fadeTime)
    if IS_CLIENT and self.__loadedAnimations[animation] then
        self.__loadedAnimations[animation]:Stop(fadeTime)
        self.__animations[animation] = nil
    elseif not IS_CLIENT then
        self.__animations[animation] = nil
    end
end
function Animator.stopAllLocal(self,fadeTime)
    if IS_CLIENT then
        for i,v in self.__loadedAnimations or {} do
            v:Stop(fadeTime)
        end
    end
    table.clear(self.__animations)
end


function Animator.play(self,animation,looped,fadeTime,weight,speed)
    if IS_CLIENT then
        local Ani:AnimationTrack =  Animator.getOrLoad(self,animation)
        if Ani then
            if looped then
                Ani.Looped = looped
            end
            Ani:Play(fadeTime,weight,getSpeed(speed))
        end
    end
    self.__animations[animation] = speed or -69
    AnimatorR.sendTask(self,"play",false,animation,fadeTime,weight,speed,looped)
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
            Ani:AdjustSpeed(getSpeed(speed))
        end
    end
    speed = speed or 1
    if speed ==  self.__animations[animation]  then return end 
    self.__animations[animation] = speed or -69
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