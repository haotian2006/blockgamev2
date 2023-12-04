local Generator = {}
local Chunk = require(game.ReplicatedStorage.ChunkV2)
local BlockPool = require(game.ReplicatedStorage.BlockPool)
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
return Generator