local Utils = {}
local CollisonHandler = require(game.ReplicatedStorage.CollisionHandler)

Utils.createEntityParams = CollisonHandler.createEntityParams

local BlockParams = CollisonHandler.createEntityParams(nil, {"c:Item"})
function Utils.doesBlockCollideWithEntityAt(block,at,params)
    local EntitiesAt = CollisonHandler.getEntitiesInBox(at, Vector3.new(1,1,1),params or BlockParams)
    return #EntitiesAt > 0 
end

return Utils