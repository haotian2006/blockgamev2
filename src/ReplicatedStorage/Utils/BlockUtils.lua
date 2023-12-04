local Utils = {}
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandlerV2)
local rotationUtils = require(script.Parent.RotationUtils)
local BlockPool = require(game.ReplicatedStorage.BlockPool)

Utils.CONST_FALSE = BlockPool.CONST_FALSE
Utils.CONST_NULL  = BlockPool.CONST_NULL

function Utils.getName(self)
    return self[2]
end

function Utils.getFullName(self)
    return self[1]
end

function Utils.getData(self)
  
end

function Utils:getComponentData(self)
    
end

function Utils.getRotation(self)
    return rotationUtils.indexPairs[self[3] or 1]
end
 
function Utils.getRawRotation(self)
    return self[3] or 1
end

function Utils.getState(self)
    return self[4] or 1
end

function Utils.isFalse(self)
    return not self[1]
end

function Utils.isNULL(self)
    return  self[1] == "NULL"
end

function Utils.isFalseOrIsNULL(self)
    return (not self[1]) or self[1] == "NULL"
end



function Utils.equals(self,str)
    return self[2] == str
end

function Utils.equalStr(self,str)
    return  self == str or self[2] == str[2]
end

return Utils