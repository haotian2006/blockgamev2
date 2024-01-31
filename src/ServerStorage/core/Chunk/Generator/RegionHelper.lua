local Region = {}
local Config = require(script.Parent.Config)
local TotalActors = Config.Actors
local RegionSize = Config.RegionSize

local Debirs = require(game.ReplicatedStorage.Libarys.Debris)
local RegionFolder = Debirs.getOrCreateFolder("RegionHelper", 10)
function Region.getIndexFromRegion(x, y)
    local index = ((x % TotalActors) + (y % TotalActors)) % TotalActors + 1
    return index
end
function Region.getRegion(chunk)
    return chunk//RegionSize
end

function Region.GetIndexFromChunk(chunk)
    local cached = RegionFolder:get(chunk)
    if cached then
        return cached
    end
    local region = chunk//RegionSize
    local x,y = region.X,region.Y
    local index = ((x % TotalActors) + (y % TotalActors)) % TotalActors + 1
    RegionFolder:add(chunk,index)
    return  index
end

return Region