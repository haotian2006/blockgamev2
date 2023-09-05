--[[
['c:x'] = { --Name
        components= {
            maxCount = 64, -- max count

        }
    }
]]
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local crt = behhandler.CreateComponent
local cit = behhandler.CreateItemType
return{
    ['c:Dirt'] = cit(
    { 
        type = 'Block',
        Block = 'c:Dirt'
    }),
    ['c:Grass'] = cit(
    {
        type = 'Block',
        Block = 'c:Grass'
    }),
    ['c:Wood'] = cit(
    {
        type = 'Block',
        Block = 'c:Wood'
    }),
    ['c:Sand'] = cit(
        {
            type = 'Block',
            Block = 'c:Sand'
        }),
    ['c:Leaf'] = cit(
    {
        type = 'Block',
        Block = 'c:Leaf'
    }),
    ['c:Stone'] = cit(
    { 
        type = 'Block',
        Block = 'c:Stone',
    }),
    ['c:Bedrock'] = cit(
    {
        type = 'Block',
        Block = 'c:Bedrock'
    }),
    ['c:Stair'] = cit(
    {
        type = 'Block',
        Block = 'c:Stair'
    }),
    ['c:Slab'] = cit(
    {
        type = 'Block',
        Block = 'c:Stair'
    }),
    ['DebugPart'] = cit(
    {
        type = 'Block',
        Block = 'c:Stair'
    }),

    ['c:Stick'] = cit(
    {
        type = 'Sword',
        Damage = 5,
        
    }),
    ['c:LongStick'] = cit(
    {
        type = 'Sword',
        Range = 120,
        KnockBackForce = Vector3.new(20,12,20),
        Damage = 0,
        
    }),
    ['c:GodStick'] = cit(
    {
        type = 'Sword',
        Range = 3,
        KnockBackForce = Vector3.new(50,30,50),
        Damage = 100,
        
    }),
}
