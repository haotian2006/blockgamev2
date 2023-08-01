local EntityAttribute = {}
local qf = require(game.ReplicatedStorage.QuickFunctions)
local function TableIsADict(t)
    for i,v in t do
        if type(i) ~= "number" then
            return true
        end
    end
end
function EntityAttribute.deepCopy(original)
    if type(original) ~= "table" then return original end 
    local copy = {}
    for k, v in pairs(original) do
      if type(v) == "table" then
        v = qf.deepCopy(v)
      end
      copy[k] = v
    end
    return copy
  end
EntityAttribute.__type = "EntityAttribute"
EntityAttribute.__index = function(self,key)
    return   self.Data[key] or getmetatable(self)[key]
end
EntityAttribute.__newindex = function(self,key,value)
    if value == "__NULL__" then
        value = nil
    end
    if  self.Data[key] ~= value then
        rawset(self,"__Update",true)
        self.Data[key] = value
        if self.Event then
            self.Event:fire(key,value)
        end
        if self.__Changed then
            self.__Changed(self,key,value)
        end
    end
 --   if key == "Output" then error()end 
end
-- EntityAttribute.__call = function(self,data)
--       if data == nil then print(self,data,"1321") error( ) end 
--     self.Data = EntityAttribute.Desterilize(data)
-- end
function EntityAttribute.__eq(self,second)
    return qf.CompareTables(self,second)
end
function EntityAttribute:Update(new)
    self.Data = EntityAttribute.Desterilize(new)
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
    else
        k = EntityAttribute
    end
    if data then
        for i,v in data do
            if v == "__NULL__" then
                data[i] = nil
            end
        end
    end
    return setmetatable({Data = type(data) == 'table' and EntityAttribute.Desterilize(data) or {},Component = true,Name = name,__type = "EntityAttribute",__Update = false},k)
end
function EntityAttribute:UP()
    self.__Update = true
    if self.__OnUpdate then
        self.__OnUpdate(self)
    end
end
function EntityAttribute.create(data:table)
    data.Event = nil
    data.Data = EntityAttribute.Desterilize(data.Data)
    return EntityAttribute.new(data.Name,data.Data)
end
function EntityAttribute:rawset(key:string,value:any)
    rawset(self.Data,key,value)
end
function EntityAttribute:GetComponent():table|nil
    return self.Component
end
function EntityAttribute:Sterilize():table
    local data = {}
    local ea = self:Copy()
    local isad = TableIsADict(ea)
    for i,v in self.Data do
        data[isad and tostring(i) or i] =v
    end
    ea.Data = data
    ea.__Update = nil
    ea.Event = nil
    return ea
end
function EntityAttribute.Desterilize(data)
    local new = {}
    for i,v in data or {} do
        if v == "__NULL__" then
             continue  
        end
        new[tonumber(i) or i] = v
    end
    return new
end
function EntityAttribute:SetComponent(c)
    self:UP()
    self.Component = c
end
function EntityAttribute:Copy()
    return self:deepCopy()
end
function EntityAttribute:Clone()
    local c =self:deepCopy()
    return EntityAttribute.new(c.Name,c.Data)
end
function EntityAttribute:GetName()
    return self.Name
end
function  EntityAttribute:GetUpdated()
    if self.__Update then
        return self:Sterilize()
    end
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
function EntityAttribute:ClearUpdated()
   self.__Update = false
end
function EntityAttribute:Destroy()
    if self.Event then
        self.Event:DisconnectAll()
    end
    table.clear(self)
    setmetatable(self,nil)
end
return EntityAttribute