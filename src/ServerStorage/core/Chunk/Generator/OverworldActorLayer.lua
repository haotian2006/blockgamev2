local Shaper = require(script.Parent.Tasks.Shaper)
local Communicator = require(script.Parent.Communicator)
local Layers = require(game.ServerStorage.core.Chunk.Generator.ChunkLayer)
Layers.Init()

local Overworld = {}
local self = {}

local Carver = require(game.ServerStorage.Generation.generation.features.caves.perlineWorms)

local CarverObject = Carver.parse(123,{
    maxDistance = 200,
    amplitude = .008,
    weight = .5,
    interval = 6,
    maxSections = 1,
    chance = 10 
})



function Overworld.Init()
    
    self.Biome = Layers.create("BiomeLayer")
    self.Caves = Layers.create("CaveLayer")
    self.Terrain = Layers.create("SampleNoiseLayer",self.Biome)
    self.Terrain = Layers.create("StoneAirLayer",self.Terrain)
    self.Colored = Layers.create("ColorLayer",self.Terrain)
end

function Overworld.Biome(chunk)
    return Layers.get(self.Biome,chunk)
end

function Overworld.AddFeatures(chunk)
    
end

function Overworld.Carve(chunk)
    return Carver.sample(CarverObject, chunk.X, chunk.Y)
end

function Overworld.Build(chunk)
    local Biomes = Layers.get(self.Biome,chunk)
    local terrain = Layers.get(self.Terrain,chunk)
    local shape,surface = terrain[1],terrain[2]
    local Colored = Layers.compute(self.Colored,chunk,shape,surface,Biomes)
    return Colored,surface,Biomes
end
 
return Overworld  