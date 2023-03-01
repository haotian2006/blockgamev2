local settings = {}
settings.Version = 0.01
settings.GridSize = 3
settings.ChunkSize = Vector2.new(8,128)
settings.LargeChunkSize = 30 -- n x n
settings.MaxBuildHeight = 200
settings.MaxEntityRunDistance = 5--Chunks 
function settings.GetDistFormChunks(chunk)
    return settings.ChunkSize.X*chunk
end
function settings.gridToreal(x:Vector3|number)
    return x*settings.GridSize
end
return settings 