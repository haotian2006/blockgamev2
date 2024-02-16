local layer = {}
local utils = require(script.Parent.Parent.Parent.Parent.Parent.math.utils)
function layer.new()
    return {script.Name,1}
end
function layer.sample(self,x,y,z)
    return 1
end

return layer