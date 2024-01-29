local Tasks = game.ServerStorage.core.Chunk.Generator.Tasks
local ChunkLayer = require(game.ServerStorage.core.Chunk.Generator.ChunkLayer)


local shaper = require(Tasks.Shaper)

local SubLayer = {}
local quadData = {
    {0,0},
    {1,0},
    {0,1},
    {1,1}
}
function SubLayer.compute(self,chunk)
    local biomes = ChunkLayer.get(self[2],Vector3.new(chunk.X,0,chunk.Z))
    local quad = quadData[chunk.Y]
    local qx,qz = quad[1],quad[2]
    local data = shaper.sampleDensityNoise(chunk.X, chunk.Z,qx,qz,biomes)
    return data
end

return SubLayer 