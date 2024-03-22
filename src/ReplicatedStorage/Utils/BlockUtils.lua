local Utils = {}
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local rotationUtils = require(script.Parent.RotationUtils)

function Utils.getName(self)
    return self[2]
end



return Utils