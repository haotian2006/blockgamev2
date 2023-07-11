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
function proxy:GetUpdated()
    local new = {}
    if rawget(self,"__Speical") then
        for i,v in self do
            if not qf.CompareTables(self.__P,rawget(self,"__Last")) then
                new[i] = v
            end
        end
        for i,v in self.__Last or {} do
            if not self[i] then
                new[i] = "__NULL__"
            end
        end
    else
        for i,v in self.__Update do
            new[i] = if self[i] == nil then "__NULL__" else self[i] 
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
        rawset(self,"__Last", qf.deepCopy(self))
    end
end
function proxy:Destroy()
    table.clear(self)
end
return proxy