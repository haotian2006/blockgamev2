local Worm = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator =  require(ChunkGeneration.Generator)
local Layer = require(ChunkGeneration.GenerationLayer)

function  Worm.compute(layer,chunk)
   local t = Generator.DoWork("computeWorms",chunk.X,chunk.Z)
   return t
end

return  Worm