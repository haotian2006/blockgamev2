local helper = {}
local Chunk = require(game.ReplicatedStorage.Chunk)
local chunks = {}
local Stack = require(game.ReplicatedStorage.Libarys.DataTypes.Stack)
local Queue = require(game.ReplicatedStorage.Libarys.DataTypes.Queue)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local to1DVector = IndexUtils.to1DVector
local to1D= IndexUtils.to1D
local to3D= IndexUtils.to3D
local camera= game.Workspace.CurrentCamera
local data = require(game.ReplicatedStorage.Data)
helper.ChunkData = {}
local directions = {
    Vector3.xAxis,
    -Vector3.xAxis,
    Vector3.yAxis,
    -Vector3.yAxis,
    Vector3.zAxis,
    -Vector3.zAxis,
}
local directions1D = {
   -1,
    1,
    -10,
    10,
    -100,
    100,
}
local Faces = directions
local facesIndex = {}
local oppsiteFaces = {

}
do
    for i,v in Faces do
        facesIndex[v] = i
    end
    for i=1,#Faces,2 do
        oppsiteFaces[i] = i+1
        oppsiteFaces[i+1] = i
    end
end
local function getChunkLocation(v)
    return (v+Vector3.one*.5)//8
end
local keysValues = {
    [Vector3.new(0, 0, -2)] = 0,
    [Vector3.new(0, 0, 2)] = 0,
    [Vector3.new(0, -2, 0)] = 1,
    [Vector3.new(0, 2, 0)] = 1,
    [Vector3.new(-2, 0, 0)] = 2,
    [Vector3.new(2, 0, 0)] = 3,
    
    [Vector3.new(0, -1, -1)] = 4,
    [Vector3.new(-1, 0, -1)] = 5,
    [Vector3.new(-1, -1, 0)] = 6,
    [Vector3.new(-1, 0, 1)] = 7,
    [Vector3.new(-1, 1, 0)] = 8,
    [Vector3.new(0, -1, 1)] = 9,
    [Vector3.new(0, 1, -1)] = 10,
    [Vector3.new(0, 1, 1)] = 11,
    [Vector3.new(1, -1, 0)] = 12,
    [Vector3.new(1, 0, -1)] = 13,
    [Vector3.new(1, 0, 1)] = 14,
    [Vector3.new(1, 1, 0)] = 15,
}
local b = buffer.create(32)
function helper.getSubChunk(loc)
    local chunk = data.getChunk(loc.X,loc.Z)
    if not chunk or not chunk.Status.SubChunks  then return end
    return chunk.Status.SubChunks[loc.Y]
end
local function canSee(subB,from,to)
    local key = Faces[from]+Faces[to]
    if key == Vector3.zero then
        key = Faces[from]-Faces[to]
    end
    local idx = keysValues[key]
    return buffer.readu8(subB, idx) == 1
end
local getSubChunk =  helper.getSubChunk

local bounds = {
}
local subChunkTo1d = {}
do
    local function to1DTEMP(x,y,z)
        return  x+y*10+z *100+1
    end
    local function helperL(x,y,z)
        local pass = true
        local vectors = {}
        if x == 0 then
            pass = false
            table.insert(vectors,-Vector3.xAxis)
        elseif x == 9 then
            pass = false
            table.insert(vectors,Vector3.xAxis)
        end
        if y == 0 then
            pass = false
            table.insert(vectors,-Vector3.yAxis)
        elseif y == 9 then
            pass = false
            table.insert(vectors,Vector3.yAxis)
        end
        if z == 0 then
            pass = false
            table.insert(vectors,-Vector3.zAxis)
        elseif z == 9 then
            pass = false
            table.insert(vectors,Vector3.zAxis)
        end
        if #vectors == 1 then
            return false,vectors[1]
        end
        return pass,vectors
    end
    for a = 0,9 do 
        subChunkTo1d[a] = subChunkTo1d[a] or {}
        for b = 0,9 do
            subChunkTo1d[a][b] =   subChunkTo1d[a][b] or  {}
            for c = 0,9 do
                local pass,vector = helperL(a,b,c)
                local abc = to1DTEMP(a, b, c)
                if not pass then
                    bounds[abc] = vector
                end
                subChunkTo1d[a][b][c] = abc
            end
        end
    end
end
local airBuffer = buffer.create(16)
buffer.fill(airBuffer, 0, 1,15)
local wallBuffer  = buffer.create(16)

function findDifferentKeys(dict1, dict2)
    local differentKeys = {}

    for key, value in(dict1) do
        if dict2[key] ~= value then
            differentKeys[key] = true
        end
    end

    for key, value in (dict2) do
        if dict1[key] ~= value then
            differentKeys[key] = true
        end
    end

    return differentKeys
end
local function to3DTEMP(index)
    local sizeX = 10
    local sizeY = 10
    local sizeZ = 10

    local z = math.floor((index - 1) / (sizeX * sizeY)) % sizeZ
    local y = math.floor((index - 1) / sizeX) % sizeY
    local x = (index - 1) % sizeX

    return x, y, z
end

function helper.sampleSection(blocks,section,chunk)
    local offset = section*8
    local isAir = true
    local allWalls = true
    local mappings = table.create(512)
    debug.profilebegin("sample Everything")
    debug.profilebegin("PreCompute Flood")
    for x =0,7 do
        for z = 0,7 do
            for y = 0,7 do
               local vector = to1D[x][y+offset][z]
               local block = buffer.readu32(blocks, (vector-1)*4)
               if x == 0 or x == 7 or y == 0 or y == 7 or z == 0 or z == 7 then
                    if block ~= 1 then
                        allWalls = false
                    end
               end
               if block ~= 0 then 
                   isAir = false 
               end      
               mappings[subChunkTo1d[x+1][y+1][z+1]] = block
            end
        end
    end
    debug.profileend()
    if isAir then
        return airBuffer
    end
    if allWalls then
        return wallBuffer
    end
    debug.profilebegin("S flood fill")
    local conflictsL = {}
    local function isIn(pos)
        local value = bounds[pos] 
        if not value then 
            return true 
        elseif typeof(value) == "Vector3" then
            conflictsL[value] = true
        else
            for i,b in value do
                conflictsL[b] = true
            end
        end 
        return false
    end
    local conflicts = {}
    local checked = {}
    local size = 8*8*8
    local function floodFill(vector)
        local floodStack = Stack.new(size)
        Stack.push(floodStack, vector)
        local hadCon = false
        conflictsL = {}
        while #floodStack>0 do
            local current = Stack.pop(floodStack)
            if checked[current] then continue end
            checked[current] = true
            local pass = isIn(current)
            if not pass then 
                hadCon = true 
                continue 
            end 
            local block = mappings[current]
            if block ~= 0 then 
                continue 
            end 
            for i,v in directions1D do
                local newDir = current+v
                Stack.push(floodStack, newDir)
            end
        end
        if hadCon then
            table.insert(conflicts,conflictsL)
        end
    end
    for x =1,8 do
        for z = 1,8 do
            for y = 1,8 do
               local vector = subChunkTo1d[x][y][z]
               if checked[vector] then continue end 
               local block = mappings[vector]
               if block ~= 0 then 
                   continue 
               end 
               floodFill(vector)         
            end
        end
    end
    debug.profileend()
    local enter = {}
    debug.profilebegin("S floodFIll combine")
    for i,subConflicts in conflicts do
        for sides,_ in subConflicts do
            for sides1,_ in subConflicts do
                if sides == sides1 then continue end 
                if sides+sides1 == Vector3.zero then
                    enter[sides - sides1] = true
                    continue
                end
                enter[sides + sides1] = true
            end
        end
    end
    debug.profileend()
    local b = buffer.create(16)
    for i,v in enter do
        buffer.writeu8(b, keysValues[i], 1)
    end
    debug.profileend()
    return b,enter
end


local fov = 0.75
local function pointInFrustum(point, origin, direction)
    local vectorToPoint =( point - origin).Unit
    return not (vectorToPoint:Dot(direction) <= fov) 
end

local frustumOffset = {
    Vector3.new(),
    Vector3.new(8),
    Vector3.new(0,8),
    Vector3.new(0,0,8),
    Vector3.new(0,8,8),
    Vector3.new(8,8,0),
    Vector3.new(8,0,8),
    Vector3.new(8,8,8),
}
local function inFrustum(vector, from, direction)
    vector*=8
    from = from*8 +Vector3.one*4
    for i = 1,8 do
        if pointInFrustum(frustumOffset[i] +vector, from, direction) then
            return true
        end
    end
    return false
end
local maxRenderDistance = 16
local lastDir,lastChunk =  camera.CFrame.LookVector,getChunkLocation(camera.CFrame.Position/3-Vector3.yAxis)
function helper.startSearch(start,direaction)
    local maxVisited = maxRenderDistance*230
    local searchQueue = Queue.new(maxVisited+100)

    local visited = {}
   
    Queue.enqueue(searchQueue, {fromVector = start,fromDir = -1,dirs = table.create(6,0)})
    visited[start] = 1
    local minX,maxX= start.X-maxRenderDistance,start.X+maxRenderDistance
    local minZ,maxZ = start.Z-maxRenderDistance,start.Z+maxRenderDistance
    local minY,maxY = 0,31
    local visitedTotal = 0
    while searchQueue[1] <= searchQueue[2]  and visitedTotal <=maxVisited do
        local top = Queue.dequeue(searchQueue)
        local current = getSubChunk(top.fromVector)
        if not current then continue end 
        local function vist(vector,throughFace)
            local x,y,z = vector.X,vector.Y,vector.Z
            if top.dirs[oppsiteFaces[throughFace]] == 1 then
                return
            end
            if (x<minX or x > maxX) or  
                (z<minZ or z > maxZ) or  
                (y<minY or y > maxY) then
                return
            end

            if visited[vector] then
                return 
            end
            if top.fromDir ~= -1 then
                if not canSee(current, top.fromDir, throughFace) then
                    return
                end
            end
            if not inFrustum(vector, start, direaction) then
                return 
            end
            visited[vector] = 1
            visitedTotal +=1
            local clone = table.clone(top.dirs)
            clone[throughFace] = 1
            Queue.enqueue(searchQueue, {fromVector = vector,fromDir = oppsiteFaces[throughFace],dirs =clone})
            return true 
        end
        for i,v in Faces do
            vist(top.fromVector+v,i) 
        end
    end
    return visited
end
function helper.update(force)
    local direaction = camera.CFrame.LookVector
    local chunk = getChunkLocation(camera.CFrame.Position/3-Vector3.yAxis)
    if direaction ~= lastDir or lastChunk ~= chunk  or force then
        lastDir = direaction
        lastChunk = chunk
        fov = math.cos(camera.FieldOfView+math.rad(15))
        local start = os.clock()
        debug.profilebegin("Frustum Cull")
        local visited = helper.startSearch(lastChunk,lastDir)
        debug.profileend()
        local updated = {}
        for i,v in visited do
            local changed = i*Vector3.new(1,0,1)
            updated[changed] = updated[changed] or buffer.create(32)
            local y = i.y
            if y >31 or y < 0 then continue end 
            buffer.writeu8(updated[changed], y, 1)
        end
        return updated
    end
    return false
end
function helper.createSubChunks(chunk)
    local Status = chunk.Status
    Status.SubChunks = {}
    for i=0,31 do
        Status.SubChunks[i] = helper.sampleSection(chunk.Blocks, i)
    end
end
return helper 