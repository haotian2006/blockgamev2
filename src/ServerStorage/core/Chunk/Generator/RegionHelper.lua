local Region = {}
local Config = require(script.Parent.Config)
local TotalActors = Config.Actors
local RegionSize = Config.RegionSize

function Region.getIndexFromRegion(x, y)
    local index = ((x % TotalActors) + (y % TotalActors)) % TotalActors + 1
    return index
end
function Region.getRegion(chunk)
    return chunk//RegionSize
end
local f = Region.getIndexFromRegion
function Region.GetIndexFromChunk(chunk)
    local region = chunk//RegionSize
    local x,y = region.X,region.Y
    return  ((x % TotalActors) + (y % TotalActors)) % TotalActors + 1
end

return Region