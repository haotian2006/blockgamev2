local qf = {}
local settings = require(game.ReplicatedStorage.GameSettings)
function  qf.to1D(x,y,z)
    local dx,dy = settings.ChunkSize.X,settings.ChunkSize.Y
    return (z * dx * dy) + (y * dx) + x
end
function qf.to3D(coord)
    local dx,dy = settings.ChunkSize.X,settings.ChunkSize.Y
    local z = math.floor(coord / (dx * dy))
	coord -= (z * dx * dy)
	local y = math.floor(coord / dx)
	local x = coord % dx
    return Vector3.new(x,y,z)
end
function qf.DecompressBlockData(data:string)
    
end
return qf 