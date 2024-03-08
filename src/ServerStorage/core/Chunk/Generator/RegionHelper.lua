local Region = {}
local Config = require(script.Parent.Config)

local TotalActors = Config.Actors
local RegionSize = Config.RegionSize

local Debirs = require(game.ReplicatedStorage.Libarys.Debris)
local RegionFolder = Debirs.getFolder("RegionHelper", 10)

function Region.getIndexFromRegion(x, y)
    local index = ((x % TotalActors) + (y % TotalActors)) % TotalActors + 1
    return index
end

function Region.getRegion(chunk): Vector3
    return chunk//RegionSize
end

function Region.localizeChunk(chunk)
    local localizedX = chunk.X % RegionSize+1
    local localizedY = chunk.Z % RegionSize+1
    return Vector3.new(localizedX, 0, localizedY)
end

function Region.deLocalizeChunk(region,chunk)
    return region*RegionSize+chunk
end

function Region.getAllChunksInRegion(rx,ry)
    local chunks = {}
    local idx = 1
    for x = rx * RegionSize, (rx + 1) * RegionSize - 1 do
        for y = ry * RegionSize, (ry + 1) * RegionSize - 1 do
            chunks[idx] = Vector3.new(x, 0, y)
            idx+=1
        end
    end
    return chunks
end

function Region.GetIndexFromChunk(chunk)
    local cached = RegionFolder:get(chunk)
    if cached then
        return cached
    end
    local region = chunk//RegionSize
    local x,y = region.X,region.Z
    local index = ((x % TotalActors) + (y % TotalActors)) % TotalActors + 1
    RegionFolder:set(chunk,index)
    return  index
end

Region.To1D = {}
Region.To1DVector = {}
Region.to2D = {}

local PreComputed2D = Region.To1D 
local function preCompute2D()
    for x = 1,RegionSize do
        PreComputed2D[x] = PreComputed2D[x] or {}
        for z = 1,RegionSize do
            local idx =  (x-1)+(z-1) *RegionSize+1
            Region.To1D[x][z] =  idx
            Region.to2D[idx] = Vector3.new(x,0,z)
            Region.To1DVector[Vector3.new(x,0,z)] = idx
        end
    end
end
preCompute2D()

return Region