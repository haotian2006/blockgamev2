local Layers = require(game.ServerStorage.Generation.generation.chunk.GenerationLayer)

Layers.Init()
local self = {}
self.Biome = Layers.create("biomeLayer")
self.Terrain = Layers.create("surfaceNoiseLayer",self.Biome)
self.Terrain = Layers.create("airStoneLayer",self.Terrain)
self.Surface = Layers.create("surfaceCombineLayer",self.Terrain)
self.Terrain  = Layers.create("shapeCombineLayer",self.Terrain )

self.Caves = Layers.create("sampleNoodleLayer")
self.Caves = Layers.create("lerpNoodleLayer",self.Caves)
return self