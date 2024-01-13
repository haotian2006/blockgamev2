local Structure = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator =  require(ChunkGeneration.Generator)
local Layer = require(ChunkGeneration.GenerationLayer)

function  Structure.compute(layer,chunk,blocks,biomeAndSurface)
    local t,passed = Generator.DoWorkDefered("computeStructures",chunk.X,chunk.Z,blocks,biomeAndSurface)
    return t,passed
end

return  Structure