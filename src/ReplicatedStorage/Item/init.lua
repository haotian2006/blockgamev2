local Item = {}
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)



function Item.new(Name,Id)
    return {Name,Id or 1}
end

function Item.equals(x,y,c)
    if type(y) == "string" then
        local c1 = x[1] == y
        local c2 = if c then x[2] == c else true 
        return c1 and c2 
    end
    local c1 = x[1] == y[1]
    local c2 = x[2] == y[2]
    return c1 and c2 
end

function Item.getData(item)
    return BehaviorHandler.getItem(item[1]) 
end

function Item.getMaxCount(item)
    return (BehaviorHandler.getItem(item[1])  or {}).MaxCount or 64 
end

return Item 