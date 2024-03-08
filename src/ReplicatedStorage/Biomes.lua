local Biome = {}
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)

local Synchronizer = require(game.ReplicatedStorage.Synchronizer)
local Loading = require(game.ReplicatedStorage.Libarys.Signal).new()
local Block = require(game.ReplicatedStorage.Block)

local Biomes = {
    --'c:ocean',
    'c:plains',
    "c:snow",
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

function Biome.exists(str)
    if Cache[str] then
        return true
    end 
    local loc = table.find(Biomes, str)
    Cache[str] = if loc then loc-1 else nil
    return if loc then true else false 
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

local function parseBiome(name,Data)
    Data.SurfaceBlock = Block.parse(Data.SurfaceBlock or "c:grassBlock")
    Data.SecondaryBlock = Block.parse(Data.SecondaryBlock or "c:dirt")
    Data.MainBlock = Block.parse(Data.MainBlock or "c:stone")
end

function Biome.init()
    for biomeName,biomeData in BehaviorHandler.getAllData().Biomes do
        parseBiome(biomeName, biomeData)
    end
   -- print(BehaviorHandler.getAllData().Biomes)
    if Synchronizer.isActor() then
        Biomes = Synchronizer.getDataActor("Biomes")
    elseif Synchronizer.isClient() then
        Biomes = Synchronizer.getDataClient("Biomes")
    else
        local Saved = Synchronizer.getSavedData("Biomes")
        if Saved then
            Biomes = Saved
        end
        local newAdded = false
        for biomeName,biomeData in BehaviorHandler.getAllData().Biomes do
            if Biome.exists(biomeName) then continue end 
            table.insert(Biomes,biomeName)
            newAdded = true
        end
        if newAdded then
            Synchronizer.updateSavedData("Biomes",Biomes)
        end
        Synchronizer.setData("Biomes",Biomes)
    end
    Loading:Fire()
    Loading = nil
    return Biome
end

return Biome