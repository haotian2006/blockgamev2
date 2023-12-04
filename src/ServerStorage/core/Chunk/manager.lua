local manager = {}
local Remote:RemoteEvent = game.ReplicatedStorage.Events.ChunkV2
local Data = require(game.ReplicatedStorage.Data)
local Generator = require(script.Parent.Generator)

Remote.OnServerEvent:Connect(function(player,x,z)
    local chunk = Data.getChunkOrCreate(x,z)
    Generator.createBlocks(chunk)
    Remote:FireClient(player,x,z,chunk.Blocks)
end)

return manager 