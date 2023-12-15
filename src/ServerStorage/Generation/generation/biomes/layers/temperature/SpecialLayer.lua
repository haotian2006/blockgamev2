local Speical = {}
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
local biomeUtils = require(script.Parent.Parent.Parent.biomeUtils)
local layers = require(script.Parent.Parent.Parent.layers)

function Speical.sample(self,x,y,z)
    local parent = self[3]
    local value = layers.get(parent,x,y,z)

    if biomeUtils.isShallowOcean(value) then return value end 
    local random = utils.createRandom(self[2], x, z)
    if (random:NextInteger(0,12) == 0) then
        value = utils.bor(value, random:NextInteger(0, 14)*256)        
    end
    return value
end

return Speical