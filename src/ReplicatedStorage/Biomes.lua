local Biome = {}
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local Biomes = {
    'c:ocean',
    'c:plains',
    "c:ice",
    'c:hill',
    'c:desert',
}

local Cache = {}
function Biome.getBiomeId(str)
    if Cache[str] then
        return Cache[str]
    end
    local loc = table.find(Biomes, str)
    if loc == -1 then
        error(`'{str}' is not a valid block`)
    end
    Cache[str] = loc-1
    return loc-1
end

function Biome.getBiomeFrom(id)
    return Biomes[id+1]
end

function Biome.getBiomeData(str)
    if type(str) == "number" then
        str = Biomes[str+1]
    end
    return BehaviorHandler.getBiome(str) or warn(`'{str}' not found`)
end

return Biome