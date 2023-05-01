local itemhand = {}
local qf,beh,reh,data 
function itemhand:Init()
    qf = require(game.ReplicatedStorage.QuickFunctions)
    beh = require(game.ReplicatedStorage.BehaviorHandler)
    reh = require(game.ReplicatedStorage.ResourceHandler)
    data = require(game.ReplicatedStorage.DataHandler)
    return self
end
function itemhand.Decompress(data,only)
    return qf.DecompressItemData(data,only)
end
function itemhand.GetItemData(item,only)
    return beh.GetItemData(itemhand.Decompress(item,only) or item )
end
function itemhand.GetItemType(item)
    local data = itemhand.GetItemData(item,"T")
    return data and data.type
end
function itemhand.IsA(item,type)
    local d =itemhand.GetItemData()
    return d and d:IsA(type)
end
function itemhand.GetInputs(item)
    local data = itemhand.GetItemData(item,"T")
    return data and data.OnInput
end
return itemhand