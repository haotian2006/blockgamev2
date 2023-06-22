local BS = {}
local Block = {}
local debirs = require(game.ReplicatedStorage.Libarys.Debris)
local BSD = debirs.CreateFolder("BlockStore")
local qf = require(game.ReplicatedStorage.QuickFunctions)
local DEFAULT_TIME = 60
Block.Type = "block"
Block.__index = function(self,key)
    return self[2][key] or Block[key]
end
Block.__eq = function(a,b)
    return a.key == b.key
end
Block.__metatable = false
Block.__newindex = function(x,k)
    error(k .. " cannot be assigned to");
end
Block.__tostring = function(self)
    return self[1]
end
function Block.new(key,data)
    return setmetatable({key,data},Block)
end
function Block:getKey()
    return self[1]
end
function Block:getData()
    return self[2]
end
function BS:get(key)
    if BSD:GetItem(key) then
        BSD:SetTime(key,60)
    else
        BS:store(key,qf.DecompressItemData(key))
    end
    return BSD:GetItemData(key)
end
function BS:store(key,data)
    local v = Block.new(key,data)
    BSD:AddItem(key,v,DEFAULT_TIME)
    return v
end
return BS