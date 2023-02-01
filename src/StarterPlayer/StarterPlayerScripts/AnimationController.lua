local bridge = require(game.ReplicatedStorage.BridgeNet)
local Data = require(game.ReplicatedStorage.DataHandler)
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local AnimationBridge = bridge.CreateBridge("AnimationHandler")
local module = {}
function module.StopAnimations(entity)
    if entity.ClientAnim then
        local entityani = entity.PlayingAnimations or {}
        for i,v in entity.ClientAnim do
            if not entityani[i] then
                v:Stop()
                entity.ClientAnim[i] = nil
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
        entity.ClientAnim = entity.ClientAnim or {}
        if not entity.ClientAnim[i] and AniPaths[i] and v  then
            entity.ClientAnim[i] = animator:LoadAnimation(AniPaths[i])
            entity.ClientAnim[i]:Play()
        end
    end
end
return module