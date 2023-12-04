local BlockPool = {}
BlockPool.Pool = {}
local rotationData = require(game.ReplicatedStorage.Utils.RotationUtils)
local behaviorhandler = require(game.ReplicatedStorage.BehaviorHandler)
local Pool = BlockPool.Pool
--//EXAMPLE BLOCK INFO: NameSpace:Block_Rotation_STATE EX: c:wool_1_2

local BlockState = {}
BlockState.__index = BlockState
BlockState.__newindex = function(self)
    error(`Attemped to modify Block '{self:getName()}'`)
end
BlockState.__metatable = function()
    warn("Cannot get metatable of Block")
end
BlockState.__tostring = function(self)
    return tostring(self[2])
end
BlockState.__eq = function(x,x2)
    return x[2] == x2[2]
end

function  BlockState.new(str:string)
    local name,r,state = str:match("([^,]*),?([^,]*),?([^,]*)")
    local block = setmetatable({{name,tonumber(r),tonumber(state)},str,1,behaviorhandler.GetBlock(name)},BlockState)
    return block
end
function BlockState:getName()
    return self[1][1]
end
function BlockState:increase()
     self[3] +=1
end
function BlockState:release()
    self[3] -=1
    if self[3] <=0 then
        Pool[self[2]] = nil
    end
end

function BlockState:bulkAdd(amt)
    self[3] += amt
    if self[3] <=0 then
        Pool[self[2]] = nil
    end
end

function BlockState:getRotation()
    return self[1][2] or 1
end

function BlockState:getData()
    return self[4] or {}
end

function BlockState:getComponentData()
    if self[1][3] and self[1][3] ~= 0 then
        return self[4].subComponents[self[1][3]]
    end
    return self[4].components
end

function BlockState:getFullRotation()
    return rotationData.indexPairs[self[1][2] or 1]
end

function BlockState:getState()
    return self[1][3] or 1
end

function BlockState:isFalse()
    return not self[2]
end

function BlockState:isNULL()
    return  self[2] == "NULL"
end

function BlockState:equal(str)
    return self:getName() == str
end

BlockPool.CONST_FALSE = setmetatable({{"false"},false,0},BlockState)
BlockPool.CONST_NULL =  setmetatable({{"NULL"},"NULL",0},BlockState)

function BlockPool:bulkAdd(str,amt)
    if Pool[str] then
        Pool[str][3] += amt 
    end
end

function BlockPool:bulkRelease(str,amt)
    if Pool[str] then
        Pool[str][3] -= amt
        if Pool[str][3] <= 0 then Pool[str] = nil end 
    end
end

function BlockPool:get(str)
    if not str or str == "false" then return BlockPool.CONST_FALSE end 
    if Pool[str] then
        Pool[str][3] += 1
        return Pool[str]
    end
    local new = BlockState.new(str)
    Pool[str] = new
    return new 
end

function BlockPool:getOrCreate(str)
    if not str or str == "false" then return BlockPool.CONST_FALSE end 
    if Pool[str] then
        return Pool[str]
    end
    local new = BlockState.new(str)
    Pool[str] = new
    return new 
end

function BlockPool:release(str)
    if not  Pool[str] then return end 
    Pool[str][3] -= 1
    if Pool[str][3] <= 0 then Pool[str] = nil end 
end

function BlockPool:doesExist(str)
    return Pool[str]
end

function BlockPool.createStr(fullname,r,p)
    return `{fullname},{rotationData.keyPairs[r]},{p}`
end

function BlockPool.createStrFromTable(tab)
    if tab[2] then
        tab[2] = rotationData.keyPairs[tab[2]]
    end
    return table.concat(tab,',')
end

return table.freeze(BlockPool)