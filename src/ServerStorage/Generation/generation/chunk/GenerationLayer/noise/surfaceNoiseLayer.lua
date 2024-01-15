local Surface = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator =  require(ChunkGeneration.Generator)
local Layer = require(ChunkGeneration.GenerationLayer)

function Surface.compute(layer,chunk)
  local biome = Layer.get(layer[2],chunk)
  local a,b,c,d = Generator.createDensityMap(chunk.X,chunk.Z,biome)
  return {a,b,c,d,biome}
end

return Surface 