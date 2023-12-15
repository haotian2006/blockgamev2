local Smooth = {}
local generation = script.Parent.Parent.Parent
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
local biomeUtils = require(script.Parent.Parent.Parent.biomeUtils)
local layers = require(generation.layers)

function Smooth.sample(self,x,y,z)
    local parent = self[3]
    local n,e,s,w,center = biomeUtils.sampleCross(parent,x,y,z)

    local xMatch = e == w
    local zMatch = n == s
    local random = utils.createRandom(self[2], x, z)
    if (xMatch and zMatch) then
        return utils.choose(random, w, n)
    elseif (not (xMatch or zMatch)) then
        return center
    elseif (xMatch) then
        return w
    end
    return n
end

return Smooth