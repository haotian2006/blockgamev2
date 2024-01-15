local manager = {}
local Remote:RemoteEvent = game.ReplicatedStorage.Events.Chunk
local Data = require(game.ReplicatedStorage.Data)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator = require(ChunkGeneration.Generator)
local Layers = require(ChunkGeneration.GenerationLayer)
local OverWorld = require(script.OverworldStack)
local Builder = require(script.ChunkBuilder)
local ChunkClass = require(game.ReplicatedStorage.Chunk)
local debirs = require(game.ReplicatedStorage.Libarys.Debris)
local ChunkTemp = debirs.createFolder("Chunk", 30)
local Runner = require(game.ReplicatedStorage.Runner)


local r =  5
local precomputed = {}
local xx = 0
for dist = 0, r do
    for x = -dist, dist do
        local zBound = math.floor(math.sqrt(r * r - x * x)) -- Bound for 'z' within the circle
        for z = -zBound, zBound do
            if table.find(precomputed,Vector3.new(x,0,z)) then continue end 
            table.insert(precomputed,Vector3.new(x,0,z))
            xx+=1
        end
    end
end
local precomputedLEN = #precomputed
local Queue = {}
local inQueue = {}
local waitingPlayers = {}

local CaveQueue = {}
local mainQueue = {}
local forCaveUse = {}

local maxSubLoops = 3
local maxCaveLoops = 2
local maxTimes = 1

local awaitingChunks = {}

local function sendDataToClients(chunk,...)
    if not waitingPlayers[chunk] then return end 
    for i,v in waitingPlayers[chunk] do
        Remote:FireClient(v,chunk,...)
    end
    waitingPlayers[chunk] = nil
end
function manager.buildChunk(chunk)
    local blockData,Biomes,surface = Builder.buildChunk(chunk)
    forCaveUse[chunk] =  {blockData,Biomes,surface}
    inQueue[chunk] = nil
    for i,offset in precomputed do
        local c = offset + chunk
        local data = awaitingChunks[c] 
        if not data then continue end 
        if table.find(data,chunk) then continue end 
        table.insert(data,chunk)
    end
    if table.find(CaveQueue, chunk) then return end 
    table.insert(CaveQueue,chunk)
    return 
end
function manager.buildCaves(chunk,data)
    local tempD = data
    if not data then return warn(`Chunk {tostring(chunk)} has no Data`) end 
    tempD[1] = Builder.buildCaves(chunk,tempD[1])
    debirs.add(ChunkTemp, chunk, tempD)
    
    forCaveUse[chunk] = nil
    return 
end
local function finishGeneration(chunk,allData)
    local foundData = allData[chunk]
    local newBlocks = Builder.buildFeatures(chunk,allData)
    local Chunk = ChunkClass.new(chunk.X,chunk.Z,newBlocks,foundData[2])
    Data.insertChunk(chunk.X, chunk.Z, Chunk)
    sendDataToClients(chunk,Builder.compress(newBlocks),foundData[2])
end
function manager.generate(chunk)
    local all = {}
    local hasGenerated = false
    debug.profilebegin("loop Precomputed")
    if not awaitingChunks[chunk] or precomputedLEN <= #(awaitingChunks[chunk] or {}) then
        awaitingChunks[chunk] = {}
        local flag = true
        for i,offset in precomputed do
            local newChunk = offset + chunk
            local foundData = debirs.get(ChunkTemp, newChunk)
            if foundData then
                all[newChunk] = foundData
                if not table.find(awaitingChunks[chunk], newChunk) then
                    table.insert(awaitingChunks[chunk],newChunk)
                end
                continue
            end
            flag = false
            if not inQueue[newChunk] and  not forCaveUse[chunk] then
                table.insert(Queue,newChunk)
                inQueue[newChunk] = true
            end
        end
        hasGenerated = flag
    end
    debug.profileend()
    if not hasGenerated  then return end 
   

    awaitingChunks[chunk] = nil
    task.spawn(finishGeneration,chunk,all)
    return true
end
function manager.getChunkData()
    
end
local function handleCaveQueue()
    local times = 0
    local removed = {}
    for v,i in CaveQueue do
        if times == maxCaveLoops then break end
        times +=1
        manager.buildCaves(i,forCaveUse[i])
        removed[i] = true
    end
    for i,v in removed do
        table.remove(CaveQueue,table.find(CaveQueue, i))
    end
    if times == 0 then return true end 
    return 
end
local function QueueSubChunk()
    if # Queue == 0 then
        return true
    end
    for i = 1,maxSubLoops do
        if Queue[i] then
            task.spawn(manager.buildChunk,Queue[i])
        end
    end
    for i = 1,maxSubLoops do
        if not Queue[i] then break end 
        table.remove(Queue,1)
    end
    return
end
local function mainChunkQueue()
    local times = 0
    local removed = {}
    for v,i in mainQueue do
        if times == maxTimes then break end 
        if manager.generate(i) then
            removed[i] = true
            times +=1
        end
    end
    for i,v in removed do
        table.remove(mainQueue,table.find(mainQueue, i))
    end
    if times == 0 then return true end 
    return 
end

local order = {
    QueueSubChunk,
    QueueSubChunk,
    handleCaveQueue,
    handleCaveQueue,
    handleCaveQueue,
    mainChunkQueue
   --sleep,
}
local i = 0
local function x(current)
    current = current or 0
    current+=1
    if current >= #order then
        return
    end
    i+=1
    if not order[i] then
        i = 0
        return x(current)
    end
    if order[i](i) then
        return x(current)
    end
    return 
end
game:GetService("RunService").Stepped:Connect(function()
    x()
end)

--mainQueue[Vector3.new(0,0,0)] = true
Remote.OnServerEvent:Connect(function(player,requestedChunk)
    do
        return
    end
    local found = Data.getChunk(requestedChunk.X,requestedChunk.Z)
    if found then
        Remote:FireClient(player,requestedChunk,Builder.compress(found.Blocks),found.BiomeMap)
        return
    end
    if not waitingPlayers[requestedChunk] then
        waitingPlayers[requestedChunk]  = {}
       table.insert(mainQueue,requestedChunk)
    end
    table.insert( waitingPlayers[requestedChunk],player)
    return 
end)

return manager  