local EntityAttribute = {}
local qf = require(game.ReplicatedStorage.QuickFunctions)
EntityAttribute.__index = function(self,key)
    return self.Data[key] or getmetatable(self)[key]
end
EntityAttribute.__newindex = function(self,key,value)
    self.Data[key] = value
end
EntityAttribute.__call = function(self,data)
    self.Data = data
end
EntityAttribute['EntityAttributes'] = true
function EntityAttribute.new(name,data,M)
    local k = {}
    if M then
        for i,v in EntityAttribute do
            k[i] = v
        end
        for i,v in M do
            k[i] = v
        end
    end
    return setmetatable({Data = type(data) == 'table' and data or {},Component = true,Name = name,Type = "EntityAttribute"},k)
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
function EntityAttribute:Clone()
    return setmetatable(qf.deepCopy(self),EntityAttribute)
end
function EntityAttribute:GetName()
    return self.Name
end
function EntityAttribute:GetReallen()
    local i = 0
    for i,v in self.Data do
        i+=1
    end
    return i 
end
function EntityAttribute:len()
    return #self.Data
end
function EntityAttribute:GetData()
    return self.Data
end
return EntityAttribute