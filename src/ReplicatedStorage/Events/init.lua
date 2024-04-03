local ByteNet = require(game.ReplicatedStorage.Libs.ByteNet)

local cubicalWorld = ByteNet.defineNamespace("CubicalWorld", function()
    return {
        AttackEntity = ByteNet.definePacket({value = ByteNet.string}),
        RespawnEntity = ByteNet.definePacket({value = ByteNet.nothing}),
        PlayerFullyLoaded = ByteNet.definePacket({value = ByteNet.nothing}),
    }
end)

return cubicalWorld
