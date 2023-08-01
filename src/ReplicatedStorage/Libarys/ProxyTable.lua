local proxy = {}
local qf = require(game.ReplicatedStorage.QuickFunctions)
proxy.__index = function(self,key)
    return self.__P[key] or proxy[key]
end
proxy.__newindex = function(self,key,v)
   if self.__P[key] ~= v and rawget(self,"__Update") then
        self.__Update[key] = true
   end
    self.__P[key] = v
end
proxy.__iter = function(self)
    return next,self.__P
end
function proxy.new(data,SPEICAL)
    return setmetatable({__P = data or {},__type = "ProxyTable",__Update = not SPEICAL and {} or nil,__Speical = SPEICAL and true or nil},proxy)
end
local function dosomething(self,new,i)
    if self[i] == nil then
        new[i] = "__NULL__"
    elseif type(self[i]) == "table" and type(self[i]["Sterilize"]) == "function" then
        if  self[i].__Update then   new[i] = self[i]:Sterilize() end 
    elseif not qf.CompareTables(self.__P[i],(rawget(self,"__Last") or {})[i]) then
        new[i] = self[i] 
    end
end
function proxy:GetUpdated()
    local new = {}
    if rawget(self,"__Speical") then
        for i,v in self.__P do
            dosomething(self,new,i)
        end
        for i,v in self.__Last or {} do
            if new[i] then continue end 
            dosomething(self,new,i)
        end
    else
        for i,v in self.__Update do
            dosomething(self,new,i)
        end
    end
    return next(new) ~= nil and new or nil
end
function proxy:Clear()
    table.clear(self.__P)
end
function proxy:Sterilize()
    return self.__P
end
function proxy:ClearUpdated()
    table.clear(self.__Update or {} )
    if rawget(self,"__Speical") then
        rawset(self,"__Last", qf.deepCopy(self.__P))
    end
    for i,v in self.__P do
        if type(v) == "table" and typeof(v["ClearUpdated"]) == "function" then
            v:ClearUpdated()
        end
    end
end
function proxy:Destroy()
    table.clear(self)
end
return proxy