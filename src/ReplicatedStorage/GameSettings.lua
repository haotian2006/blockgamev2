local settings = {}
local proxy = newproxy(true)
local meta = getmetatable(proxy)
settings.ServerReplicationRate = 1/20
settings.ClientReplicationRate = 1/30
settings.Version = 0.01
settings.GridSize = 3
settings.ChunkSize = Vector2.new(8,128)
settings.LargeChunkSize = 30 -- n x n
settings.MaxBuildHeight = 200
settings.MaxEntityRunDistance = 5--Chunks 
settings.Seed = 1234567
function settings.GetDistFormChunks(chunk)
    return settings.ChunkSize.X*chunk
end
function settings.gridToreal(x:Vector3|number)
    return x*settings.GridSize
end
meta.__index = settings
meta.__metatable = "No Metatable for you hahahaha"
return proxy 