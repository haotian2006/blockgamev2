local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local Blocks = {
    Normal = Vector3.new(1,1,1),
    Slab = {
        Side1 = {
            Size = Vector3.new(1,0.5,1),
            Offset = Vector3.new(0,-0.25,0)
        },
    },
    Stair = {
        Side1 = {
            Size = Vector3.new(1,0.5,1),
            Offset = Vector3.new(0,-0.25,0)
        },
        Side2 = {
            Size = Vector3.new(1,1,.5),
            Offset = Vector3.new(0,0,.25)
        }
    }
}
return Blocks