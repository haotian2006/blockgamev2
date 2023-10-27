local Animator = {}
local Utils = require(script.Parent.Utils)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local BridgeNet = require(game.ReplicatedStorage.BridgeNet)
local AnimationBridge = BridgeNet.CreateBridge("AnimationBridge")
local Runservice = game:GetService("RunService")
local IS_CLIENT = Runservice:IsClient()


function Animator.loadAnimation(self,animationName)
    if not IS_CLIENT then return warn("[METHOD] loadAnimation cannot be called from the server") end
    local model = self.__model 
    if not model then return end 
    local animator:Animator = model:FindFirstChild("AnimationController",true):FindFirstChildOfClass("Animator")
    local AniPaths = Utils.getDataFromResource(self,"Animations")
    local ani = AniPaths[animationName]
    if not ani or not animator then return end 
    ani = type(ani) == "string" and ResourceHandler.GetAnimationFromName(ani) or ani
    self.__animations[animationName] = animator:LoadAnimation(ani)
    return self.__animations[animationName] 
end
function Animator.getOrLoad(self,animation)
    return self.__animations[animation]  or Animator.loadAnimation(self,animation)
end
function Animator.remove(self,animation,fadeTime)
    Animator.stop(self,animation,fadeTime)
    self.__animations[animation] = nil
end
function Animator.stop(self,animation,fadeTime)
    if self.__animations[animation] then
        self.__animations[animation]:Stop(fadeTime)
    end
end
function Animator.play(self,animation,...)
    if self.__animations[animation] then
        self.__animations[animation]:Play(...)
    end
end
function Animator.clear(self)
    table.clear(self.__animations)
end
if IS_CLIENT then
    AnimationBridge:Connect(function(uuid,animation,play)
    
    end)
else
    AnimationBridge:Connect(function(player,uuid,animation,play)
        
    end)
end
return Animator