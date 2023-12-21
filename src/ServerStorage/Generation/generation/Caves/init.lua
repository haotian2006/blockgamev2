local Carver = {}
local NoiseHandler = require(script.Parent.Parent.math.noise)
function Carver.samplerHelper(noise1,noise2)
    return math.abs(noise1)+math.abs(noise2)
end
local function carverHelper()
    
end
function Carver.new(seed,noise1,noise2)
    noise1 = NoiseHandler.parse(seed, noise1)
    noise2 = NoiseHandler.parse(seed, noise2)
    return {noise1,noise2}
end

function Carver.sample()
    
end
return Carver