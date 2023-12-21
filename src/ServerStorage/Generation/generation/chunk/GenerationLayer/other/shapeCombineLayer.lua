local shapeLayer = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator =  require(ChunkGeneration.Generator)
local Layer = require(ChunkGeneration.GenerationLayer)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local offsetTable = {
    Vector3.zero,
    Vector3.new(4),
    Vector3.new(0,0,4),
    Vector3.new(4,0,4)
}
function shapeLayer.compute(layer,chunk)
    local last = Layer.get(layer[2],chunk)
    return if typeof(last[1]) == "buffer" then last[1] else Generator.shapeCombine(unpack(last[1]))
end

return shapeLayer