local worms ={}
local Noise = require(script.Parent.Parent.Parent.Parent.math.noise)
local Math = require(script.Parent.Parent.Parent.Parent.math.utils)
local carver = require(script.Parent.Parent.Parent.Parent.math.carver)
local carver2 = require(script.Parent.Parent.Parent.Parent.math.Carver2)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Storage = require(game.ServerStorage.core.Chunk.Generator.ChunkDataLocal)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local to1d = IndexUtils.to1D

local lerpMap = Math.clampedMap

function worms.new(seed,maxDistance,maxRange,amplitude,weight,sampleInterval,maxSections,chance)
    return {seed,Noise.newBasic(seed,1),Noise.newBasic(seed,20),Noise.newBasic(seed,4),maxDistance,maxRange,amplitude,weight or 5,sampleInterval,chance or 5,maxSections}
end

function worms.parse(seed,settings)
    return worms.new(seed, settings.maxDistance or 0, settings.maxRange or 0, settings.amplitude or 1, settings.weight or .5, settings.interval or 10, settings.maxSections or 3, settings.chance or 20)
end

local function getAngle(x,y,z,n,getValue)
    local value = Noise.basicSample(n, x, y, z)
    if getValue then return value end 
    return (lerpMap(value,-1.5,1.5,-180,180))
end

local function getDir(x,y,z,n1,n2,n3,scale)
    x,y,z = x*scale,y*scale,z*scale
    local rx = getAngle(x, y, z, n1)
    local ry = getAngle(x, y, z, n2)
    local rz = getAngle(x, y, z, n3)
    local dir = CFrame.fromOrientation(rx, ry, rz).LookVector
   -- dir = Vector3.new(dir.X,Math.lerp(.2, lastY, dir.Y),dir.Z)
    return dir
end

function worms.sample(self,cx,cz,DEBUG)
    local RandomO = Math.createRandom(self[1],cx,cz,73) 
    --if RandomO:NextInteger(0, self[10]) ~= 1 then return false end 
    debug.profilebegin("caves")
    local n1,n2,n3 = self[2],self[3],self[4]
    local maxDistnace = self[5]
    local maxRange = self[6]
    local amplitude = self[7] or 1
    local weight = self[8] or 1
    local sampleInterval = self[9] or 1

    local maxSplits = 1--RandomO:NextInteger(1, self[11])
    local ofx,ofz = cx*8,cz*8
    local startingX = RandomO:NextInteger(0, 7)
    local startingZ = RandomO:NextInteger(0, 7)
    local startingY = RandomO:NextInteger(30, 80)
    local radius = RandomO:NextInteger(2,5)
    local carved = {}

    local checked = {}
    local currentBuffer = Storage.rawGetOrCreate(Vector3.new(cx,0,cz)).Carved
    local Lcx,Lcz  = cx,cz
    for split =1,maxSplits do
        
        local current = Vector3.new(startingX,startingY,startingZ)
        local maxLength = RandomO:NextInteger(3, maxDistnace)
        local direaction
        local yOffset = RandomO:NextInteger(-1000,1000)
        local endDir = RandomO:NextUnitVector()
        if endDir.Y <=.5 then
            endDir = Vector3.new(endDir.X,.5,endDir.Z).Unit
        end
        if endDir.Y >= -.5 then
            endDir = Vector3.new(endDir.X,-.5,endDir.Z).Unit
        end

        local endPoint = current+endDir*maxLength
        local shaper = carver2.getSphere(radius)
        local chunkOffset = Vector3.new(ofx,0,ofz)
        for x = 0,maxLength do
            if x%sampleInterval == 0 then
                direaction = getDir(current.X, current.Y-yOffset, current.Z, n1, n2, n3, amplitude)
                local dirToConver = (endPoint-current).Unit
                direaction = (direaction*(1-weight)+dirToConver*weight).Unit
            end
            local rounded = (current+Vector3.one*.5)//1
            local ccx,ccz = ConversionUtils.getChunk(rounded.X+ofx,0,rounded.Z+ofz)
            if math.sqrt((cx-ccx)^2+(cz-ccz)^2) > 5 then break end 
            debug.profilebegin("Sphere")

            local Center = rounded+chunkOffset
            for i,offset in shaper do
                local new = Center+offset
                if checked[new] then continue end 
                checked[new] = true
                local ncx,ncz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(new.X, new.Y, new.Z)
                if ly > 255 or ly <0 then continue end 
                if ncx ~= Lcx or ncz ~= Lcz then
                    currentBuffer = Storage.rawGetOrCreate(Vector3.new(ncx,0,ncz)).Carved
                    Lcx,Lcz = ncx,ncz
                end
                local to1d = to1d[lx][ly][lz]
                buffer.writeu16(currentBuffer, (to1d-1)*2, 0)
            end
            debug.profileend()
            current+= direaction 
        end
    end
    debug.profileend()
    return true 
end
return worms