local Tasks = game.ServerStorage.core.Chunk.Generator.Tasks
local ChunkLayer = require(game.ServerStorage.core.Chunk.Generator.ChunkLayer)

local shaper = require(Tasks.Shaper)

local BiomeLayer = {}

function BiomeLayer.compute(self,chunk)
    return shaper.createBiomeMap(chunk.X, chunk.Z)
end

return BiomeLayer 