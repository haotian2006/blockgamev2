local Noodle = {}
local NoiseHandler = require(script.Parent.Parent.Parent.Parent.math.noise)
local Utils = require(script.Parent.Parent.Parent.Parent.math.utils)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)

local XprecentageCache = Utils.precentageCache4
local YprecentageCache = Utils.YprecentageCache8

function Noodle.new(seed,noise1,noise2,thickness)
    noise1 = NoiseHandler.parse(seed, noise1)
    noise2 = NoiseHandler.parse(seed, noise2)
    thickness = NoiseHandler.parse(seed, thickness)
    return {"c:noodle",noise1,noise2,thickness}
end
local maxHeight =126
function Noodle.sampleChunk(self,cx,cz,quadx,quadz)
    local b = buffer.create(32*12)
    local x,z = ConversionUtils.getoffset(cx, cz)
    x += quadx*4
    z += quadz*4
    for y = 0,maxHeight-1,8 do
        local noise1 = NoiseHandler.sample(self[2], x, y, z)
        local noise2 = NoiseHandler.sample(self[3], x, y, z)
        local thickness = NoiseHandler.sample(self[4], x, y, z)
        y = (y//8)*12
        buffer.writef32(b, y, noise1)
        buffer.writef32(b, y+4, noise2)
        buffer.writef32(b, y+8, thickness)
    end
    return b
end
local lerp3 = Utils.lerp3
local s = maxHeight//8-1
function Noodle.lerp(center,top,left,topLeft)
    local noise000,noise001,noise010,noise011,noise100,noise101,noise110,noise111 
    debug.profilebegin("Create noodle")
    local LastY 
    local function f(b,loc)
        return Vector3.new(buffer.readf32(b, loc),buffer.readf32(b, loc+4),buffer.readf32(b, loc+8))
    end
    local bu = buffer.create(maxHeight*2)
    for y = 0,maxHeight-1 do
        local yp = YprecentageCache[y]
        local ly = y//8
        if LastY ~= ly then
            LastY = ly
            local IncreaseY = (ly+1)>s and s*12 or (ly+1)*12
            local my =  ly*12
            noise000 = f(center,my)
            noise001 = f(left, my)
            noise010 = f(center, IncreaseY)	
            noise011 = f(left, IncreaseY)		
            noise100 = f(top, my)	
            noise101 = f(topLeft, my)	
            noise110 = f(top, IncreaseY)
            noise111 = f(topLeft, IncreaseY)
        end
        local bits = 0
        for x = 0,3 do
            local xp= XprecentageCache[x]
            for z = 0,3 do
                local zp = XprecentageCache[z]
                local value = lerp3(xp, yp, zp, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)
                if value.X^2 + value.Y^2 < value.Z+Utils.clampedMap(y,0,130,0,-.2)+.08 then--value.Z then
                    local idx = IndexUtils.to1DXZChunkQuad[x][z]
                    bits += (2^(idx-1))
                end
            end
        end
        if bits ~= 0 then
            buffer.writeu16(bu, y*2, bits)
        end
    end
    debug.profileend()
    return bu
end
return Noodle