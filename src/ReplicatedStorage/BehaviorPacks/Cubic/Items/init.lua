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

    ['C:Stick'] = cit(
    {
        type = 'Sword',
        Damage = 5,
        
    }),
    ['C:LongStick'] = cit(
    {
        type = 'Sword',
        Range = 120,
        KnockBackForce = Vector3.new(20,12,20),
        Damage = 0,
        
    }),
    ['C:GodStick'] = cit(
    {
        type = 'Sword',
        Range = 3,
        KnockBackForce = Vector3.new(50,30,50),
        Damage = 100,
        
    }),
}
