local Utils = require(game.ReplicatedStorage.EntityHandler.Utils)
local Handler = require(game.ReplicatedStorage.EntityHandler)

return {
    ['c:lookAtPlayer'] = {
        Function = function(entity,info)
           for i,v in Utils.getEntitiesNear(entity,info.MaxRange or 20) do
           -- part.Position = Utils.getEyePosition(v)*3
            Utils.lookAt(entity,v)
            break
           end
        end,
        Type = {"Movement","Turning"},
    }, 
    ['c:ManFaceManSwitch'] = {
        Function = function(entity,info)
           for i,v in Utils.getEntitiesNear(entity,2) do
           -- part.Position = Utils.getEyePosition(v)*3
            --Utils.lookAt(entity,v)
            Handler.addComponent(entity, "ManFaceMan")
            break
           end
        end,
        Type = {},
    }, 
   
} 