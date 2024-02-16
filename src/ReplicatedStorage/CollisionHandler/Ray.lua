local Ray = {}
local collisionHandler = require(script.Parent)

local getBlock = collisionHandler.getBlock
local abs = math.abs
local inf = math.huge

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


local function traceRay(start,direction:Vector3,DEBUG)
    debug.profilebegin("CastRay")
    if DEBUG then
        DebugFolder:ClearAllChildren()
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

    local txDelta = abs(1/dx)--math.sqrt(1+(dz/dx)^2) --abs(1/dx)
    local tyDelta = abs(1/dy)
    local tzDelta = abs(1/dz)--math.sqrt(1+(dx/dz)^2) --abs(1/dz)


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

        if DEBUG and grid then 
            local a = p:Clone()
            a.Position = grid*3
            a.Parent = DebugFolder
            
            local hitPos = Vector3.new(px+t*dx , py+t*dy , pz+t*dz)
            local a = p:Clone()
            a.Size = Vector3.one*.5
            a.Position = hitPos*3
            a.Parent = DebugFolder
        end

        if block ~= 0 and block  then
            local hitPos = Vector3.new(px+t*dx , py+t*dy , pz+t*dz)
            local normal = Vector3.new(steppedIndex == 0 and -stepx,steppedIndex == 1 and -stepy,steppedIndex == 2 and -stepz)
            if DEBUG then
                drawLine(start*3,hitPos*3)
            end
            debug.profileend()
            return block,grid,hitPos,normal
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
    return nil,grid,hitPos,Vector3.zero
end

function Ray.cast(start:Vector3,direction:Vector3)
    if (direction.Magnitude == 0) then error("Attemped to cast a ray with the length of 0") end 
    return traceRay(start, direction,false)
end

return Ray