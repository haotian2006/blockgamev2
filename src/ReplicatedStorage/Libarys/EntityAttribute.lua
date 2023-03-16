local EntityAttribute = {}
EntityAttribute.__index = function(self,key)
    return self.Data[key] or EntityAttribute[key]
end
EntityAttribute.__call = function(self,data)
    self.Data = data
end
function EntityAttribute.new(name,data)
    return setmetatable({Data = data or {},Name = name,Type = "EntityAttribute"},EntityAttribute)
end
function EntityAttribute.create(data)
    return setmetatable(data,EntityAttribute)
end
function EntityAttribute:GetComponent()
    return self.Component
end
function EntityAttribute:SetComponent(c)
    self.Component = c
end
function EntityAttribute:GetName()
    return self.Name
end
function EntityAttribute:len()
    return #self.Data
end
function EntityAttribute:GetData()
    return self.Data
end
return EntityAttribute