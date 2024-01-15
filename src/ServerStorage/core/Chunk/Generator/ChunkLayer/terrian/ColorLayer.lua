local Tasks = game.ServerStorage.core.Chunk.Generator.Tasks
local ChunkLayer = require(game.ServerStorage.core.Chunk.Generator.ChunkLayer)


local shaper = require(Tasks.Shaper)

local Color = {}

function Color.compute(self,chunk,Shape,surface,biome)
    return shaper.color(chunk.X, chunk.Z, Shape, surface, biome)
end

return Color 