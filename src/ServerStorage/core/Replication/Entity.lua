local Events = require(game.ReplicatedStorage.Events)
local EntityHolder = require(game.ReplicatedStorage.EntityHandler.EntityHolder)
local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local DataHandler = require(game.ReplicatedStorage.Data)
local Utils = EntityHandler.Utils

Events.AttackEntity.listen(function(data: string, player: Player?)  


    local e = EntityHolder.getEntity(data)
    local p = DataHandler.getEntityFromPlayer(player)
    if not e or not p then return end 

    local lookat = Utils.calculateLookAt(p)
    local dir:Vector3 = (lookat).Unit+Vector3.new(0,.5)
    --EntityHandler.applyVelocity(e, Vector3.new(dir.X*100,dir.Y*30,dir.Z*100))
    EntityHandler.takeDamage(e,false, 5)
end)

return {}