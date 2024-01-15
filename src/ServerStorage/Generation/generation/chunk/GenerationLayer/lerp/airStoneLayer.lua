local AirLayer = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator =  require(ChunkGeneration.Generator)
local Layer = require(ChunkGeneration.GenerationLayer)


function AirLayer.compute(layer,chunk)
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
        local x,z = Generator.getBlendedAirMap(C[6] or C[1],T[6] or T[1],L[6] or L[1],TL[6] or TL[1],C[5])
        return {x,z}
    end
    Done = 0
    Thread = coroutine.running()
    local data = {}
    local surface = {}
    task.spawn(function()
        data[1],surface[1] = Generator.getAirMap(C[1],C[2],C[3],C[4],1,C[5])
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    task.spawn(function()
        data[2],surface[2] = Generator.getAirMap(C[2],T[1],C[4],T[3],2,C[5])
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    task.spawn(function()
        data[3],surface[3] = Generator.getAirMap(C[3],C[4],L[1],L[2],3,C[5])
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    task.spawn(function()
        data[4],surface[4] = Generator.getAirMap(C[4],T[3],L[2],TL[1],4,C[5])
        Done+=1
        if Done == 4 then
            coroutine.resume(Thread)
        end
    end)
    if Done ~= 4 then coroutine.yield() end 
    return {data,surface}
end

return AirLayer