local Utils = {}
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local CSIZE_X,CSIZE_Y = GameSettings.getChunkSize()
local GRID_SIZE = GameSettings.GridSize
--//Assume x,y,z will be grid unless told in the name
function Utils.getChunkAndLocal(x,y,z)
    local cx,cz = Utils.getChunk(x,y,z) 
    local lx,ly,lz = x%CSIZE_X,y,z%CSIZE_Y
    return cx,cz,lx,ly,lz
end
function Utils.getChunk(x,y,z)
	return math.floor((x+0.5)/CSIZE_X), math.floor((z+0.5)/CSIZE_X)
end
function Utils.convertLocalToGrid(cx,cz,x,y,z):Vector3
    return Vector3.new((x+CSIZE_X*cx),y,(z+CSIZE_X*cz))
end
return Utils