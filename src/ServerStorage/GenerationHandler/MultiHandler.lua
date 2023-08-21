local mul = {}
local chunk = require(game.ReplicatedStorage.Chunk)
local settings = require(game.ReplicatedStorage.GameSettings)
local terrianhandler = require(script.Parent.TerrianHandler)
local genhandler = require(script.Parent)
function mul.GenerateCaves(cx,cz)
    local data = genhandler.CreateWorms(cx,cz,true)
    return data
end
function mul.GenerateTerrain(cx,cz)
    local data = genhandler.GenerateTerrain(cx,cz,true)
    return data
end
function mul.SmoothTerrian(cx,cz,data)
    local data = genhandler.SmoothTerrian(cx,cz,data)
    return data
end
function mul.test(cx,cz,data)
    return {}
end
return setmetatable(mul,{__index = function(self,key)
    mul[key] = genhandler[key] or terrianhandler[key]
    return mul[key] or error(key.." Is not a valid generation function")
end})