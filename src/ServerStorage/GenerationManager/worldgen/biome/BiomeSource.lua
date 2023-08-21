local BiomeSource = {}
local mulit = require(script.Parent.MultiNoiseBiomeSource)
function BiomeSource.Evaluate(obj)
    local type = obj.type    
    if type == "multi_noise" then
        return mulit.Evaluate(obj)
    end
end
return BiomeSource