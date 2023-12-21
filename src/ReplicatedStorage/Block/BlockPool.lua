local BlockPool = {}
local Pool = {}
local rotationData = require(game.ReplicatedStorage.Utils.RotationUtils)
local BlockId =require(script.Parent)


local Block = {}

function Block.new(str:string)
    local name,r,state = str:match("([^,]*),?([^,]*),?([^,]*)")
    local block = table.freeze({str,name,tonumber(r) or 1,tonumber(state)})
    return block
end

BlockPool.CONST_FALSE = table.freeze({false,"false"})
BlockPool.CONST_NULL  = table.freeze({"NULL","NULL"})

function BlockPool.bulkAdd(str,amt)
    local block = Pool[str]
    if block then
        block[2] += amt 
    end
end

function BlockPool.bulkRelease(str,amt)
    local block = Pool[str]
    if block then
        block[2] -= amt
        if block[2] <= 0 then Pool[str] = nil end 
    end
end

function BlockPool.get(str)
    if not str or str == "false" then return BlockPool.CONST_FALSE end 
    local block = Pool[str]
    if block then
        block[2] += 1
        return block[1] 
    end
    local new = Block.new(str)
    Pool[str] = {new,1}
    return new 
end
function BlockPool.getFromIdx(idx,times)
    local str = BlockId.getBlock(idx)
    if not str or str == "false" or str == "c:air" then return BlockPool.CONST_FALSE end 
    local block = Pool[str]
    if block then
        block[2] += times or 1
        return block[1] 
    end
    local new = Block.new(str)
    Pool[str] = {new,times or 1}
    return new 
end


function BlockPool.release(str)
    local block = Pool[str]
    if not block then return end 
    block[2] -= 1
    if block[2] <= 0 then Pool[str] = nil end 
end

function BlockPool.find(str)
    local block = Pool[str]
    return block and block[1] or nil
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