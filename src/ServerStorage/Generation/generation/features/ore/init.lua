local ore = {}
local Utils = require(script.Parent.Parent.Parent.math.utils)
local NoiseHandler = require(script.Parent.Parent.Parent.math.noise)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local Carver = require(script.Parent.Parent.Parent.math.carver)
local SEED = 12345
function ore.init(seed)
    SEED = seed
end

local function getOreFrom(biome)

end

--[[
    {
    Name : String,
    Block : table,
    Chance: number|table,
    MaxDensity: number,
    YRange:number,
    CarverSettings : table,
    }
]]
function ore.parse(settings)
     
end
function ore.sample(cx,cz,surface,biome)
    local random = Utils.createRandom(SEED, cx, cz)
    local ores = getOreFrom(biome)
    local carver = {}
    for i,ore in ores do
        local chance = ore.Chance
        if random:NextInteger(1, chance) == 1 then continue end
        local yHeight = random:NextInteger(0, ore.YRange)
        local ofx = random:NextInteger(0, 7)
        local ofz = random:NextInteger(0, 7)
        Carver.noise(cx,cz,ofx,yHeight,ofz,ore.Block,carver,ore.NoiseSettings,ore.MaxDensity)
    end
    return carver
end
return ore