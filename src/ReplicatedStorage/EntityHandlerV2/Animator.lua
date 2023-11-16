local Animator = {}
local Utils = require(script.Parent.Utils)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local BridgeNet = require(game.ReplicatedStorage.BridgeNet)
--local AnimationBridge = BridgeNet.CreateBridge("AnimationBridge")
local Runservice = game:GetService("RunService")
local IS_CLIENT = Runservice:IsClient()


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
function Animator.stop(self,animation,fadeTime)
    if IS_CLIENT and self.__loadedAnimations[animation] then
        self.__loadedAnimations[animation]:Stop(fadeTime)
    end
    self.__animations[animation] = nil
    
end
function Animator.stopAll(self,fadeTime)
    for i,v in self.__loadedAnimations or {} do
        v:Stop(fadeTime)
    end
    table.clear(self.__animations)
end
function Animator.play(self,animation,...)
    if IS_CLIENT then
        Animator.getOrLoad(self,animation):Play(...)
    end
end
function Animator.clear(self)
    table.clear(self.__animations)
    if IS_CLIENT then
        Animator.stopAll(self)
        table.clear(self.__loadedAnimations)
    end
end
if IS_CLIENT then
  --  AnimationBridge:Connect(function(uuid,animation,play)
    
    --end)
else
 --   AnimationBridge:Connect(function(player,uuid,animation,play)
        
  --  end)
end
return Animator