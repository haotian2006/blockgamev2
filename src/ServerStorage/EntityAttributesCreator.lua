local EntityAttribute = require(game.ReplicatedStorage.Libarys.EntityAttribute)
local self = {}
self.Attributes = {}
self.Shared = {
    
}
self.Attributes.inventory = {
    new = function(info,comp)
        local newAtt = EntityAttribute.new('inventory',table.create(info or 0,''))
        newAtt:SetComponent(comp)
        return newAtt
    end,
    update = function(olddata,newinfo,comp)
        local data = olddata:GetData()
        if #data < newinfo then
            for i = #data+1, newinfo do
                data[i] = ""
            end
        elseif #data > newinfo then
            for i = newinfo+1, #data do
                data[i] = nil
            end
        end
        olddata:SetComponent(comp)
        return olddata
    end
}
function self.Find(name)
    return self.Attributes[name] or false
end
return self