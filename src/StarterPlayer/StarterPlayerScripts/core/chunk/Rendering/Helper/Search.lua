local helper = {}
local Queue = require(game.ReplicatedStorage.Libs.DataStructures.Queue)

local AntiLag = require(script.Parent.Parent.Config).ANTI_LAG

local camera= game.Workspace.CurrentCamera
local data = require(game.ReplicatedStorage.Data)

local Start_Time = os.clock()
local Paused 


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

local Faces = {
    Vector3.xAxis,
    -Vector3.xAxis,
    Vector3.yAxis,
    -Vector3.yAxis,
    Vector3.zAxis,
    -Vector3.zAxis,
}

local facesIndex = {}
local oppsiteFaces = {}
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

local function getSubChunk(loc)
    local chunk = data.getChunk(loc.X,loc.Z)
    if not chunk or not chunk.SubChunks  then return end
    local sub = chunk.SubChunks 
    if not sub.DONE then return  end
    return sub[loc.Y+1]
end

local function canSee(subB,from,to)
    local key = Faces[from]+Faces[to]
    if key == Vector3.zero then
        key = Faces[from]-Faces[to]
    end
    local idx = keysValues[key]
    return buffer.readu8(subB, idx) == 1
end

local fov = 0.75
local function pointInFrustum(point, origin, direction)
    local vectorToPoint =( point - origin).Unit
    return not (vectorToPoint:Dot(direction) <= fov) 
end


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
function helper.startSearch(start,direction)
    local maxVisited = maxRenderDistance*230
    local searchQueue = Queue.new(maxVisited+100)

    local visited = {}
    Queue.enqueue(searchQueue, {fromVector = start,fromDir = -1,dirs = table.create(6,0)})
    visited[start] = 1
    local minX,maxX= start.X-maxRenderDistance,start.X+maxRenderDistance
    local minZ,maxZ = start.Z-maxRenderDistance,start.Z+maxRenderDistance
    local minY,maxY = 0,32
    local visitedTotal = 0
    while searchQueue.S <= searchQueue.E  and visitedTotal <=maxVisited do
        if os.clock()-Start_Time >=.015  then
            if not AntiLag then break end 
            Paused = coroutine.running()
            coroutine.yield()
        end
        local top = Queue.dequeue(searchQueue)
        if not top then break end 
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
            if not inFrustum(vector, start, direction) then
                return 
            end
            visited[vector] = 1
            visitedTotal +=1
            local clone = table.clone(top.dirs)
            clone[throughFace] = 1
            Queue.enqueue(searchQueue, {fromVector = vector,fromDir = oppsiteFaces[throughFace],dirs =clone})
            return true 
        end

        for face,dirVector in Faces do
            vist(top.fromVector+dirVector,face) 
        end
    end
    return visited
end

function helper.update(force,StartTime,Update)
    Start_Time = StartTime
    if Paused then
        helper.resume(StartTime)
        return 
    end
    Update.Value +=1
    local direction = camera.CFrame.LookVector
    local chunk = getChunkLocation(camera.CFrame.Position/3-Vector3.yAxis)
    if direction ~= lastDir or lastChunk ~= chunk  or force then
        
        lastDir = direction
        lastChunk = chunk
        fov = math.cos(camera.FieldOfView+math.rad(15))
        debug.profilebegin("StartSearch")
        local visited = helper.startSearch(lastChunk,lastDir)
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

function helper.resume(StartTime)
    Start_Time = StartTime
    local toRun = Paused
    Paused = nil
    debug.profilebegin("ResumeSearch")
    coroutine.resume(toRun)
end

return helper 