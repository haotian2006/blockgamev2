local bridge = require(game.ReplicatedStorage.BridgeNet)
local Data = require(game.ReplicatedStorage.DataHandler)
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local AnimationBridge = bridge.CreateBridge("AnimationHandler")
local run = game:GetService("RunService")
local anievent = bridge.CreateBridge("PlayAnimation")
anievent:Connect(function(...)
    if run:IsServer() then
        local plr,entity,name = ...
        anievent:FireToAllExcept(plr,entity,name)
    else
        local entity,name = ...
        if not Data.LoadedEntities[entity]then return end 
        Data.LoadedEntities[entity]:PlayAnimation(name,true)
    end
end)
local module = {}
function module.StopAllAnimations(entity,ALL)
    if entity.ClientAnim then
        local entityani = entity.PlayingAnimations or {}
        for i,v in entity.ClientAnim do
            if not entityani[i] then
                if ALL then
                    module.StopAnimation(entity,i)
                end
                v:Stop()
                entity.ClientAnim[i] = nil
            end
        end
    end
end
function module.StopAnimation(entity,animation)
    if entity.LoadedAnis[animation] then
        entity.LoadedAnis[animation]:Stop()
        entity.LoadedAnis[animation] = nil
    end
end
function module.LoadAnimation(entity,animation)
    entity.LoadedAnis = entity.LoadedAnis or {}
    if entity.LoadedAnis[animation] then  return entity.LoadedAnis[animation] end 
    local AniPaths = resourcehandler.GetEntityFromData(entity)
    local animator = entity.Entity:FindFirstChild("AnimationController",true):FindFirstChildOfClass("Animator")
    if not AniPaths or not AniPaths.Animations or not animator then return end 
    AniPaths = AniPaths.Animations
    local animationinstance = type(AniPaths[animation]) == "string" and resourcehandler.GetAnimationFromName(AniPaths[animation]) or AniPaths[animation]
    if animationinstance then
        entity.LoadedAnis = entity.LoadedAnis or {}
        entity.LoadedAnis[animation] = entity.LoadedAnis [animation] or animator:LoadAnimation(animationinstance)
        return entity.LoadedAnis[animation]
    end
end
function module.PlayAnimationOnce(entity,animation)
    local ani = module.LoadAnimation(entity,animation)
    if ani then ani:Play() end
end
function module.UpdateEntity(entity)
    module.StopAllAnimations(entity)
    local AniPaths = resourcehandler.GetEntityFromData(entity)
    local animator = entity.Entity:FindFirstChild("AnimationController",true):FindFirstChildOfClass("Animator")
    if not AniPaths or not AniPaths.Animations or not animator then return end 
    AniPaths = AniPaths.Animations
    for i,v in entity.PlayingAnimations or {} do
        entity.ClientAnim = entity.ClientAnim or {}
        local animation = module.LoadAnimation(entity,i)
        if not entity.ClientAnim[i] and animation and v  then
            entity.ClientAnim[i] = animation
            entity.ClientAnim[i]:Play()
        end
    end
end
return module