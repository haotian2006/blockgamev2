local layer = {}
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
function layer.new(seed,salt)
    return {script.Name,utils.jenkins_hash(`{seed}{salt or 0}`)}
end
function layer.sample(self,x,y,z)
    local r = utils.createRandom(self[2], x, z)
    return if(x == 0 and z == 0 ) or (r:NextInteger(0, 9) == 0) then 1 else 0 
end

return layer