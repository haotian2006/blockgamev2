local Terrian = {}
local NoiseManager = require(script.Parent.Parent.math.noise)
--[[
Biome : {
   Noise = {
     HighNoise = {...},
     LowNoise = {...},
     SurfaceNoise = {},

   }
}

]]
local SEED = 12354
local Amp = { 1.0,
1.0,
2.0,
2.0,
2.0,
2.0}
local octaves = -9
local Noise1 = NoiseManager.new(SEED,octaves,Amp,nil)

local mAmp = {    1.0,
1.0,
0.0,
0,
1.0,
1}
local moctaves = -9
local MinNoise = NoiseManager.new(SEED,moctaves,mAmp)

local MAmp = { 
    1.0,
    2.0,
    0,
    1}
local Moctaves = -7
local MaxNoise = NoiseManager.new(SEED,Moctaves,MAmp)
local function clampedLerp(a, b, c)
    if c < 0 then
        return a
    elseif c > 1 then
        return b
    else
        return  b + a * (c - b) 
    end
end
function Terrian.sample(x,y,z)
    
end

return Terrian 