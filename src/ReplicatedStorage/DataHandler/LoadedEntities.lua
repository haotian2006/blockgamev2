local lem = {}
lem.__index = lem
function lem.new()
    return setmetatable({__Changed = false,__P = {}},lem)
end
function lem:Find(value)
    return table.find(self.__P,value)
end
function lem:AddEntity(id)
    local i = self:Find(id)
    if i then return i end 
    table.insert(self.__P,id)
    self.__Changed = true
    return self:Find(id)
end
function lem:RemoveEntity(id)
    local i = self:Find(id)
    if not i then return end 
    table.remove(self.__P,i)
    self.__Changed = true
end
function lem:Clear()
    table.clear(self.__P)
end
function lem:Update(new)
    for i,v in self.__P do
        if not new[v] then
            self:RemoveEntity(v)
        end
    end
    for i,v in new do
        self:AddEntity(i)
    end
end
function lem:Get()
    if self.__Changed then
        self.__Changed = false
        return self.__P
    end
end

local idk = {}
local Store = {}
function idk.Get(player)
    if not idk[player] then
        idk[player] = lem.new()
    end
    return idk[player]
end
function idk.Remove(player)
    idk[player] = nil
end
return idk