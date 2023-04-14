--[[
['C:x'] = { --Name
        components= {
            maxCount = 64, -- max count

        }
    }
]]
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local crt = behhandler.CreateComponent
local cit = behhandler.CreateItemType
return{
    ['C:Dirt'] = cit(
    {
        type = 'Block',
        Block = 'C:Dirt'
    }),
    ['C:Grass'] = cit(
    {
        type = 'Block',
        Block = 'C:Grass'
    }),
    ['C:Stone'] = cit(
    {
        type = 'Block',
        Block = 'C:Stone'
    }),
    ['C:Bedrock'] = cit(
    {
        type = 'Block',
        Block = 'C:Bedrock'
    }),
    
}