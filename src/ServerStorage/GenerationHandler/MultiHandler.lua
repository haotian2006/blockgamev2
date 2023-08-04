local mul = {}
local chunk = require(game.ReplicatedStorage.Chunk)
local settings = require(game.ReplicatedStorage.GameSettings)
local genhandler = require(script.Parent)

function mul.GenerateCaves(cx,cz)
    local data = genhandler.CreateWorms(cx,cz,true)
    return data
end
function mul.GenerateTerrain(cx,cz)
    local data = genhandler.GenerateTerrain(cx,cz,true)
    return chunk:CompressVoxels(data,true)
end
return mul