local Tasks = {}
local Generation = game.ServerStorage.Generation
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local NoiseManager = require(game.ServerStorage.Generation.math.noise)
local layers = require(game.ServerStorage.Generation.generation.biomes.layers)
local Biomes = require(game.ReplicatedStorage.Biomes)

local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
IndexUtils.preCompute()
IndexUtils.preCompute2D()
IndexUtils.preCompute2DChunkQuad()

local Overworld = require(script.Parent.Overworld)
local Width,Height = GameSettings.getChunkSize()
Width-=1;Height-=1

local XprecentageCache = {}
local YprecentageCache = {}
do
    for x = 0,3 do
        XprecentageCache[x] = ((x % 4 + 4) % 4) / 4
    end
    for y = 0,255 do
        YprecentageCache[y] = ((y % 8 + 8) % 8) / 8
    end
end
function lerp2(a, b, c, d, e, f)
    local x = c + a * (d - c)
    return x+ b* (e + a * (f- e)- x)
end
function lerp3(a, b, c, d, e, f, g, h, i, j, k)
    local x1 =  d + a * (e - d)
    local x =   x1 + b * ((f + a * (g - f)) - x1)
    local y1 =  h + a * (i -h)
    return    x + c * (( y1 + b * ((j + a * (k - j)) - y1)) - x)
end
local function clampedLerp(a, b, c)
    if c < 0 then
        return a
    elseif c > 1 then
        return b
    else
        return  b + a * (c - b) 
    end
end

function Tasks.createBiomeMap(cx,cz)
    debug.profilebegin("createBiome")
    local startX,startZ = ConversionUtils.getoffset(cx,cz)
    local b = buffer.create(8*8*2)
    local current = nil
    for x = 0,Width do
        for z = 0,Width do
            local biome = layers.get(Overworld,startX+x,0,startZ+z)
            current = if biome ~= current and current ~= nil then false else biome
            buffer.writeu16(b,(IndexUtils.to1DXZ[x][z]-1)*2,biome)
        end
    end
    debug.profileend() 
    if current then
        return current
    end
    return b
end

do

--[[
    debug.profilebegin("Compress Biomes")
        local toBuffer = table.create(32)
        local count = 0
        local current
        for i,v in biomes do
            if not current then
                current = v
                count =0
                continue
            end
            if v~= current then
                toBuffer[#toBuffer+1] =  bit32.bor(bit32.lshift(count, 6), current-1)
                current = v
                count =0
                continue
            end
            count += 1;
        end
        toBuffer[#toBuffer+1] =  bit32.bor(bit32.lshift(count, 6), current-1)
        local buf = buffer.create(#toBuffer*12)
        for i,v in toBuffer do
            buffer.writeu16(buf, (i-1)*12, v)
        end
        debug.profileend()
    ]]
end
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
function Tasks.sampleDensityNoise(cx,cz,biome)
    local maxBufferSize = 32*4
    local startX,startZ = ConversionUtils.getoffset(cx,cz)
    local height,scale = 60,0.005
    local ISBUFFER = type(biome) ~= "number"
    if not ISBUFFER then
        local b = Biomes.getBiomeData(biome)
        height = b.Elevation or height
        scale = b.Scale or scale
    end
    debug.profilebegin("sample Density")
    local TL,TR,BL,BR = buffer.create(maxBufferSize),buffer.create(maxBufferSize),buffer.create(maxBufferSize),buffer.create(maxBufferSize)
    for x =0,Width,4 do
        local lx = x//4
        for z =0,Width,4 do
            local lz =z//4
            local bufferObject = if lx == 0 and lz == 0 then BL 
            else if lx == 1 and lz == 0 then TL
            else if lx == 0 and lz == 1 then BR
            else TR
            if ISBUFFER then
                local idx = IndexUtils.to1DXZ[x][z]
                local b = Biomes.getBiomeData(buffer.readu16(biome, (idx-1)*2))
                height = b.Elevation or height
                scale = b.Scale or scale
            end
            for y = 0,Height,8 do
                local ly = y//8
                local nx = x + startX
                local nz = z + startZ
                local surface = NoiseManager.sample(Noise1, nx, y, nz)
                local min = NoiseManager.sample(MinNoise, nx, y, nz)
                local max = NoiseManager.sample(MaxNoise, nx, y, nz)
                local noise = clampedLerp(min, max, surface)+(height-y)*scale
                buffer.writef32(bufferObject, ly*4, noise)
            end
        end
    end
    debug.profileend()
    return BL,TL,BR,TR
end
function Tasks.lerpDensity(TL,TR,BL,BR,N,E,NE)
    
end
local maxBufferSizeAIR = 256*2
function Tasks.computeAir(center,top,left,topLeft)
    local noise000,noise001,noise010,noise011,noise100,noise101,noise110,noise111 = 1,1,1,1,1,1,1,1
    local b = buffer.create(maxBufferSizeAIR)
    debug.profilebegin("lerping and computing air")
    local LastY 
    for y = 0,255 do
        local yp = YprecentageCache[y]
        local ly = y//8
        if LastY ~= ly then
            LastY = ly
            local IncreaseY = (ly+1)>31 and 31*4 or (ly+1)*4
            local my =  ly*4
            noise000 = buffer.readf32(center, my)
            noise001 = buffer.readf32(left, my)
            noise010 = buffer.readf32(center, IncreaseY)	
            noise011 = buffer.readf32(left, IncreaseY)		
            noise100 = buffer.readf32(top, my)	
            noise101 = buffer.readf32(topLeft, my)	
            noise110 = buffer.readf32(top, IncreaseY)
            noise111 = buffer.readf32(topLeft, IncreaseY)
        end
        local bits = 0
        for x = 0,3 do
            local xp= XprecentageCache[x]
            for z = 0,3 do
                local zp = XprecentageCache[z]
                local value = lerp3(xp, yp, zp, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)>0 and 1 or 0
                local idx = IndexUtils.to1DXZChunkQuad[x][z]
                bits += value*(2^(idx-1))
            end
        end
        buffer.writeu16(b, y*2, bits)
    end
    debug.profileend()
    return b
end
local offsetTable = {
    Vector3.zero,
    Vector3.new(4),
    Vector3.new(0,0,4),
    Vector3.new(4,0,4)
}
function Tasks.combine(x1,x2,x3,x4)
    local last = {x1,x2,x3,x4}
   -- local t = table.create(8*8*256,false)
    local B = buffer.create(8*8*256)
    debug.profilebegin("Combine")
    for i,b in last do
        for y =0,255 do
            local xzBits = buffer.readu16(b,y*2)
            for iter = 15, 0,-1 do
                local value = false
                if xzBits == 0 then
                    value = false
                elseif xzBits == 65535 then
                    value = true
                else
                    value = bit32.band(xzBits, bit32.lshift(1, iter)) ~= 0
                end
                if not value then continue end 
                local Real = IndexUtils.to2DChunkQuad[iter+1]+offsetTable[i] 
                local idx = IndexUtils.to1D[Real.X][y][Real.Z]
               -- t[idx] = value
                buffer.writeu8(B, idx-1, value and 1 or 0)
            end
        end     
    end
    return B
end
return Tasks