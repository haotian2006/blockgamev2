local Data = {}
local SEED = 0
local Biomes = {}
local Noise = {}

local NoiseCreator = require(script.Parent.math.noise)

function Data.getAllBiomes()
    
end
function Data.getBiome()
    
end
function Data.getBiomeLoc()
    
end
function Data.load(t)
    
end
function Data.addBiome(t)
    
end

function Data.getNoise(name)
    return Noise[name]
end

function Data.createNoise(Name,data)
    Noise[Name] = NoiseCreator.new(SEED+data.Offset or 0, data.firstOctave, data.amplitudes, data.persistance, data.lacunarity)
    return Noise[Name]
end

function Data.setSeed(seed)
    SEED = seed
end
function Data.getSeed()
    return SEED
end

return table.freeze(Data)