local settings = {}
local proxy = newproxy(true)
local meta = getmetatable(proxy)
settings.ServerReplicationRate = 1/20
settings.ClientReplicationRate = 1/30
settings.Version = 0.01
settings.GridSize = 3
settings.ChunkSize = Vector2.new(8,256)
settings.LargeChunkSize = 30 -- n x n
settings.MaxBuildHeight = 200
settings.MaxEntityRunDistance = 5--Chunks 
settings.Seed = 1234567
local chsizex = settings.ChunkSize.X
local chsizey = settings.ChunkSize.Y
function settings.getChunkSize()
    return settings.ChunkSize.X,settings.ChunkSize.Y
end
function settings.GetDistFormChunks(chunk)
    return settings.ChunkSize.X*chunk
end
function settings.gridToreal(x:Vector3|number)
    return x*settings.GridSize
end
local farea = (settings.ChunkSize.X)*(settings.ChunkSize.Y) 
settings.CONST_XYZ1D = {}
settings.CONST_3D = {}
local init = false
local CONSTXYZ = settings.CONST_XYZ1D 
local function createxyz()
    init = true
    for x = 0,chsizex-1 do
        CONSTXYZ[x] = CONSTXYZ[x] or {}
        for z = 0,chsizex-1 do
            CONSTXYZ[x][z] = CONSTXYZ[x][z] or {}
            for y = 0,chsizey-1 do
                CONSTXYZ[x][z][y] =  x + y * chsizex + z *farea+1
                settings.CONST_3D[CONSTXYZ[x][z][y]] = {x,y,z}
            end
        end
    end
end
function settings.to1D(x,y,z)
    if not init then createxyz() end 
    return CONSTXYZ[x][z][y]
   -- return x + y * chsizex + z *farea+1
end
function settings.to3D(index)
    if not init then createxyz() end 
    return unpack( settings.CONST_3D[tonumber(index)])
    -- index = tonumber(index) - 1
	-- local x = index % chsizex
	-- index = math.floor(index / chsizex)
	-- local y = index % chsizey
	-- index = math.floor(index / chsizey)
	-- local z = index % chsizex
	-- return x, y, z
end
function settings.to1DXZ(x,z)
    return x + z *chsizex + 1
end
function settings.to2D(index)
    index = tonumber(index) - 1
    local x = index % chsizex
    local y = math.floor(index /chsizex)
    return x, y
end
function settings.convertchgridtogrid(cx,cz,x,y,z):Vector3
    return (x+chsizex*cx),y,(z+chsizex*cz)
end
function settings.getoffset(cx,cz):Vector3
    return (chsizex*cx),(chsizex*cz)
end
settings.maxChunkSize =  (settings.ChunkSize.X)*(settings.ChunkSize.Y) *(settings.ChunkSize.X)
meta.__index = settings
meta.__metatable = "No Metatable for you hahahaha"
return settings 