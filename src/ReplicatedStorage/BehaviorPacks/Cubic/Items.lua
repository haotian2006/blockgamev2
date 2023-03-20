--[[
['Cubic:x'] = { --Name
        components= {
            maxCount = 64, -- max count

        }
    }
]]
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local crt = behhandler.CreateComponent
local cit = behhandler.CreateItemType
return{
    ['Cubic:Dirt'] = cit(
    {
        type = 'Block',
        Block = 'Cubic:Dirt'
    })
    
}