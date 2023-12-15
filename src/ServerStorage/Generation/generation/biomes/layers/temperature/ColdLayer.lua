local Cold = {}
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
local biomeUtils = require(script.Parent.Parent.Parent.biomeUtils)
local layers = require(script.Parent.Parent.Parent.layers)

function Cold.new(seed,salt,parent)
    return {script.Name,utils.jenkins_hash(`{seed},{salt or 0}`),parent}
end

function Cold.sample(self,x,y,z)
    local biome = layers.get(self[3],x,y,z)
    if biomeUtils.isOcean(biome) then
        return biome
    end
    local random = utils.createRandom(self[2], x, z)
    local i = random:NextInteger(0, 5)
    if i ==0 then  return 2 end 
    return if i == 1 then 3 else 1
end

return Cold