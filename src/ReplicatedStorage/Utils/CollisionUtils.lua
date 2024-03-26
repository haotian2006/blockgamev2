local Utils = {}
local CollisonHandler = require(game.ReplicatedStorage.CollisionHandler)

function Utils.doesBlockCollideWithEntityAt(block,at)
    local EntitiesAt = CollisonHandler.getEntitiesInBox(at, Vector3.new(3,3,3))
    
end