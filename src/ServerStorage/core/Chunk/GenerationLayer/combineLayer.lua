local Combine = {}
local Data = require(game.ReplicatedStorage.Data)
local Chunk = require(game.ReplicatedStorage.Chunk)
local Generator =  require(game.ServerStorage.core.Chunk.Generator)
local Layer = require(game.ServerStorage.core.Chunk.GenerationLayer)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local offsetTable = {
    Vector3.zero,
    Vector3.new(4),
    Vector3.new(0,0,4),
    Vector3.new(4,0,4)
}
function Combine.compute(layer,chunk)
    local last = Layer.get(layer[2],chunk)
    return Generator.combine(unpack(last))
end

return Combine