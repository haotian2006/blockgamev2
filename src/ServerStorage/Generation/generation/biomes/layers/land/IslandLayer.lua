local IsLandLayer = {}
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
local biomeUtils = require(script.Parent.Parent.Parent.biomeUtils)
function IsLandLayer.new(seed,salt,parent)
    return {script.Name,utils.jenkins_hash(`{seed},{salt or 0}`),parent}
end
function IsLandLayer.sample(self,x,y,z)
    local N,E,S,W,Center = biomeUtils.sampleCross(self[3],x,y,z)
    local random = utils.createRandom(self[2], x, z)::Random
    local flag = true
    for i,v in {N,E,S,W,Center} do
        if  biomeUtils.isShallowOcean(v) then continue end
        flag = false
        break
    end
    return if flag and random:NextInteger(1, 2) ==1 then 1 else Center
   
end
return IsLandLayer