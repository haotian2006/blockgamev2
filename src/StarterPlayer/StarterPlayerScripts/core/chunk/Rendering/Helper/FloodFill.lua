local Stack = require(game.ReplicatedStorage.Libarys.DataStructures.Stack)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local to1D= IndexUtils.to1D
local directions1D = {
   -1,
    1,
    -10,
    10,
    -100,
    100,
}

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

local bounds = {}
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
    for a = 1,10 do 
        subChunkTo1d[a] = subChunkTo1d[a] or {}
        for b = 1,10 do
            subChunkTo1d[a][b] =   subChunkTo1d[a][b] or  {}
            for c = 1,10 do
                local pass,vector = helperL(a-1,b-1,c-1)
                local abc = to1DTEMP(a-1, b-1, c-1)
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

local precomputedLoopTable = {}
for x =1,8 do
    for z = 1,8 do
        for y = 1,8 do
            local isEdge = false
            if x == 1 or x == 8 or y == 1 or y == 8 or z == 1 or z == 8 then
                isEdge = true
            end
            precomputedLoopTable[{x,y,z}] = isEdge
        end
    end
end

task.wait()
local precomputedLoopTable2 = {}
for x =2,9 do
    for z = 2,9 do
        for y = 2,9 do
            local vector = subChunkTo1d[x][y][z]
            table.insert(precomputedLoopTable2,vector)
        end
    end
end


local function sampleSection(blocks,section)
    local offset = section*8
    local isAir = true
    local allWalls = true
    local mappings = table.create(512)
    debug.profilebegin("sample Section")
    debug.profilebegin("Pre Flood Check")
    
    for loc,isWall in next,precomputedLoopTable do
        local x,y,z = loc[1],loc[2],loc[3]
        local vector = to1D[x][y+offset][z]
        local block = buffer.readu8(blocks, (vector-1))
        if isWall and block ~= 0 then
            allWalls = false
        elseif block == 0 then
            isAir = false
        end 
        mappings[subChunkTo1d[x+1][y+1][z+1]] = block
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
        local hadConflict = false
        conflictsL = {}
        while #floodStack>0 do
            local current = Stack.pop(floodStack)
            if checked[current] then continue end
            checked[current] = true
            local pass = isIn(current)
            if not pass then 
                hadConflict = true 
                continue 
            end 
            local block = mappings[current]
            if block == 0 then 
                continue 
            end 
            for i,v in directions1D do
                local newDir = current+v
                Stack.push(floodStack, newDir)
            end
        end
        if hadConflict then
            table.insert(co nflicts,conflictsL)
        end
    end

   for _,vector in precomputedLoopTable2 do
        if checked[vector] then continue end 
        local block = mappings[vector]
        if block == 0 then 
            continue 
        end 
        floodFill(vector)         
    end


    debug.profileend()
    local enter = {}
    debug.profilebegin("FloodFill Create Combinations")
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


return sampleSection