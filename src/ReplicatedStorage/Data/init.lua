local Data = {}
local EntityHolder = require(game.ReplicatedStorage.EntityHandlerV2.EntityHolder)
Data.EntityHolder = EntityHolder
Data.Chunks = {}
Data.Other = {}
Data.PlayerEntity = nil
function Data.addEntity(Entity)
    EntityHolder.addEntity(Entity)
end
function Data.getEntity(Guid)
    return EntityHolder.getEntity(Guid)
end
function Data.getAllEntities()
    return EntityHolder.getAllEntities()
end
function Data.set(key,value)
    Data.Other[key] = value
end
function Data.get(key)
    return Data.Other[key]
end 
function Data.getPlayerEntity()
    return Data.LocalPlayer
end
function Data.setPlayerEntity(e)
    Data.LocalPlayer = e
end
return Data