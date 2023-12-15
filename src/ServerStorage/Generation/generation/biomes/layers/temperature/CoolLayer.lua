local Cool = {}
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
local biomeUtils = require(script.Parent.Parent.Parent.biomeUtils)
local layers = require(script.Parent.Parent.Parent.layers)

function Cool.sample(self,x,y,z)
    local parent = self[3]
    local n,e,s,w,c = biomeUtils.sampleCross(parent,x,y,z)
    return if c ~= 3 or n ~= 1 and e ~= 31
    and w ~= 1 and s ~= 1 and n ~= 4
    and e ~= 4 and w ~= 4
    and s ~= 4 then c else 3
end

return Cool