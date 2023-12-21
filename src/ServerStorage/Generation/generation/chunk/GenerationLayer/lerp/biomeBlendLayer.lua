local BlendLayer = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator =  require(ChunkGeneration.Generator)
local Layer = require(ChunkGeneration.GenerationLayer)
function BlendLayer.compute(layer,chunk)
    local C,T,L,TL
    local Thread = coroutine.running()
    local Done = 0
    task.spawn(function() 
        C = Layer.get(layer[2],chunk)
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    task.spawn(function()
        T = Layer.get(layer[2],chunk+Vector3.xAxis)
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    task.spawn(function()
        L = Layer.get(layer[2],chunk+Vector3.zAxis)
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    task.spawn(function()
        TL = Layer.get(layer[2],chunk+Vector3.new(1,0,1))
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    if Done ~= 4 then coroutine.yield() end 
    if type(C[5]) ~= 'number' or type(T[5]) ~= 'number' or type(L[5]) ~= 'number' or type(TL[5]) ~= 'number' then
        local t = Generator.blendNoise(C[1],T[1],L[1],TL[1])
        C[6] = t
    end
    return C
end

return BlendLayer