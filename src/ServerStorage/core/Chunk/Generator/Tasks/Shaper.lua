--!nocheck
local Shaper = {}

local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
IndexUtils.preCompute()
IndexUtils.preCompute2D()
IndexUtils.preCompute2DChunkQuad()

local WorldConfig = require(game.ReplicatedStorage.WorldConfig)
local SEED = WorldConfig.Seed

local Generation = game.ServerStorage.Generation
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local NoiseManager = require(game.ServerStorage.Generation.math.noise)
local layers = require(game.ServerStorage.Generation.generation.biomes.layers)
local Biomes = require(game.ReplicatedStorage.Handler.Biomes)
local Utils = require(Generation.math.utils)
local Registry = require(script.Parent.Parent.Registry)
local UInt32 = 2^32-1

local to1D = IndexUtils.to1D
local to1DXZ = IndexUtils.to1DXZ

local Overworld = require(script.Parent.Parent.Parent.OverworldBiome)
local Width,Height = GameSettings.getChunkSize()

local XprecentageCache = Utils.precentageCache4
local YprecentageCache = Utils.YprecentageCache8

function lerp3(a, b, c, d, e, f, g, h, i, j, k)
    local x1 =  d + a * (e - d)
    local x =   x1 + b * ((f + a * (g - f)) - x1)
    local y1 =  h + a * (i -h)
    return    x + c * (( y1 + b * ((j + a * (k - j)) - y1)) - x)
end

local function calculateFallOff(depth,scale,y)
    local fall = (y-(8.5+depth*8.5/8*4))*12*128/256/scale
    if fall < 0 then
        fall *=4
    end
    return fall
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


function Shaper.color(cx,cz,Shape,Surface,Biome)
    local IS_BUFFER = type(Biome) ~= "number"
    local currentBiome  = {}
    if not IS_BUFFER then
        local BiomeName = Biomes.getBiomeFrom(Biome)
        currentBiome = Registry.getBiome(BiomeName)
    end
    local Cache = {} 
    local MainBlock = currentBiome.MainBlock 
    local SurfaceBlock = currentBiome.SurfaceBlock 
    local SecondaryBlock = currentBiome.SecondaryBlock
    local SecondaryLength = (currentBiome.SecondaryLength )

    local function getBiome(idx):Registry.Biome
        if Cache[idx] then return Cache[idx] end 
        local BiomeName = Biomes.getBiomeFrom(buffer.readu16(Biome, (idx-1)*2))
        local b = Registry.getBiome(BiomeName)

        Cache[idx] = b or currentBiome
        return b
    end
    debug.profilebegin("color")
    local times = 0
    for x = 1,8 do
        for z = 1,8 do
            local idx2D = IndexUtils.to1DXZ[x][z] 
            local SurfaceY = buffer.readu8(Surface, idx2D-1)
            if IS_BUFFER then
                local biome = getBiome(idx2D)
                if currentBiome ~= biome then
                    MainBlock = biome.MainBlock
                    SurfaceBlock = biome.SurfaceBlock
                    SecondaryBlock = biome.SecondaryBlock 
                    SecondaryLength = (biome.SecondaryLength)
                end
                currentBiome = biome
            end
            for y = 256,1,-1 do
                local idx = to1D[x][y][z]
                local idx_ = (idx-1)*4
                local value = buffer.readu32(Shape, idx_)
                local color = 0
                if value == UInt32 then
                    local diff = SurfaceY-y
                    color = MainBlock
                    if SurfaceY == y then
                        color = SurfaceBlock
                    elseif diff < SecondaryLength and diff>0 then
                        color = SecondaryBlock
                    end
                    times+=1
                end
                buffer.writeu32(Shape, idx_, color)
            end
        end
    end
    debug.profileend()
    return Shape,times
end

function Shaper.createBiomeMap(cx,cz)
    debug.profilebegin("createBiome")
    local startX,startZ = cx*8,cz*8
    local b = buffer.create(8*8*2)
    local current = nil
    for x = 1,Width do
        for z = 1,Width do
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

function Shaper.sampleDensityNoise(cx,cz,qx,qz,biome)
    local maxBufferSize = 32*4
    local startX,startZ = cx*8,cz*8
    local height,Factor = 60,0.005
    local noise_scale = 1
    local SurfaceScale = 1
    local ISBUFFER = type(biome) ~= "number"
    if not ISBUFFER then
        local BiomeName = Biomes.getBiomeFrom(biome)
        local b = Registry.getBiome(BiomeName)
        height = b.Elevation 
        Factor = b.Factor 
        noise_scale = b.NoiseScale 
        SurfaceScale = b.SurfaceScale 
    end
    debug.profilebegin("sample Density For SubChuck")
    local bufferObject = buffer.create(maxBufferSize)
    local x= qx*4+1
    local z = qz*4+1

    if ISBUFFER then
        local idx = IndexUtils.to1DXZ[x][z]
        local BiomeName = Biomes.getBiomeFrom(buffer.readu16(biome, (idx-1)*2))
        local b = Registry.getBiome(BiomeName)
        height = b.Elevation 
        Factor = b.Factor 
        noise_scale = b.NoiseScale 
        SurfaceScale = b.SurfaceScale 
    end

    local nx = x-1 + startX
    local nz = z-1 + startZ
    for y = 0,Height-1,8 do
        local ly = (y)//8
        local surface = NoiseManager.sample(Noise1, nx, y, nz)/SurfaceScale
        local min = NoiseManager.sample(MinNoise, nx, y, nz)/noise_scale
        local max = NoiseManager.sample(MaxNoise, nx, y, nz)/noise_scale
        surface = (surface / 10.0 + 1) / surface

        local noise = clampedLerp(min, max, surface) -calculateFallOff(height, Factor, y) --+(height-y)*scale
        buffer.writef32(bufferObject, ly*4, noise)
    end
    debug.profileend()
    return bufferObject
end

local BlendSize = 8
function Shaper.blendNoise(C,N,E,NE)
    local M = C
    local cache = {
        [C] = {},
        [N] = {},
        [E] = {},
        [NE] = {}
    }
    local function getY(b,y)
        local c = cache[b]
        if c[y] then return c[y] end 
        local v = buffer.readu32(b, y*4)
        c[y] = v
        return v
    end
    local maxBufferSize = 32*4
    local b = buffer.create(maxBufferSize)
    debug.profilebegin("blend noise")
    for y = 0,(Height-1)//BlendSize do
        local yy = YprecentageCache[y//4]
        local IncreaseY = (y+1)>31 and 31 or (y+1)
        local my =  y
        local noise000 = getY(M, my)
        local noise001 = getY(E, my)
        local noise010 = getY(M, IncreaseY)
        local noise011 = getY(E,IncreaseY)
        local noise100 = getY(N, my)
        local noise101 = getY(NE, my)
        local noise110=  getY(N, IncreaseY)
        local noise111 = getY(NE, IncreaseY)
        local v = lerp3(.25, yy, .25, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)
        buffer.writef32(b, y*4, v)
    end
    debug.profileend()
    return b
end


function Shaper.computeBlendedAir(center,top,left,topLeft)
    local noise000,noise001,noise010,noise011,noise100,noise101,noise110,noise111 = 1,1,1,1,1,1,1,1
    local b = buffer.create(256*8*8)
    debug.profilebegin("Blend air")
    local LastY 
    local surfaceBuffer = buffer.create(8*8)
    local calculated = {}
    for y = 255,0,-1 do 
        local yp = YprecentageCache[y+1]
        local ly = (y)//8
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
        for x = 1,8 do
            local xp= YprecentageCache[x]
            for z = 1,8 do
                local zp = YprecentageCache[z]
                local value = lerp3(xp, yp, zp, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)
                local bool = value>0 and 1 or 0
                local idx2d = to1DXZ[x][z] 
                if not calculated[idx2d] then
                    if  (bool == 1) then
                        buffer.writeu8(surfaceBuffer, idx2d-1, y)
                        calculated[idx2d] = true
                    end
                end
                if bool == 0 then continue end 
                local idx = to1D[x][y+1][z]
                buffer.writeu8(b, (idx-1), bool)
            end
        end
    end
    debug.profileend()
    return b,surfaceBuffer
end

function Shaper.computeAir(center,top,left,topLeft,bufferObject,surfaceBuffer,qx,qz)
    local noise000,noise001,noise010,noise011,noise100,noise101,noise110,noise111 = 1,1,1,1,1,1,1,1
    debug.profilebegin("lerping and computing air")
    local LastY 
    local calculated = {}
    for y = 255,0,-1 do
        local yp = YprecentageCache[y+1]
        local ly = (y)//8
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
        for x = 1,4 do
            local xp= XprecentageCache[x]
            local rx = qx*4+x
            for z = 1,4 do
                local rz = qz*4+z
                local zp = XprecentageCache[z]
                local value = lerp3(xp, yp, zp, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)
                local bool = value>0 and 1 or 0
                if bool == 0 then continue end 
                local indx2d = to1DXZ[rx][rz]
                if not calculated[indx2d]  then
                    buffer.writeu8(surfaceBuffer, indx2d-1, y+1)
                    calculated[indx2d] = true
                end
                local ridx = to1D[rx][y+1][rz]
                buffer.writeu32(bufferObject, (ridx-1)*4, UInt32)
                
            end
        end
    end
    debug.profileend()
    return bufferObject,surfaceBuffer
end

return Shaper