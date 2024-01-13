local Item = {}
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)

function Item.new(Name,Id)
    return {Name,Id or 1}
end

function Item.getItemInfoR(self)
    local data = ResourceHandler.getItem(self[1])
    if not data then
        return {
            Name = self[1],
            DisplayName = "No Data Found",
            Id = self[2],
            Icon = ""
        }
    end
    return {
        Name = self[1],
        DisplayName = data.DisplayName or self[1],
        Id = self[2],
        Icon = data.Icon,
        Texture = data.Texture,
        Mesh = data.Mesh,
        RenderHand = data.RenderHand
    }
end

function Item.tostring(item)
    return `{item[1]}-{item[2] or 1}`
end

function Item.equals(x,y,Id)
    if type(y) == "string" then
        local c1 = x[1] == y
        local c2 = if Id then x[2] == Id else true 
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