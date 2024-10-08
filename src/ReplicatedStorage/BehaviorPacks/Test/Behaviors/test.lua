local Utils = require(game.ReplicatedStorage.Handler.EntityHandler.Utils)
local Handler = require(game.ReplicatedStorage.Handler.EntityHandler)

return {
        Function = function(entity,info)
          local found = false
           for i,v in Utils.getEntitiesNear(entity,10) do
            if not Handler.isType(v, 'Player') then
              continue
          end
           -- part.Position = Utils.getEyePosition(v)*3
            local direction = ((v.Position-entity.Position )*Vector3.new(1,0,1)).Unit*.3
            Handler.setMoveDirection(entity,direction) 
           -- Utils.lookAt(entity,v)
            found = true
            break
           end
           if not found then
            Handler.setMoveDirection(entity,Vector3.zero) 
            Handler.removeComponent(entity, "ManFaceMan")
           end
        end,
        Type = {"Movement","Turning"},
    }
   
