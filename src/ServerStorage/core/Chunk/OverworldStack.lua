local Layers = require(script.Parent.GenerationLayer)
Layers.Init()
local current = Layers.create("biomeLayer")
current = Layers.create("surfaceNoiseLayer",current)
current = Layers.create("airStoneLayer",current)
current = Layers.create("combineLayer",current)
return current