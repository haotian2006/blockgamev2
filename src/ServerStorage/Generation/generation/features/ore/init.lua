local ore = {}
local Utils = require(script.Parent.Parent.Parent.math.utils)
local NoiseHandler = require(script.Parent.Parent.Parent.math.noise)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local Carver = require(script.Parent.Parent.Parent.math.carver)
local SEED = 120
function ore.init(seed)
    SEED = seed
end

local function getOreFrom(biome)
    return {
        { 
            block = 0,
            chance =1,
            minRange = 0,
            maxRange = 3,
            yRange = 100,
            noiseScale = 5,
            noiseSettings = NoiseHandler.parse(SEED,{
                amplitudes = {1},
                firstOctave = -3
            })
        }
    }
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
function ore.parse(settings)
     
end
function ore.sample(cx,cz,surface,biome)
    debug.profilebegin("Create Ore")
    local random = Utils.createRandom(SEED, cx, cz)
    local ores = getOreFrom(biome)
    local carver = {}
    for i,ore in ores do
        local chance = ore.chance
      --  if random:NextInteger(1, chance) == 1 then continue end
        local yHeight = random:NextInteger(0, ore.yRange)

        local ofx = random:NextInteger(0, 7)
        local ofz = random:NextInteger(0, 7)
        
        Carver.noiseSphere(cx,cz,ofx,yHeight,ofz,ore.block,carver,ore.noiseSettings,ore.noiseScale,ore.minRange,ore.maxRange)
    end
    debug.profileend()
    return Carver.toArray(carver)
end
return ore