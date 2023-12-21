local manager = {}
local Remote:RemoteEvent = game.ReplicatedStorage.Events.Chunk
local Data = require(game.ReplicatedStorage.Data)
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Generator = require(ChunkGeneration.Generator)
local Layers = require(ChunkGeneration.GenerationLayer)
local OverWorld = require(script.OverworldStack)
local Builder = require(script.ChunkBuilder)
local ChunkClass = require(game.ReplicatedStorage.Chunk)

local Runner = require(game.ReplicatedStorage.Runner)



local Queue = {}
local waitingPlayers = {}

local maxIterations = 6

local function sendDataToClients(chunk,...)
    if not waitingPlayers[chunk] then return end 
    for i,v in waitingPlayers[chunk] do
        Remote:FireClient(v,chunk,...)
    end
    waitingPlayers[chunk] = nil
end

function manager.generateChunk(chunk)
    local blockData,Biomes,buffer = Builder.buildChunk(chunk)
    local Chunk = ChunkClass.new(chunk.X,chunk.Z,blockData,Biomes)
    Data.insertChunk(chunk.X, chunk.Z, Chunk)
    sendDataToClients(chunk,buffer,Biomes)
end

function manager.getChunkData()
    
end

Runner.bindToHeartbeat("ChunkQueue", function(dt)
    for i = 1,maxIterations do
        if Queue[i] then
            task.spawn(manager.generateChunk,Queue[i])
        end
    end
    for i = 1,maxIterations do
        if not Queue[i] then break end 
        table.remove(Queue,1)
    end
end,5)

Remote.OnServerEvent:Connect(function(player,requestedChunk)
    if not waitingPlayers[requestedChunk] then
        waitingPlayers[requestedChunk]  = {}
        table.insert(Queue,requestedChunk)
    end
    table.insert( waitingPlayers[requestedChunk],player)
end)

return manager  