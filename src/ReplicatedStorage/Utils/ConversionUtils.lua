--// Local  =   0-chunksize.X-1
--// Grid   =   x,y,z
--// Real   =   (x,y,z)*BlockSize
--// Not Name = Grid

local Utils = {}

local GameSettings = require(game.ReplicatedStorage.GameSettings)
local Chunk_Width
local Chunk_Height
local Block_Size = GameSettings.GridSize
Chunk_Width,Chunk_Height = GameSettings.getChunkSize()

function Utils.getoffset(cx,cz):Vector3
    return (Chunk_Width*cx),(Chunk_Width*cz)
end
function Utils.gridToLocalAndChunk(x,y,z)
    local cx,cz = Utils.getChunk(x,y,z) 
    local lx,ly,lz = x%Chunk_Width,y,z%Chunk_Width
    return cx,cz,lx,ly,lz
end

function Utils.gridToLocal(x,y,z)
    local lx,ly,lz = x%Chunk_Width,y,z%Chunk_Width
    return lx,ly,lz
end

function Utils.getChunk(x,y,z)
	return (x+0.5)//Chunk_Width, (z+0.5)//Chunk_Width
end

function Utils.localToGrid(cx,cz,x,y,z):Vector3
    return Vector3.new((x+Chunk_Width*cx),y,(z+Chunk_Width*cz))
end

return Utils 