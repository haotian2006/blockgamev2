local Tasks = game.ServerStorage.core.Chunk.Generator.Tasks
local ChunkLayer = require(game.ServerStorage.core.Chunk.Generator.ChunkLayer)
local Communicator =  require(game.ServerStorage.core.Chunk.Generator.Communicator)
local shaper = require(Tasks.Shaper)

local StoneAir = {}

function StoneAir.compute(self,chunk)
    local C,T,L,TL = chunk,chunk+Vector3.xAxis,chunk+Vector3.zAxis,chunk+Vector3.zAxis+Vector3.xAxis
    local toCompute = {
            {C,1},-- 1
            {C,2},-- 2
            {C,3},-- 3
            {C,4},-- 4
            {T,1},-- 5
            {T,3},-- 6
            {L,1},-- 7
            {L,2},-- 8
            {TL,1}-- 9
    }
    for i,v in toCompute do
        toCompute[i] = ChunkLayer.get(self[2],v[1]+Vector3.new(0,v[2]))
    end
    local b = buffer.create(8*8*256*4)
    local surface = buffer.create(8*8)

    shaper.computeAir(toCompute[1],toCompute[2],toCompute[3],toCompute[4],b,surface,0,0)
    shaper.computeAir(toCompute[2],toCompute[5],toCompute[4],toCompute[6],b,surface,1,0)
    shaper.computeAir(toCompute[3],toCompute[4],toCompute[7],toCompute[8],b,surface,0,1)
    shaper.computeAir(toCompute[4],toCompute[6],toCompute[8],toCompute[9],b,surface,1,1)
    
    return {b,surface}
end

return StoneAir 