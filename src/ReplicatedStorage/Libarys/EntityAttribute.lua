local EntityAttribute = {}
local qf = require(game.ReplicatedStorage.QuickFunctions)

EntityAttribute.__index = function(self,key)
    return   self.Data[key] or getmetatable(self)[key]
end
EntityAttribute.__newindex = function(self,key,value)
    self.Data[key] = value
    if self.Event then
        self.Event:fire(key,value)
    end
    if self.__Changed then
        self.__Changed(self,key,value)
    end
end
EntityAttribute.__call = function(self,data)
    self.Data = EntityAttribute.Desterilize(data)
end
function EntityAttribute.__eq(self,second)
    return qf.CompareTables(self,second)
end
EntityAttribute['EntityAttributes'] = true
function EntityAttribute.new(name:string,data:{},M:nil|table)
    local k = {}
    if M then
        for i,v in EntityAttribute do
            k[i] = v
        end
        for i,v in M do
            k[i] = v
        end
    end
    return setmetatable({Data = type(data) == 'table' and EntityAttribute.Desterilize(data) or {},Component = true,Name = name,Type = "EntityAttribute"},k)
end
function EntityAttribute.create(data:table)
    data.Event = nil
    data.Data = EntityAttribute.Desterilize(data.Data)
    return setmetatable(data,EntityAttribute)
end
function EntityAttribute:rawset(key:string,value:any)
    rawset(self.Data,key,value)
end
function EntityAttribute:GetComponent():table|nil
    return self.Component
end
function EntityAttribute:Sterilize():table
    return self:Copy()
end
function EntityAttribute.Desterilize(data):EntityAttribute
    local new = {}
    for i,v in data or {} do
        new[tonumber(i) or i] = v
    end
    return new
end
function EntityAttribute:SetComponent(c)
    self.Component = c
end
function EntityAttribute:Copy()
    return qf.deepCopy(self)
end
function EntityAttribute:Clone()
    return setmetatable(qf.deepCopy(self),EntityAttribute)
end
function EntityAttribute:GetName()
    return self.Name
end
function EntityAttribute:GetChangedEvent()
    self.Event = self.Event or require(game.ReplicatedStorage.Libarys.Signal).new()
    return self.Event
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
function EntityAttribute:Destroy()
    if self.Event then
        self.Event:DisconnectAll()
    end
    setmetatable(self,nil)
end
return EntityAttribute