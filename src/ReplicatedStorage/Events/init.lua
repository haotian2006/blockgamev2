local ByteNet = require(game.ReplicatedStorage.Libarys.ByteNet)

return ByteNet.defineNamespace("CubicalWorld", function()
    return {
        AttackEntity = ByteNet.definePacket({value = ByteNet.string}),
        RespawnEntity = ByteNet.definePacket({value = ByteNet.nothing})
    }
end)
