local Tasks = {}
local Generation = game.ServerStorage.Generation
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local NoiseManager = require(game.ServerStorage.Generation.math.noise)
local layers = require(game.ServerStorage.Generation.generation.biomes.layers)
local Biomes = require(game.ReplicatedStorage.Handler.Biomes)
local Utils = require(script.Parent.Parent.Parent.Parent.math.utils)
local features = script.Parent.Parent.Parent.features
local worms = require(script.Parent.Parent.Parent.features.caves.perlineWorms)


local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
IndexUtils.preCompute()
IndexUtils.preCompute2D()
IndexUtils.preCompute2DChunkQuad()
local to1D = IndexUtils.to1D

local Overworld = require(script.Parent.Overworld)
local Width,Height = GameSettings.getChunkSize()


local XprecentageCache = Utils.precentageCache4
local YprecentageCache = Utils.YprecentageCache8

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

function Tasks.combineBufferWCarver(mainBuffer,...)
    debug.profilebegin("CarveBuffer")
    local checked = {}
    for ii,toCompute in {...} do
       for i,data in toCompute do
            for i,v in data do
                local mode = v.Z
                local loc = v.X

                local value = checked[loc] or buffer.readu32(mainBuffer, (loc-1)*4)
                if mode == 0 and value == 0 then
                    checked[loc] = value
                    continue
                elseif mode ==2 and value ~= 0 then
                    checked[loc] = value
                    continue
                end

                buffer.writeu32(mainBuffer, (loc-1)*4, v.Y)
                checked[loc] = v.Y
            end
       end
    end
    debug.profileend()
    return mainBuffer
end
function Tasks.createBiomeMap(cx,cz)
    debug.profilebegin("createBiome")
    local startX,startZ = ConversionUtils.getoffset(cx,cz)
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

function Tasks.color(cx,cz,Shape,Surface,Biome)
    local ISBUFFER = type(Biome) ~= "number"
    local currentBiome 
    if not ISBUFFER then
        currentBiome = Biomes.getBiomeData(Biome)
    end
    local Cache = {}
    local function getBiome(idx)
        if Cache[idx] then return Cache[idx] end 
        local b = Biomes.getBiomeData(buffer.readu16(Biome, (idx-1)*2))
        Cache[idx] = b or currentBiome
        return b
    end
    local b = buffer.create(8*8*256*4)
    debug.profilebegin("color")
    for x = 1,8 do
        for z = 1,8 do
            local idx2D = IndexUtils.to1DXZ[x][z]
            if ISBUFFER then
                currentBiome = getBiome(idx2D)
            end
            for y = 256,1,-1 do
                local idx = to1D[x][y][z]
                local value = buffer.readu8(Shape, idx-1)
                local color = 0
                if value == 1 then
                    color = currentBiome.Color or 0
                end
                buffer.writeu32(b, (idx-1)*4, color)
            end
        end
    end
    debug.profileend()
    return b 
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
    local height,Factor = 60,0.005
    local noise_scale = 1
    local SurfaceScale = 1
    local ISBUFFER = type(biome) ~= "number"
    if not ISBUFFER then
        local b = Biomes.getBiomeData(biome)
        height = b.Elevation or height
        Factor = b.Factor or Factor
        noise_scale = b.NoiseScale or noise_scale
        SurfaceScale = b.SurfaceScale or SurfaceScale
    end
    debug.profilebegin("sample Density")
    local TL,TR,BL,BR = buffer.create(maxBufferSize),buffer.create(maxBufferSize),buffer.create(maxBufferSize),buffer.create(maxBufferSize)
    for x =1,Width,4 do
        local lx = (x-1)//4
        for z =1,Width,4 do
            local lz =(z-1)//4
            local bufferObject = if lx == 0 and lz == 0 then BL 
            else if lx == 1 and lz == 0 then TL
            else if lx == 0 and lz == 1 then BR
            else TR
            if ISBUFFER then
                local idx = IndexUtils.to1DXZ[x][z]
                local b = Biomes.getBiomeData(buffer.readu16(biome, (idx-1)*2))
                height = b.Elevation or height
                Factor = b.Factor or Factor
                noise_scale = b.NoiseScale or noise_scale
                SurfaceScale = b.SurfaceScale or SurfaceScale
            end
            for y = 1,Height,8 do
                local ly = (y-1)//8
                local nx = x + startX
                local nz = z + startZ
                local surface = NoiseManager.sample(Noise1, nx, y, nz)/SurfaceScale
                local min = NoiseManager.sample(MinNoise, nx, y, nz)/noise_scale
                local max = NoiseManager.sample(MaxNoise, nx, y, nz)/noise_scale
                surface = (surface / 10.0 + 1) / surface
                local noise = clampedLerp(min, max, surface) -calculateFallOff(height, Factor, y) --+(height-y)*scale
                buffer.writef32(bufferObject, ly*4, noise)
            end
        end
    end
    debug.profileend()
    return BL,TL,BR,TR
end
local BlendOffset = {
    Vector3.zero,
    Vector3.xAxis,
    Vector3.yAxis,
    Vector3.new(1,0,1)
}
local BlendSize = 8
function Tasks.blendNoise(C,N,E,NE)
    local ww = BlendSize
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
    local Surface = buffer.create(8*8)
    for y = 0,Height//BlendSize do
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
function Tasks.computeBlendedAir(center,top,left,topLeft)
    local noise000,noise001,noise010,noise011,noise100,noise101,noise110,noise111 = 1,1,1,1,1,1,1,1
    local b = buffer.create(256*8*8)
    debug.profilebegin("Blend air")
    local LastY 
    local surfaceBuffer = buffer.create(8*8)
    local calculate = {}
    for y = 256,1,-1 do
        local yp = YprecentageCache[y]
        local ly = (y-1)//8
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
                local idx2d =IndexUtils.to1DXZ[x][z] 
                if not calculate[idx2d] then
                    if  (bool == 1) then
                        buffer.writeu8(surfaceBuffer, idx2d-1, y)
                        calculate[idx2d] = true
                    end
                end
                if bool == 0 then continue end 
                local idx = to1D[x][y][z]
                buffer.writeu8(b, (idx-1), bool)
            end
        end
    end
    debug.profileend()
    return b,surfaceBuffer
end
local offsetTable = {
    Vector3.zero,
    Vector3.new(4),
    Vector3.new(0,0,4),
    Vector3.new(4,0,4)
}
local maxBufferSizeAIR = 256*2
function Tasks.computeAir(center,top,left,topLeft,loc)
    local noise000,noise001,noise010,noise011,noise100,noise101,noise110,noise111 = 1,1,1,1,1,1,1,1
    local b = buffer.create(maxBufferSizeAIR)
    debug.profilebegin("lerping and computing air")
    local LastY 
    local surfaceBuffer = buffer.create(4*4)
    local calculated = {}
    for y = 256,1,-1 do
        local yp = YprecentageCache[y]
        local ly = (y-1)//8
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
        for x = 1,4 do
            local xp= XprecentageCache[x]
            for z = 1,4 do
                local zp = XprecentageCache[z]
                local value = lerp3(xp, yp, zp, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)
                local bool = value>0 and 1 or 0
                local idx = IndexUtils.to1DXZChunkQuad[x][z]
                if not calculated[idx] and  (bool == 1) then
                    buffer.writeu8(surfaceBuffer, idx-1, y)
                    calculated[idx] = true
                end
                if bool == 0 then continue end 
                bits += bool*(2^(idx-1))
            end
        end
        buffer.writeu16(b, (y-1)*2, bits)
    end
    debug.profileend()
    return b,surfaceBuffer
end
function Tasks.shapeCombine(x1,x2,x3,x4)
    local last = {x1,x2,x3,x4}
   -- local t = table.create(8*8*256,false)
    local maxy = buffer.len(x1)//2
    local B = buffer.create(8*8*256)
    debug.profilebegin("Combine")
    for i,b in last do
        local offs = offsetTable[i] 
        for y =1,maxy do
            local xzBits = buffer.readu16(b,(y-1)*2)
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
                local Real = IndexUtils.to2DChunkQuad[iter+1]+offs
                local idx = to1D[Real.X][y][Real.Z]
               -- t[idx] = value
                buffer.writeu8(B, idx-1, value and 1 or 0)
            end
        end     
    end
    return B
end
function Tasks.carve(main,...)
    for _,v in {...} do
        for i =0, buffer.len(v)-1 do
            local value = buffer.readu8(v, i)
            if value == 1 then
                buffer.writeu8(main, i, 0)
            end
        end
    end
    return main
end
function Tasks.surfaceCombine(x1,x2,x3,x4)
    local last = {x1,x2,x3,x4}
   -- local t = table.create(8*8*256,false)
    local B = buffer.create(8*8)
    debug.profilebegin("CombineSurface")
    for i,b in last do
        local offs = offsetTable[i] 
        for x = 1,4 do
            for z = 1,4 do
                local idx = IndexUtils.to1DXZChunkQuad[x][z]
                local value = buffer.readu8(b,idx-1)
                buffer.writeu8(B, IndexUtils.to1DXZ[offs.X+x][offs.Z+z]-1, value)
            end
        end
    end
    for i=0,63 do
        if buffer.readu8(B, i) == 0 then
            print(i)
        end
    end
    return B
end
function Tasks.compressBlockBuffer(b)
    local t = {}
    local current
    local idx = 0
    local length = 0
    debug.profilebegin("compress")
    for i =0,8*8*256-1 do
        local value = buffer.readu32(b, i*4)
        if value ~= current then
            if current ~= nil then  
                t[idx] = Vector3.new(current,length)
            end
            current = value 
            length = 0
            idx+=1
        end
        length+=1
    end
    if  t[idx-1] and t[idx-1].X == current then
        t[idx-1]+=Vector3.new(0,length)
    else
        t[idx] = Vector3.new(current,length)
    end
    local cBuffer = buffer.create(#t*6)
    for i,v in t do
        local idx_ = (i-1)*6
        buffer.writeu32(cBuffer,idx_, v.X)
        buffer.writeu16(cBuffer,idx_+4, v.Y)
    end
    debug.profileend()
    return cBuffer
end
return Tasks