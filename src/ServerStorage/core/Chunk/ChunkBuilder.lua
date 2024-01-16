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
    local colored = Builder.color(chunk,Shape,Surface,Biome)
    return colored,Biome,Surface 
end
function Builder.buildCaves(chunk,blocks)
    local caves = Layers.compute(OverWorld.Caves,chunk)
    local combined = Generator.DoWork("combineBufferWCarver",blocks,caves)
    return combined
end
function Builder.buildFeatures(chunk,surroundingChunks)
    local lastData = surroundingChunks[chunk]
    local surfaceArray = {}
    for i,v in surroundingChunks do
        surfaceArray[`{i.X},{i.Z}`] = {v[2],v[3]}
    end
    local colored,Biome,Surface = unpack(lastData)
    local Structures = Layers.compute(OverWorld.Structures,chunk,surroundingChunks,surfaceArray)
    local ore = Layers.compute(OverWorld.Ore,chunk)
    --local combined = Generator.DoWork("combineBufferWCarver",colored,ore)
   -- combined =  Generator.DoWork("computefoliage",chunk.X,chunk.Z,combined,Biome,Surface)
    local combined = Generator.DoWork("combineBufferWCarver",colored,Structures,ore)
    return combined
end
function Builder.compress(buffer)
     return Generator.DoWork("compressBlockBuffer",buffer)
end
return Builder 