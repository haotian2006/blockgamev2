local scale = {}
local generation = script.Parent.Parent.Parent
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
local layers = require(generation.layers)
local function band(x,y)
    local sign = math.sign(x)
    return sign*bit32.band(x*sign,y)
end
function scale.new(seed,salt,type,parent)
    return {script.Name,utils.jenkins_hash(`{seed}{salt or 0}`),parent or error("No Parent Given To Scale Layer"),type or "NORMAL"}
end
local function helper(self,random,center,e,s,se)
    local value = utils.choose4(random,center,e,s,se)

    if self[4] == "FUZZY" then
        return value
    end
    if(e ==  s and e == se) then return e end 
    if(center == e and s ~= se) then return center end 
    if(center == s and e ~= se) then return center end 
    if(center == se and e ~= s) then return center end 
    if(e == s and center ~= se) then return e end 
    if(e == se and center ~= s) then return e end 
    if(s == se and center ~= e) then return s end 
    return value 
end

function scale.sample(self,x,y,z)
    local parent = self[3]
    local center = layers.get(parent,x//2,y,z//2)
    local random = utils.createRandom(self[2],band(x,-2),band(z, -2))

    local xBack = band(x, 1)
    local zBack = band(z, 1)

    if (xBack == 0 and zBack == 0) then return center end

    local south = layers.get(parent,x//2,y,(z+1)//2)
    local zFront = utils.choose(random, center, south)

    if (xBack == 0) then return zFront end 

    local east = layers.get(parent,(x+1)//2,y,z//2)
    local xFront = utils.choose(random, center, east)

    if (zBack == 0) then return xFront end

    local southEast = layers.get(parent,(x+1)//2,y,(z+1)//2)
    return helper(self,random,center,east,south,southEast)
end

return scale