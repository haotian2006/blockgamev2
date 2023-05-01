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
        Block = 'C:Stone',
        functions = {

        },
        OnInput = {
            Interact = crt({
                HasToBeInHand = true,
                HasToBeInHotBar = true,
                Trigger = crt(
                    {
    
                    },
                    'PlaceBlock'
                )
            },
            'Inputs'
        )
        }

    }),
    ['C:Bedrock'] = cit(
    {
        type = 'Block',
        Block = 'C:Bedrock'
    }),
    ['C:Stair'] = cit(
    {
        type = 'Block',
        Block = 'C:Stair'
    }),
    ['C:Slab'] = cit(
    {
        type = 'Block',
        Block = 'C:Stair'
    }),
    ['DebugPart'] = cit(
    {
        type = 'Block',
        Block = 'C:Stair'
    }),

    ['Sword'] = cit(
    {
        type = 'Weapon',
        
    }),
}