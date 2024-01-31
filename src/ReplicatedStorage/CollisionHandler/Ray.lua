local Ray = {}
local collisionHandler = require(script.Parent)
local getBlock = collisionHandler.getBlock
local abs = math.abs
local inf = math.huge

local D = workspace.RayD
local p = Instance.new("Part")
p.Size = Vector3.new(3,3,3)
p.Transparency = .2
p.Anchored = true

local function round(x)
    return math.floor(x)
end

function drawLine(startVector, endVector,color)
    -- Create a part to represent the line
    local linePart = Instance.new("Part")
    linePart.Size = Vector3.new(0.2, 0.2, (startVector - endVector).Magnitude)
    linePart.Anchored = true
    linePart.CanCollide = false
    linePart.Position = (startVector + endVector) / 2
    
    -- Calculate the rotation to align the part with the line
    local rotation =  CFrame.lookAt(startVector+(endVector-startVector)/2,endVector)
    linePart.CFrame = rotation
    
    -- Set the color or material of the line as desired
    linePart.BrickColor = color or BrickColor.new("Bright red")  -- Change color if needed
    
    -- Parent the line part to the workspace or another desired parent
    linePart.Parent = D
end

local function frac(x)
    return x - math.floor(x)
end

local function traceRayV2(start,direction)
    D:ClearAllChildren()
    local x1, y1, z1 = start.X,start.Y,start.Z
    -- end point
    --[[

      self.forward.x = glm.cos(self.yaw) * glm.cos(self.pitch)
        self.forward.y = glm.sin(self.pitch)
        self.forward.z = glm.sin(self.yaw) * glm.cos(self.pitch)

          yaw = glm.atan2(forward_vector.z, forward_vector.x)

         pitch = glm.asin(forward_vector.y)

    ]]
    local forward = direction
    local x2, y2, z2 = x1 + forward.X, y1 + forward.Y, z1 + forward.Z

    local currentVoxelPos = (start+Vector3.one*.5)//1
    local voxel_normal = Vector3.new(0, 0, 0)
    local stepDir = -1

    local dx = math.sign(x2 - x1)
    local delta_x = (dx ~= 0) and math.min(dx / (x2 - x1), 10000000.0) or 10000000.0
    local max_x = (dx > 0) and delta_x * (1.0 - frac(x1)) or delta_x * frac(x1)

    local dy = math.sign(y2 - y1)
    local delta_y = (dy ~= 0) and math.min(dy / (y2 - y1), 10000000.0) or 10000000.0
    local max_y = (dy > 0) and delta_y * (1.0 - frac(y1)) or delta_y * frac(y1)

    local dz = math.sign(z2 - z1)
    local delta_z = (dz ~= 0) and math.min(dz / (z2 - z1), 10000000.0) or 10000000.0
    local max_z = (dz > 0) and delta_z * (1.0 - frac(z1)) or delta_z * frac(z1)

    while not (max_x > 1.0 and max_y > 1.0 and max_z > 1.0) do
        local result --= getVoxelId(currentVoxelPos)

        local block,l,grid = getBlock(currentVoxelPos.X,currentVoxelPos.Y,currentVoxelPos.Z)
        local a = p:Clone()
        a.Position = currentVoxelPos*3
        a.Parent = D
        if block ~= 0 and block  then
            drawLine(start*3,start*3 + direction)
            return block,grid
        end

        if result then

            if stepDir == 0 then
                voxel_normal = Vector3.new(-dx, 0, 0)
            elseif stepDir == 1 then
                voxel_normal = Vector3.new(0, -dy, 0)
            else
                voxel_normal = Vector3.new(0, 0, -dz)
            end
            return true
        end

        if max_x < max_y then
            if max_x < max_z then
                currentVoxelPos = currentVoxelPos + Vector3.new(dx, 0, 0)
                max_x = max_x + delta_x
                stepDir = 0
            else
                currentVoxelPos = currentVoxelPos + Vector3.new(0, 0, dz)
                max_z = max_z + delta_z
                stepDir = 2
            end
        else
            if max_y < max_z then
                currentVoxelPos += Vector3.new(0, dy, 0)
                max_y = max_y + delta_y
                stepDir = 1
            else
                currentVoxelPos += Vector3.new(0, 0, dz)
                max_z += delta_z
                stepDir = 2
            end
        end
        currentVoxelPos = (currentVoxelPos+Vector3.one*.5)//1
    end
    drawLine(start*3,start*3 + direction)
    return false
end

local function traceRayV3(start,direction:Vector3)
    D:ClearAllChildren()
    local t = 0
    
    local unitVector = direction.Unit 
    print( math.deg(math.atan(unitVector.X/unitVector.Z)))
    start //=1
    local dx,dy,dz = unitVector.X,unitVector.Y,unitVector.Z
    local px,py,pz = start.X,start.Y,start.Z
    local maxD = direction.Magnitude

    local ix = round(px)
    local iy = round(py)
    local iz = round(pz)

  local stepx,stepz

    local txDelta = abs(1/dx)--math.sqrt(1 + (dz * dz) / (dx * dx))--abs(1/dx)
    local tyDelta = abs(1/dy)
    local tzDelta = abs(1/dz)--math.sqrt(1 + (dx * dx) / (dz * dz))--abs(1/dz)

    local sideDistX 
    local sideDistZ
    if dx<0 then
        stepx = -1
        sideDistX = (px-ix)*txDelta
    else
        stepx = 1
        sideDistX = (ix+1-px)*txDelta
    end

    if dz<0 then
        stepz = -1
        sideDistZ = (pz-iz)*tzDelta
    else
        stepz = 1
        sideDistZ = (iz+1-pz)*tzDelta
    end



    local fDistance = 0
    while fDistance< maxD do
        if (sideDistX<sideDistZ) then
            sideDistX+=txDelta
            fDistance = sideDistX
            ix += stepx
            
        else
            sideDistZ+=tzDelta
            fDistance = sideDistZ
            iz += stepz
        end

        local a = p:Clone()
        a.Position = Vector3.new(ix,iy,iz)*3
        a.Parent = D

       
    end
    drawLine(start*3,start*3+direction)
    return nil
end

local function traceRay(start,direction:Vector3)
    D:ClearAllChildren()
    local t = 0
    
    local unitVector = direction.Unit 

    local dx,dy,dz = unitVector.X,unitVector.Y,unitVector.Z
    local px,py,pz = start.X,start.Y,start.Z
    local maxD = direction.Magnitude

    local ix = round(px)
    local iy = round(py)
    local iz = round(pz)

    local stepx = if dx> 0 then 1 else -1
    local stepy = if dy> 0 then 1 else -1
    local stepz = if dz> 0 then 1 else -1

    local txDelta = abs(1/dx)
    local tyDelta = abs(1/dy)
    local tzDelta = abs(1/dz)


    local xdist = if stepx >0 then (ix +1 - px) else (px +1- ix)
    local ydist = if stepy >0 then (iy +1 - py) else (py +1- iy)
    local zdist = if stepz >0 then (iz +1 - pz) else (pz +1- iz)

    local txMax = if txDelta<inf then txDelta*xdist else inf
    local tyMax = if tyDelta<inf then tyDelta*ydist else inf
    local tzMax = if tzDelta<inf then tzDelta*zdist else inf

    local steppedIndex = -1


    while t<= maxD do
        ix,iy,iz = round(ix),round(iy),round(iz)
        local block,l,grid = getBlock(ix,iy,iz)
        local a = p:Clone()
        a.Position = Vector3.new(ix,iy,iz)*3
        a.Parent = D
        if block ~= 0 and block  then
            local hitPos = Vector3.new(px+t*dx , py+t*dy , pz+t*dz)
            local normal = Vector3.new(steppedIndex == 0 and -stepx,steppedIndex == 1 and -stepy,steppedIndex == 2 and -stepz)
            drawLine(start*3,hitPos*3)
            return block,grid,hitPos,normal
        end
        if (txMax<tyMax) then
            if (txMax<tzMax) then
                ix += stepx
                t = txMax
                txMax += txDelta
                steppedIndex =0
                a.Name = "4"
            else
                iz += stepz
				t = tzMax
				tzMax += tzDelta
				steppedIndex = 2
                a.Name = "3"
            end
        else
            if (tyMax < tzMax) then
				iy += stepy
				t = tyMax
				tyMax += tyDelta
				steppedIndex = 1
                a.Name = "1"
			else 
				iz += stepz
				t = tzMax
				tzMax += tzDelta
				steppedIndex = 2
                a.Name = 2
            end
        end
    end
    local hitPos = Vector3.new(px+t*dx , py+t*dy , pz+t*dz)
    drawLine(start*3,hitPos*3)
    return nil
end

function Ray.cast(start:Vector3,direction:Vector3)
    if (direction.Magnitude == 0) then error("Attemped to cast a ray with the length of 0") end 
    return traceRay(start, direction)
end

return Ray