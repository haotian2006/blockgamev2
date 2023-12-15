local Voronoi = {}
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
local biomeUtils = require(script.Parent.Parent.Parent.biomeUtils)
local layers = require(script.Parent.Parent.Parent.layers)

function Voronoi.sample(self,x,y,z)
    local Parent = self[3]
    local nx,nz = biomeUtils.sampleVoronoi2D(self[2], x, z)
    return  layers.get(Parent,nx,0,nz)
end

return Voronoi