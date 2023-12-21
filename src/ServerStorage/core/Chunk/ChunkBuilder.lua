local Builder = {}
local Data = require(game.ReplicatedStorage.Data)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator = require(ChunkGeneration.Generator)
local Layers = require(ChunkGeneration.GenerationLayer)
local OverWorld = require(script.Parent.OverworldStack)

function Builder.color(chunk,Shape,Surface,Biome)
    return Generator.DoWork("color",chunk.X,chunk.Z,Shape,Surface,Biome)
end
function Builder.buildChunk(chunk)
    local Shape = Layers.compute(OverWorld.Terrain,chunk)
    local Surface = Layers.compute(OverWorld.Surface,chunk)
    local Biome = Layers.get(OverWorld.Biome,chunk)
 --   local caves = Layers.compute(OverWorld.Caves,chunk)
   -- local combined = Generator.DoWork("carve",Shape,caves)
    local colored = Builder.color(chunk,Shape,Surface,Biome)
    local compressed = Generator.DoWork("compressBlockBuffer",colored)
    return colored,Biome,compressed
end
return Builder 