local bridge = require(game.ReplicatedStorage.BridgeNet)
local Data = require(game.ReplicatedStorage.DataHandler)
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local AnimationBridge = bridge.CreateBridge("AnimationHandler")
local module = {}
module.PlayingAnimations = {}
function module.StopAnimations(entity)
    if module.PlayingAnimations[entity.Id] then
        local entityani = entity.PlayingAnimations or {}
        for i,v in module.PlayingAnimations[entity.Id] do
            if not entityani[i] then
                v:Stop()
                module.PlayingAnimations[entity.Id][i] = nil
            end
        end
    end
end
function module.UpdateEntity(entity)
    module.StopAnimations(entity)
    local AniPaths = resourcehandler.GetEntityModelDataFromData(entity)
    local animator = entity.Entity:FindFirstChild("AnimationController",true):FindFirstChildOfClass("Animator")
    if not AniPaths or not AniPaths.Animations or not animator then return end 
    AniPaths = AniPaths.Animations
    for i,v in entity.PlayingAnimations or {} do
        if not module.PlayingAnimations[entity.Id][i] and AniPaths[i] then
            module.PlayingAnimations[entity.Id][i] = animator:LoadAnimation(AniPaths[i])
            module.PlayingAnimations[entity.Id][i]:Play()
        end
    end
end
return module