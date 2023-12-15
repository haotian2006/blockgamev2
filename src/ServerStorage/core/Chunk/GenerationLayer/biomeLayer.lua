local layer = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local Generator =  require(game.ServerStorage.core.Chunk.Generator)
local Layer = require(game.ServerStorage.core.Chunk.GenerationLayer)

function layer.compute(layer,chunk)
    return Generator.createBiomeMap(chunk.X,chunk.Z)
end

return layer