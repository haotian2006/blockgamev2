local BS = {}
local Block = {}
local debirs = require(game.ReplicatedStorage.Libarys.Debris)
local BSD = debirs.CreateFolder("BlockStore")
local qf = require(game.ReplicatedStorage.QuickFunctions)
local reh = require(game.ReplicatedStorage.ResourceHandler)
local DEFAULT_TIME = 60
Block.Type = "store"
Block.__index = Block
Block.__eq = function(a,b)
    return a[1] == b[1]
end
Block.__metatable = false
Block.__newindex = function(x,k)
    error(k .. " cannot be assigned to");
end 
function Block.new(key,data,time)
    return setmetatable({key,data,time},Block)
end
function Block:getKey()
    return self[1]
end
function Block:getData()
    return self[2]
end
function Block:IsA(t)
    return self[2].T == t
end
BS.Predefined = {
    empty = Block.new("",{}),
    [false] = Block.new(false,{}),
    NULL = Block.new("NULL",{}),
}
function BS:get(key,time) 
    if key == true then
         error("NO TRUE")
    end
    if self.Predefined[key] then
        return self.Predefined[key]
    end
    if BSD:GetItem(key) then
        BSD:SetTime(key,BSD:GetItem(key)[3] or 60)
    else
        local d = qf.DecompressItemData(key)
        d.Data = reh.GetBlock(d.T)
        BS:store(key,d,time)
    end
    return BSD:GetItemData(key)
end
function BS:store(key,data,time)
    local v = Block.new(key,data,time)
    BSD:AddItem(key,v,time or DEFAULT_TIME)
    return v
end
return BS