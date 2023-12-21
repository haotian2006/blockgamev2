local Stack = {}
local Layer = require(script.Parent.GenerationLayer)

function Stack.getBiome(self,at)
    return Layer.get(self.Biome,at)
end

function Stack.getTerrain(self,at)
    return Layer.get(self.Terrain,at)
end

function Stack.getSurface(self,at)
    return Layer.get(self.Surface,at)
end
return Stack 