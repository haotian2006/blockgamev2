local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local Utils = {}
function Utils.getDataFromResource(self,string)
    local entityData = ResourceHandler.Entities[self.Type]
    if not entityData.components then
        return entityData[string] 
    end
    if #self.__componets > 0 and entityData.components_groups then
        for i,v in self.__componets do
           local group = entityData.components_groups[v.Name]
           if group and group[string] then
             return group[string]
           end
        end
    end
    return entityData.components[string]
end
return Utils 