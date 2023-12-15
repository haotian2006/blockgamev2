local Warm = {}
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
local biomeUtils = require(script.Parent.Parent.Parent.biomeUtils)
local layers = require(script.Parent.Parent.Parent.layers)

function Warm.new(seed,salt,parent)
    return {script.Name,utils.jenkins_hash(`{seed},{salt or 0}`),parent}
end

function Warm.sample(self,x,y,z)
    local parent = self[3]
    local n,e,s,w,c = biomeUtils.sampleCross(parent,x,y,z)
    return if c ~= 1 or n ~= 3 and e ~= 3 
    and w ~= 3 and s ~= 3 and n ~= 2
    and e ~= 2 and w ~= 2
    and s ~= 2 then c else 4
end

return Warm