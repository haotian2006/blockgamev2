local Generator = {}
local Chunk = require(game.ReplicatedStorage.Chunk)
local BlockPool = require(game.ReplicatedStorage.Block.BlockPool)
local BiomeWorkers = require(script.WorkerHandler).create("Biomes",6)
local OtherWorkers = require(script.WorkerHandler).create("Biomes",14)
function Generator.DoWork(task,...)
    return OtherWorkers:DoWork(task,...)
end
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
function Generator.blendNoise(C,N,E,NE)
    return OtherWorkers:DoWork("blendNoise",C,N,E,NE) 
end
function Generator.createDensityMap(cx,cz,biome)
    return OtherWorkers:DoWork("sampleDensityNoise",cx,cz,biome)
end
function Generator.getAirMap(c,t,l,tl,loc,biomes)
    return OtherWorkers:DoWork("computeAir",c,t,l,tl,loc,biomes)
end
function Generator.getBlendedAirMap(c,t,l,tl,biome)
    return OtherWorkers:DoWork("computeBlendedAir",c,t,l,tl,biome)
end
function Generator.shapeCombine(x1,x2,x3,x4)
    return OtherWorkers:DoWork("shapeCombine",x1,x2,x3,x4)
end
function Generator.surfaceCombine(x1,x2,x3,x4)
    return OtherWorkers:DoWork("surfaceCombine",x1,x2,x3,x4)
end

return Generator