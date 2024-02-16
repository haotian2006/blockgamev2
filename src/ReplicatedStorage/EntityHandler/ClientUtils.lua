local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local Entities = ResourceHandler.getAllData().Entities

local Utils = {}

local OFFSETKEY = "RP_"

function Utils.getResource(self)
    return Entities[self.Type]
end

local function getKey(key)
    if type(key) == "string" then
        return OFFSETKEY..key
    end
    return key
end

function Utils.getAndCache(self,string)
    local special = getKey(string)
    if self[special] ~= nil then
        return self[special] 
    end
    local cached = self.__cachedData[special]
    if not cached then
        local data = Utils.get(self,string) 
        self.__cachedData[special] = data
        return data
    end
    return cached
end

function Utils.get(self,key)
    local special = getKey(string)
    if self[special] then return self[special] end 
    local data = Utils.getResource(self)
    local Variants = data.Variants
    for i,v in self.__components do
        local name = v.Name
        local vData = Variants[name]
        if not vData then continue end 
        if vData[key] then
            return vData[key]
        end
    end
    return data.Default[key]

end

return Utils