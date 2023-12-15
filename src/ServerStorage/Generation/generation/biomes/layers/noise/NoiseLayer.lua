local NoiseLayer = {}
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
local biomeUtils = require(script.Parent.Parent.Parent.biomeUtils)
local layers = require(script.Parent.Parent.Parent.layers)

function NoiseLayer.new(seed,salt,parent)
    return {script.Name,utils.jenkins_hash(`{seed},{salt or 0}`),parent}
end
function NoiseLayer.sample(self,x,y,z)
    local random = utils.createRandom(self[2], x, z)
    local biome = layers.get(self[3],x,y,z)
    return if biomeUtils.isShallowOcean(biome) then biome else 2--random:NextInteger(0, 299999)+ 2
end

return NoiseLayer