local Utils = require(game.ReplicatedStorage.EntityHandlerV2.Utils)
local part = Instance.new("Part")
part.Size = Vector3.new(2,.1,2)
part.Anchored = true
part.Parent = workspace
return {
    ['c:lookAtPlayer'] = {
        Function = function(entity,info)
           for i,v in Utils.getEntitiesNear(entity,10) do
            part.Position = Utils.getEyePosition(v)*3
            Utils.lookAt(entity,v)
           end
        end,
        Type = {"Movement","Turning"},
    }, 
   
}