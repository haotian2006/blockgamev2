local manager = {}
local Remote:RemoteEvent = game.ReplicatedStorage.Events.Chunk
local Data = require(game.ReplicatedStorage.Data)
local Generator = require(script.Generator)
local Layers = require(script.GenerationLayer)
local OverWorld = require(script.OverworldStack)

local Runner = require(game.ReplicatedStorage.Runner)

local Queue = {}
local waitingPlayers = {}

local maxIterations = 6

local function sendDataToAll(chunk,data)
    if not waitingPlayers[chunk] then return end 
    for i,v in waitingPlayers[chunk] do
        Remote:FireClient(v,chunk,data)
    end
    waitingPlayers[chunk] = nil
end

function manager.generateChunk(chunk)
    local data = Layers.get(OverWorld,chunk)
    sendDataToAll(chunk,data)
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