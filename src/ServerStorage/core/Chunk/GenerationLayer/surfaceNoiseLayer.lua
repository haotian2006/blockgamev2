local Surface = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local Generator =  require(game.ServerStorage.core.Chunk.Generator)
local Layer = require(game.ServerStorage.core.Chunk.GenerationLayer)

function Surface.compute(layer,chunk)
  local biome = Layer.get(layer[2],chunk)
  local a,b,c,d = Generator.createDensityMap(chunk.X,chunk.Z,biome)
  return {a,b,c,d,biome}
end

return Surface