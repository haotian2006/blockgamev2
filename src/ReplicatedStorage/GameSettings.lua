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
local farea = (settings.ChunkSize.X)*(settings.ChunkSize.Y) 
function settings.to1D(x,y,z,toString)
    if toString then
        return tostring(x + y * settings.ChunkSize.X + z *farea+1)
    end
    return x + y * settings.ChunkSize.X + z *farea+1
end
function settings.to3D(index)
    index = tonumber(index) - 1
	local x = index % settings.ChunkSize.X
	index = math.floor(index / settings.ChunkSize.X)
	local y = index % settings.ChunkSize.Y
	index = math.floor(index / settings.ChunkSize.Y)
	local z = index % settings.ChunkSize.X
	return x, y, z
end
function settings.to1DXZ(x,z,toString)
    if toString then
        return tostring(x +z  *settings.ChunkSize.X + 1)
    end
    return x + z *settings.ChunkSize.X + 1
end
function settings.to2D(index)
    index = tonumber(index) - 1
    local x = index % settings.ChunkSize.X 
    local y = math.floor(index /settings.ChunkSize.X )
    return x, y
end
function settings.convertchgridtoreal(cx,cz,x,y,z):Vector3
    return (x+settings.ChunkSize.X*cx),y,(z+settings.ChunkSize.X*cz)
end
meta.__index = settings
meta.__metatable = "No Metatable for you hahahaha"
return settings 