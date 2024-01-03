local Layers = require(game.ServerStorage.Generation.generation.chunk.GenerationLayer)

Layers.Init()
local self = {}
self.Biome = Layers.create("biomeLayer")
self.Terrain = Layers.create("surfaceNoiseLayer",self.Biome)
self.Terrain = Layers.create("airStoneLayer",self.Terrain)
self.Surface = Layers.create("surfaceCombineLayer",self.Terrain)
self.Terrain  = Layers.create("shapeCombineLayer",self.Terrain )

self.Caves = Layers.create("sampleWorm")
self.Caves = Layers.create("combineLayer",self.Caves,6)

self.Ore = Layers.create("oreSampleLayer")
self.Ore= Layers.create("combineLayer",self.Ore,3)

self.Structres = Layers.create("structureSampleLayer")
self.Structres= Layers.create("combineLayer",self.Structres,4)
return self 