local Noodle = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator =  require(ChunkGeneration.Generator)
local Layer = require(ChunkGeneration.GenerationLayer)

function Noodle.compute(layer,chunk)
    local t = coroutine.running()
    local done = 0
    local data = {}
    for z = 0,1 do
        for x = 0,1 do
            task.spawn(function()
                data[(x+z*2)+1] = Generator.DoWork("sampleNoodleNoise",chunk.X,chunk.Z,x,z)
                done+=1
                if done == 4 then
                    coroutine.resume(t)
                end
            end)
        end
    end
    if done == 4 then return data end
    coroutine.yield()
    return data
end

return Noodle