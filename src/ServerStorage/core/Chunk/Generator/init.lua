local Generator = {}
local Chunk = require(game.ReplicatedStorage.Chunk)
local BlockPool = require(game.ReplicatedStorage.Block.BlockPool)
local BiomeWorkers = require(script.WorkerHandler).create("Biomes",6)
local OtherWorkers = require(script.WorkerHandler).create("Biomes",14)
function Generator.createBlocks(chunk)
    if Chunk.getStatus(chunk, "Generated") then return false end 
    for x = 0, 7 do
        for z = 0, 7 do
            Chunk.insertBlockAt(chunk, x,60,z, true)
        end
    end
    Chunk.insertBlockAt(chunk, 1,61,1, true)
    Chunk.insertBlockAt(chunk, 2,61,1, true)
    Chunk.setStatus(chunk, "Generated",true) 
    return true
end
function Generator.createBiomeMap(cx,cz)
   return BiomeWorkers:DoWork("createBiomeMap",cx,cz)
end
function Generator.createDensityMap(cx,cz,biome)
    return OtherWorkers:DoWork("sampleDensityNoise",cx,cz,biome)
end
function Generator.getAirMap(c,t,l,tl)
    return OtherWorkers:DoWork("computeAir",c,t,l,tl)
end
function Generator.combine(x1,x2,x3,x4)
    return OtherWorkers:DoWork("combine",x1,x2,x3,x4)
end
return Generator