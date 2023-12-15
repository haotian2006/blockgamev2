--!nocheck
local settings = {}
settings.ServerReplicationRate = 1/20
settings.ClientReplicationRate = 1/30
settings.Version = 0.01
settings.GridSize = 3
settings.ChunkSize = Vector3.new(8,256,8)
settings.LargeChunkSize = 30 -- n x n
settings.MaxBuildHeight = 200
settings.MaxEntityRunDistance = 5--Chunks 
settings.Seed = 1234567
function settings.getChunkSize()
    return settings.ChunkSize.X,settings.ChunkSize.Y
end

settings.maxChunkSize =  (settings.ChunkSize.X)*(settings.ChunkSize.Y) *(settings.ChunkSize.X)

return table.freeze(settings) 