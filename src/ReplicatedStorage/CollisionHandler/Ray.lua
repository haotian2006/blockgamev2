local Ray = {}
local collisionHandler = require(script.Parent)

local Core = require(game.ReplicatedStorage.Core)
local Shared:Core.Shared
local EntityService:Core.EntityService
task.spawn(function()
    Shared = Core.await("Shared")::Core.Shared
    EntityService = Shared.awaitModule("EntityService")::Core.EntityService
end)

local getBlock = collisionHandler.getBlock
local abs = math.abs
local inf = math.huge
local ENTITY_INTERVAL = .1

local DebugFolder = workspace.RayD
local p = Instance.new("Part")
p.Size = Vector3.new(3,3,3)
p.Transparency = .3
p.Anchored = true

local function round(x)
    return math.floor(x)-.5
end


local function drawLine(startVector, endVector,color,name)

    local linePart = Instance.new("Part")
    linePart.Size = Vector3.new(0.2, 0.2, (startVector - endVector).Magnitude)
    linePart.Anchored = true
    linePart.CanCollide = false
    linePart.Name = name or ""
    linePart.Material = Enum.Material.Neon
    linePart.Position = (startVector + endVector) / 2
    
    local rotation =  CFrame.lookAt(startVector+(endVector-startVector)/2,endVector)
    linePart.CFrame = rotation
    
    linePart.BrickColor = color or BrickColor.new("Bright red") 
    
    linePart.Parent = DebugFolder
end

local function createBroadPhase(start,direaction)
    local middle = (start + direaction/2)
    return middle,Vector3.new(abs(direaction.X),abs(direaction.Y),abs(direaction.Z))+Vector3.zero*2
end

local function precomputeEntityCorners(Entities)
    local Corners = {}
    for _, entity:Core.Entity in Entities do
        local HitBox = EntityService.getHitbox(entity)
        local Size = HitBox/2
        local entityMinCorner = entity.Position - Size
        local entityMaxCorner = entity.Position + Size
        local corner = {}
        corner.MinX = entityMinCorner.X
        corner.MinY = entityMinCorner.Y
        corner.MinZ = entityMinCorner.Z
        corner.MaxX = entityMaxCorner.X
        corner.MaxY = entityMaxCorner.Y
        corner.MaxZ = entityMaxCorner.Z
        Corners[entity] = corner
    end
    return Corners
end

local function getEntitiesInVoxel(voxel,EntitiesCorners)
     
    local entitiesInVoxel = {}
    local has = false
    local halfSize = Vector3.one / 2

    local minCorner = voxel - halfSize
    local maxCorner = voxel + halfSize

    local minX, minY, minZ = minCorner.X, minCorner.Y, minCorner.Z
    local maxX, maxY, maxZ = maxCorner.X, maxCorner.Y, maxCorner.Z

    local index = 1
    
    for entity:Core.Entity,corner in EntitiesCorners do

        if corner.MaxX > minX and
            corner.MinX < maxX and
            corner.MaxY > minY and
            corner.MinY < maxY and
            corner.MaxZ > minZ and
            corner.MinZ < maxZ then
                has = true
                entitiesInVoxel[entity] = corner
            index+=1
        end
    end

    return entitiesInVoxel,has
end

local function createRayResult(Block,Entity,hit,grid,normal)
    return {
        normal = normal,
        grid = grid,
        hit = hit,
        entity = Entity,
        block = Block,
    }
end

local function FindFirstEntityInRay(start:Vector3,direaction:Vector3,Entities)
    local TotalDistance = direaction.Magnitude
    local Increment = direaction.Unit*ENTITY_INTERVAL
    local CurrentPos =  start
    local Distance = 0
    local Hit 
    while Distance < TotalDistance and not Hit do
        CurrentPos += Increment
        Distance += ENTITY_INTERVAL
        local x,y,z = CurrentPos.X,CurrentPos.Y,CurrentPos.Z
        for Entity,corner in Entities do
            if corner.MaxX > x and
                corner.MinX < x and
                corner.MaxY > y and
                corner.MinY < y and
                corner.MaxZ > z and
                corner.MinZ < z then
                    Hit = Entity
                    return Hit,CurrentPos
            end
        end
    end
    return 
end

local function traceRay(start,direction:Vector3,CheckForEntities,DEBUG)
    debug.profilebegin("CastRay")
    if DEBUG then
        DebugFolder:ClearAllChildren()
    end
    local EntitiesInRegion 
    if CheckForEntities then
        local middle,size = createBroadPhase(start,direction)
        CheckForEntities.CheckGlobal = true
        EntitiesInRegion = collisionHandler.getEntitiesInBox(middle,size,CheckForEntities)
        EntitiesInRegion = precomputeEntityCorners(EntitiesInRegion)
        EntitiesInRegion = next(EntitiesInRegion) and EntitiesInRegion or nil
    end
    local t = 0
    
    local unitVector = direction.Unit 
   -- start //= 1 
    local dx,dy,dz = unitVector.X,unitVector.Y,unitVector.Z
    local px,py,pz = start.X,start.Y,start.Z
    local maxD = direction.Magnitude

    local ix = round(px+.5)
    local iy = round(py+.5)
    local iz = round(pz+.5)


    local stepx = if dx> 0 then 1 else -1
    local stepy = if dy> 0 then 1 else -1
    local stepz = if dz> 0 then 1 else -1

    local txDelta = abs(1/dx)--math.sqrt(1+(dz/dx)^2) 
    local tyDelta = abs(1/dy)
    local tzDelta = abs(1/dz)--math.sqrt(1+(dx/dz)^2) 


    local xdist = if stepx >0 then (ix +1 - px) else (px - ix)
    local ydist = if stepy >0 then (iy +1 - py) else (py - iy)
    local zdist = if stepz >0 then (iz +1 - pz) else (pz - iz)

    local txMax = if txDelta<inf then txDelta*xdist else inf
    local tyMax = if tyDelta<inf then tyDelta*ydist else inf
    local tzMax = if tzDelta<inf then tzDelta*zdist else inf

    local steppedIndex = -1
    local block,lcoord,grid
    while t <= maxD do
        local current = Vector3.new(ix,iy,iz )
        block,lcoord,grid = getBlock(ix,iy,iz)
        local hitPos = Vector3.new(px+t*dx , py+t*dy , pz+t*dz)

        if DEBUG and grid then 
            local a = p:Clone()
            a.Position = grid*3
            a.Parent = DebugFolder
            
            local a = p:Clone()
            a.Size = Vector3.one*.5
            a.Position = hitPos*3
            a.Parent = DebugFolder
        end

        if block ~= 0 and block  then
            local normal = Vector3.new(steppedIndex == 0 and -stepx,steppedIndex == 1 and -stepy,steppedIndex == 2 and -stepz)

            if DEBUG then
                drawLine(start*3,hitPos*3)
            end

            debug.profileend()
            return createRayResult(block,nil,hitPos,grid,normal)
        end
        if (txMax<tyMax) then
            if (txMax<tzMax) then
                ix += stepx
                t = txMax
                txMax += txDelta
                steppedIndex =0

            else
                iz += stepz
				t = tzMax
				tzMax += tzDelta
				steppedIndex = 2
            end
        else
            if (tyMax < tzMax) then
				iy += stepy
				t = tyMax
				tyMax += tyDelta
				steppedIndex = 1
			else 
				iz += stepz
				t = tzMax
				tzMax += tzDelta
				steppedIndex = 2
            end
        end
        if EntitiesInRegion then
            local Entitys,hasEntity = getEntitiesInVoxel(grid,EntitiesInRegion)
            if hasEntity then
                local normal = Vector3.new(steppedIndex == 0 and -stepx,steppedIndex == 1 and -stepy,steppedIndex == 2 and -stepz)
                local endPos = Vector3.new(px+t*dx , py+t*dy , pz+t*dz)

                local found,hit = FindFirstEntityInRay(hitPos, endPos-hitPos, Entitys)
                if found then
                    return createRayResult(nil,found,hit,grid,normal)
                end
            end
        end
      if DEBUG then
            drawLine(current*3,current*3 + Vector3.new(txMax)*stepx/5,BrickColor.Green(),`cx: {txMax}`)
            drawLine(current*3,current*3 + Vector3.new(0,tyMax)*stepy/5,BrickColor.Blue())
            drawLine(current*3,current*3 + Vector3.new(0,0,tzMax)*stepz/5,BrickColor.Yellow(),`cz: {tzMax}`)
      end
    end
    local hitPos = Vector3.new(px+t*dx , py+t*dy , pz+t*dz)
    if DEBUG then
        drawLine(start*3,hitPos*3)
    end
    debug.profileend()
    return  createRayResult(nil,nil,hitPos,grid,Vector3.zero)
end

Ray.createEntityParams = collisionHandler.createEntityParams

function Ray.cast(start:Vector3,direction:Vector3,EntityParams)
    if (direction.Magnitude == 0) then error("Attemped to cast a ray with the length of 0") end 
    return traceRay(start, direction,EntityParams)
end

return Ray