local types = {}
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local crt = behhandler.CreateComponent
--[[
    {
        maxCount = integer
        type = string
        OnInput = {
            InputName = Inputs       
            
        }
    }
]]
types.Block = {
    maxCount = 64,
    OnInput = {
        Interact = crt({
            Trigger = crt(
                {

                },
                'PlaceBlock'
            )
        },
        'Inputs'
    )
    }
}
return types 