local worms ={}
local Noise = require(script.Parent.Parent.Parent.Parent.math.noise)
local Math = require(script.Parent.Parent.Parent.Parent.math.utils)
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
    local RandomO = Random.new(Math.jenkins_hash(`{self[1]}{cx}_{cz}`))
    if RandomO:NextInteger(0, self[10]) ~= 1 then return end 
    local n1,n2,n3 = self[2],self[3],self[4]
    local maxDistnace = self[5]
    local maxRange = self[6]
    local amplitude = self[7] or 1
    local weight = self[8] or 1
    local sampleInterval = self[9] or 1

    local maxSplits = RandomO:NextInteger(1, self[11])
    local ofx,ofz = cx*8,cz*8
    local startingX = RandomO:NextInteger(0, 7)+ofx
    local startingZ = RandomO:NextInteger(0, 7)+ofz
    local startingY = RandomO:NextInteger(10, 60)
    local DEBUGM:Model
    if DEBUG then
        DEBUGM = Instance.new("Model")
        DEBUGM.Name = "CAVES"
        DEBUGM.Parent = workspace
        local p = Instance.new("Part")
        p.Size = Vector3.new(6,6,6)
        p.Position = Vector3.new(startingX,startingY,startingZ)*3
        p.Anchored = true
        p.Parent = DEBUGM
        p.BrickColor = BrickColor.Red()
    end
    for split =1,maxSplits do
        local c = BrickColor.random()
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
        -- repeat 
        --     endDir = RandomO:NextUnitVector()
        -- until endDir.Y <=.6 and  endDir.Y >= -.6
        local endPoint = current+endDir*maxLength

        if DEBUG then
            local p = Instance.new("Part")
            p.Size = Vector3.new(5,5,5)
            p.Position =endPoint*3
            p.Anchored = true
            p.Parent = DEBUGM
            p.BrickColor = c
            p.Material = Enum.Material.Neon
        end
        for x = 0,maxLength do
            if x%sampleInterval == 0 then
                direaction = getDir(current.X, current.Y-yOffset, current.Z, n1, n2, n3, amplitude)
                local dirToConver = (endPoint-current).Unit
                direaction = (direaction*(1-weight)+dirToConver*weight).Unit
            end
            current+= direaction
        
           if DEBUG then
            local p = Instance.new("Part")
            p.Size = Vector3.new(1,1,1)*3
            p.Position = (current+Vector3.one*.5)//1 *3
            p.Anchored = true
            p.Parent = DEBUGM
            p.BrickColor = c
           end
        end
    end
end
return worms