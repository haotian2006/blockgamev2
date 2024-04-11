local Events = require(game.ReplicatedStorage.Events)
local EntityHolder = require(game.ReplicatedStorage.EntityHandler.EntityHolder)
local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local DataHandler = require(game.ReplicatedStorage.Data)
local containerHandler = require(game.ReplicatedStorage.Handler.Container)
local Utils = EntityHandler.Utils

Events.AttackEntity.listen(function(data: string, player: Player?)  


    local e = EntityHolder.getEntity(data)
    local p = DataHandler.getEntityFromPlayer(player)
    if not e or not p then return end 

    local lookat = Utils.calculateLookAt(p)
    local dir:Vector3 = (lookat).Unit+Vector3.new(0,.5)
    EntityHandler.applyVelocity(e, Vector3.new(dir.X*100,dir.Y*30,dir.Z*100))
    EntityHandler.takeDamage(e, 5)
end)

Events.DropItem.listen(function(_,player)
    local p = DataHandler.getEntityFromPlayer(player)
    if  not p then return end 
    local item,loc,container = EntityHandler.getSlot(p)
    if container and item ~= "" then
        Utils.dropItem(p, item[1], 1)
        containerHandler.set(container, loc, item[1], item[2]-1)

    end
end)

return {}