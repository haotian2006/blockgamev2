local utils = {}
local Layer = require(script.Parent.layers)
local MathUtils = require(script.Parent.Parent.Parent.math.utils)
function utils.sampleXCross(layer,x,y,z)
    local BR = Layer.get(layer,x-1,y,z+1)
    local TR = Layer.get(layer,x+1,y,z+1)
    local TL = Layer.get(layer,x+1,y,z-1)
    local BL = Layer.get(layer,x-1,y,z-1)
    local Center = Layer.get(layer,x,y,z)
    return BR,TR,TL,BL,Center
end
function utils.sampleCross(layer,x,y,z)
    local N = Layer.get(layer,x,y,z-1)
    local E = Layer.get(layer,x+1,y,z)
    local S = Layer.get(layer,x,y,z+1)
    local W = Layer.get(layer,x-1,y,z)
    local Center = Layer.get(layer,x,y,z)
    return N,E,S,W,Center
end

function utils.isOcean(id)
    return id == 0
end
function utils.isShallowOcean(id)
    return id == 0
end
local function calcContribution(offset, x, z)
    return ((x - offset[2]) * (x - offset[2])) + ((z - offset[1]) * (z - offset[1]))
end
local find = 1024
local mul = 3.6
local function calcOffset2D(seed, x, z, offX, offZ)
    local Random = MathUtils.createRandom(seed, x+offX, z+offZ)
    local d1 = ((Random:NextInteger(1, find)) / find - 0.5) * mul+ offX
    local d2 = (Random:NextInteger(1, find) / find - 0.5) * mul + offZ
    return { d1, d2 }
end
function utils.sampleVoronoi2D(seed, x, z)
    x = x - 2
    z = z - 2
    local pX = x // 4
    local pZ = z // 4
    local sX = pX * 4
    local sZ = pZ * 4
    local off_0_0 = calcOffset2D(seed, sX, sZ, 0, 0)
    local off_1_0 = calcOffset2D(seed, sX, sZ, 4, 0)
    local off_0_1 = calcOffset2D(seed, sX, sZ, 0, 4)
    local off_1_1 = calcOffset2D(seed, sX, sZ, 4, 4)

    local cell = MathUtils.band(z, 3) * 4 + MathUtils.band(x, 3)
    local rshift = cell//4
    local lshift =  MathUtils.band(cell, 3)
    local corner0 = calcContribution(off_0_0, rshift, lshift)
    local corner1 = calcContribution(off_1_0, rshift, lshift)
    local corner2 = calcContribution(off_0_1, rshift, lshift)
    local corner3 = calcContribution(off_1_1, rshift, lshift)
    
    local offset
    if corner0 < corner1 and corner0 < corner2 and corner0 < corner3 then
        offset = 0
    elseif corner1 < corner0 and corner1 < corner2 and corner1 < corner3 then
        offset = 1
    elseif corner2 < corner0 and corner2 < corner1 and corner2 < corner3 then
        offset = 2
    else
        offset = 3
    end
    
    return pX+(MathUtils.band(offset, 1)),pZ+(offset//2)
end

return table.freeze(utils)