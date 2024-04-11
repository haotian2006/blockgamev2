local ore = {}
local Utils = require(script.Parent.Parent.Parent.math.utils)
local NoiseHandler = require(script.Parent.Parent.Parent.math.noise)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local Carver2 = require(script.Parent.Parent.Parent.math.Carver2)
local Storage = unpack(require(game.ServerStorage.core.Chunk.Generator.ChunkAndStorage))
local Distributions = require(script.Parent.Parent.Parent.math.Distributions)
local BlockHandler = require(game.ReplicatedStorage.Block)
local BiomeHelper = require(game.ReplicatedStorage.Handler.Biomes)
local Distribution = require(script.Parent.Parent.Parent.math.Distributions)

IndexUtils.preCompute2D()
local to1dXZ = IndexUtils.to1DXZ

local Biomes 

local SEED
local WorldConfig = require(game.ReplicatedStorage.WorldConfig)

local function getOreFrom(biome)
    local b = BiomeHelper.getBiomeFrom(biome)
    if not b then return {} end 
    return  Biomes[b].Ores
    -- return {
    --     { 
    --         block = 4,
    --         chance =1,
    --         minRange = 0,
    --         maxRange = 3,
    --         yRange = 80,
    --         noiseScale = 10,
    --         noiseSettings = NoiseHandler.parse(SEED,{
    --             amplitudes = {1},
    --             firstOctave = -3
    --         })
    --     }
    -- }
end

--[[
    {
    name : String,
    block : table,
    chance: number|table,
    minRange:number,
    maxRange:number,
    noiseScale:number,
    carverSettings : table,
    }
]]

export type Ore = {
    block :number,
    salt : number?,
    chance :number,
    minRange :number,
    maxRange :number,
    noiseScale : number,
    randomY : Distributions.Distribution,
    noiseSettings : NoiseHandler.Noise,
}

function ore.parse(settings)
    SEED = SEED or WorldConfig.Seed
     local parsed =  { 
        block = settings.block and BlockHandler.parse(settings.block) or 4,
        salt = settings.salt,
        chance = settings.chance or 1,
        minRange = 0,
        maxRange = 3,
        noiseScale = 10,
        randomY = settings.randomY and Distributions.parse(settings.randomY) or Distributions.parse({type = 'uniform',max = 60,min = 1}),
        noiseSettings = settings.noiseSettings and NoiseHandler.parse(SEED,settings.noiseSettings)
    }
    return parsed
end
function ore.sample(cx,cz)
    SEED = SEED or WorldConfig.Seed
    debug.profilebegin("Create Ore") 

    local ChunkData = Storage.getChunkData(Vector3.new(cx,0,cz))
    local biome = ChunkData.Biome
    local surface = ChunkData.Surface
    if typeof(biome) =='buffer' then
        biome = buffer.readu16(biome, 2)
    end
    local ores = getOreFrom(biome)
    local carver = {} 
    for i,ore:Ore in ores do
        local random = Utils.createRandom(SEED, cx, cz,ore.salt or i*2+3)
        local chance = ore.chance
        if random:NextInteger(1, chance) == 1 then continue end
        local yHeight = Distribution.sample(ore.randomY,random)//1

        local ofx = random:NextInteger(1, 8)
        local ofz = random:NextInteger(1, 8)

        local idx = to1dXZ[ofx][ofz]
        local height = buffer.readu8(surface, idx-1)
        if yHeight > height then continue end 
        Carver2.noiseSphere(cx,cz,ofx,yHeight,ofz,ore.block,carver,ore.noiseSettings,ore.noiseScale,ore.minRange,ore.maxRange,true)
    end
    debug.profileend()
end

function ore.addRegirstry(b)
    Biomes = b
end
return ore