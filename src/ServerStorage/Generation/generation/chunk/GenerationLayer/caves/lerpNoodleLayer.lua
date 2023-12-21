local lerpNoodle = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator =  require(ChunkGeneration.Generator)
local Layer = require(ChunkGeneration.GenerationLayer)

function lerpNoodle.compute(layer,chunk)
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
    Done = 0
    Thread = coroutine.running()
    local data = {}
    task.spawn(function()
        data[1] = Generator.DoWork("lerpNoodleNoise",C[1],C[2],C[3],C[4])
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    task.spawn(function()
        data[2] = Generator.DoWork("lerpNoodleNoise",C[2],T[1],C[4],T[3])
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    task.spawn(function()
        data[3] =Generator.DoWork("lerpNoodleNoise",C[3],C[4],L[1],L[2])
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    task.spawn(function()
        data[4] = Generator.DoWork("lerpNoodleNoise",C[4],T[3],L[2],TL[1])
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    if Done ~= 4 then coroutine.yield() end 
    return Generator.DoWork("shapeCombine",unpack(data))
end

return lerpNoodle