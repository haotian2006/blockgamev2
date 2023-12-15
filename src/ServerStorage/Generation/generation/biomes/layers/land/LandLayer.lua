local LandLayer = {}
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
local biomeUtils = require(script.Parent.Parent.Parent.biomeUtils)
function LandLayer.new(seed,salt,parent)
    return {script.Name,utils.jenkins_hash(`{seed},{salt or 0}`),parent}
end
function LandLayer.sample(self,x,y,z)
    local BR,TR,TL,BL,Center = biomeUtils.sampleXCross(self[3],x,y,z)
    local random = utils.createRandom(self[2], x, z)
    local flag = true
    for i,v in {BR,TR,TL,BL} do
        if  biomeUtils.isShallowOcean(v) then continue end
        flag = false
        break
    end
    if (not biomeUtils.isShallowOcean(Center) or flag) then
        local pFlag = true
        for i,v in {BR,TR,TL,BL} do
            if v == 1 then continue end
            pFlag = false
            break
        end
        if Center ~= 1 or pFlag then
            return Center
        end
        return random:NextInteger(1,5) ==4 and 0 or 1
    end
    return random:NextInteger(1,3) ==2 and 1 or 0
end
return LandLayer