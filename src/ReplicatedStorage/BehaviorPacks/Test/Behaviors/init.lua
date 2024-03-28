local Utils = require(game.ReplicatedStorage.EntityHandler.Utils)
local Handler = require(game.ReplicatedStorage.EntityHandler)

return {
    ['c:goToPlayer'] = {
        Function = function(entity,info)
          local found = false
           for i,v in Utils.getEntitiesNear(entity,10) do
            if not Handler.isType(v, 'Player') then
                continue
            end
           -- part.Position = Utils.getEyePosition(v)*3
            local direction = ((v.Position-entity.Position )*Vector3.new(1,0,1)).Unit*.3

            Handler.setMoveDireaction(entity,direction) 
           -- Utils.lookAt(entity,v)
            found = true
            break
           end
           if not found then
            Handler.setMoveDireaction(entity,Vector3.zero) 
            Handler.removeComponent(entity, "ManFaceMan")
           end
        end,
        Type = {"Movement","Turning"},
    }, 
   
} 