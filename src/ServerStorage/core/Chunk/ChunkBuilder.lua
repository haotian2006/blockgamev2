local Builder = {}
local Data = require(game.ReplicatedStorage.Data)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator = require(ChunkGeneration.Generator)


function Builder.compress(buffer)
     return Generator.DoWork("compressBlockBuffer",buffer)
end
return Builder 