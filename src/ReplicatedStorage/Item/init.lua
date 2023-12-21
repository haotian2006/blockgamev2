local Item = {}
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)

function Item.new(Name,Count)
    return {Name,Count}
end

return Item 