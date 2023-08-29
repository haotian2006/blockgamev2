local biome = {}
local RandomState,MappedRouter,Visitor
local gamesettings = require(game.ReplicatedStorage.GameSettings)
local Climate = require(game.ServerStorage.Deepslate.worldgen.biome.Climate)
local cs = gamesettings.ChunkSize
local csx,csy = cs.X,cs.Y
local MultiNoiseHandler = require(game.ServerStorage.Deepslate.worldgen.biome.MultiNoiseBiomeSource)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local BiomeGetter 
export type continents = number
export type erosion = number
export type weirdness = number
export type temperature = number
export type humidity = number
export type depth = number
function biome:Init(RS,MR,V)
    RandomState = RS
    MappedRouter = MR
    Visitor = V
    local allbiomes = BehaviorHandler.Biomes or {}
    BiomeGetter = MultiNoiseHandler.Evaluate(allbiomes)
end
function biome.get2DNoiseValues(x,z): (continents,erosion,weirdness)
    local pos = Vector3.new(x,0,z)
    local continents = MappedRouter.continents
    local erosion = MappedRouter.erosion 
    local weirdness =  MappedRouter.weirdness 
    return continents and continents:compute(pos),
    erosion and erosion:compute(pos),
    weirdness and weirdness:compute(pos)
end
function biome.get3DNoiseValues(x,y,z): (temperature,humidity,depth)
local pos = Vector3.new(x,y,z)
  local temperature = MappedRouter.temperature
  local humidity = MappedRouter.humidity
  local depth =  MappedRouter.depth
  return temperature and temperature:compute(pos), humidity and humidity:compute(pos), depth and depth:compute(pos)
end
function biome.newTable(temperature,humidity,continents,erosion,depth,weirdness)
    return {temperature,humidity,continents,erosion,depth,weirdness}
end
function biome.fromTable(t)
    return Climate.target(unpack(t))
end
biome.newTarget = Climate.target
function biome.generateBiomesMap(cx,cz)
    local offx,offz = gamesettings.getoffset(cx,cz)
    for x = 0,csx-1,4 do
        for z = 0,csx-1,4 do
            local rx,rz = offx+x,offz+z
            local continents,erosion,weirdness = biome.get2DNoiseValues(rx,rz)
            for y = 0,csy-1,4 do
                local temperature,humidity = biome.get3DNoiseValues(rx,y,rz)
                local target = Climate.target(temperature,humidity,continents,erosion,1)
            end
        end
    end
end
return biome