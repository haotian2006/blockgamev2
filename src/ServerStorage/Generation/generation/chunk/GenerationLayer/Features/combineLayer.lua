local Combine = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator =  require(ChunkGeneration.Generator)
local Layer = require(ChunkGeneration.GenerationLayer)
local maxR = 6
function Combine.compute(layer,chunk,...)
    local t = coroutine.running()
    maxR =   layer[3] or maxR
    local r = maxR^2
    if not layer[4] then
        layer[4] = {}
        for x = -maxR,maxR do
            for z = -maxR,maxR do
                if x*x+z*z > r then continue end 
                table.insert(layer[4],Vector3.new(x,0,z))
            end
        end
    end
    
    local worms = {}
    local finished = 0
    local amt = 0
    local strC = `{chunk.X},{chunk.Z}`
    local looping = false
    for i,v in layer[4] do
        amt += 1
        task.spawn(function(a,b)
            if a then
                a = a[chunk+v][1]
            end
            local data = Layer.get(layer[2],Vector3.new(chunk.X,0,chunk.Z)+v,a,b)[strC]
            if data then
                table.insert(worms,data)
            end
            finished+=1
            if amt == finished and looping then 
                coroutine.resume(t)
            end
        end,...)
    end
    looping = true
    if amt ~= finished then 
        coroutine.yield()
    end
    return worms
end

return Combine