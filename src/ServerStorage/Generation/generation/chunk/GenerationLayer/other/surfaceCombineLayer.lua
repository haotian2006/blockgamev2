local surfaceLayer = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator =  require(ChunkGeneration.Generator)
local Layer = require(ChunkGeneration.GenerationLayer)

function surfaceLayer.compute(layer,loc)
    local last = Layer.get(layer[2],loc)
    return if typeof(last[2]) == "buffer" then last[2] else Generator.surfaceCombine(unpack(last[2]))
end

return surfaceLayer