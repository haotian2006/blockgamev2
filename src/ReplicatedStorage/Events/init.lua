local ByteNet = require(game.ReplicatedStorage.Libs.ByteNet)

local cubicalWorld = ByteNet.defineNamespace("CubicalWorld", function()
    return {
        AttackEntity = ByteNet.definePacket({value = ByteNet.string}),
        RespawnEntity = ByteNet.definePacket({value = ByteNet.nothing}),
        PlayerFullyLoaded = ByteNet.definePacket({value = ByteNet.nothing}),

        UpdateBlock = ByteNet.definePacket({value = ByteNet.struct({
                [1] = ByteNet.vec3,
                [2] = ByteNet.int32
            })
    
        }),
        StartBreakingBlockClient = ByteNet.definePacket({value =ByteNet.struct({
            [1] = ByteNet.string,
            [2] = ByteNet.vec3,
            [3] = ByteNet.float32,
            [4] = ByteNet.float32
        })}),
        StartBreakingBlockServer = ByteNet.definePacket({value = ByteNet.vec3}),
        StopBreakingBlock = ByteNet.definePacket({value = ByteNet.optional(ByteNet.string)})
    }
end)

return cubicalWorld
