--// for stuff like grass flowers
local math = script.Parent.Parent.Parent.math
local NoiseHandler = require(math.noise)
local Range = require(math.range)
local BiomeHandler = require(game.ReplicatedStorage.Biomes)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local Storage = require(game.ServerStorage.core.Chunk.Generator.ChunkDataLocal)
local to1d = IndexUtils.to1D
local to1DXZ = IndexUtils.to1DXZ
local foliage = {}
--[[
    noiseSetting:NoiseSetting,
    range: Range,
    name,
    block:number,

]]
local function getfoliageFromBiome(biome)
    return {
        {
            noiseSettings = NoiseHandler.new(12345, -7, {1}),
            range = Range.parse(
                {
                    multiplier  = 30, 
                   min = -.6,
                   max = 0
                }
            ),
            block = 3,
        }
    }
end
function foliage.new(noise,block,salt)
    
end
function foliage.addfoliage(cx,cz)
    local currentChunk = Vector3.new(cx,0,cz)
    local ChunkData = Storage.getOrCreate(currentChunk)
    local biomes = ChunkData.Biome
    local surface = ChunkData.Surface
    local blocks = ChunkData.Shape
    local t = Storage.getFeatureBuffer(currentChunk)
    local ISBUFFER = typeof(biomes) == "buffer"
    local foliage = {}
    local Updatefoliage
    local currentBiome
    debug.profilebegin("sample foliage")
    if ISBUFFER then
        Updatefoliage = function(x,z)
            local biome = buffer.readu16(biomes, (to1DXZ[x][z]-1)*2)
            if biome == currentBiome then return end 
            currentBiome = biome
            foliage = getfoliageFromBiome(biome)
        end
    else
        currentBiome = biomes
        foliage = getfoliageFromBiome(biomes)
    end
    local ofx,ofz = cx*8,cz*8
    for x = 1,8 do
        local rx = x+ofx
        for z = 1,8 do
            local rz = z+ofz
            if Updatefoliage then Updatefoliage(x, z) end 
            local height = buffer.readu8(surface, to1DXZ[x][z]-1)
            local blockAt = buffer.readu32(blocks, (to1d[x][height+1][z]-1)*4)
            local blockBelow = buffer.readu32(blocks, (to1d[x][height][z]-1)*4)
            for i,v in foliage do
                local noise = NoiseHandler.sample(v.noiseSettings, rx*5, 0, rz*5)
                if Range.inRange(v.range,noise) and blockBelow ~= 0 and blockAt ==0  then
                    buffer.writeu32(t,  (to1d[x][height+1][z]-1)*4, 3)
                    break
                end
            end
        end
    end
    debug.profileend()
    return blocks
end
return foliage