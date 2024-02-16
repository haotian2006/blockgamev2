local manager = {}
local Remote:RemoteEvent = game.ReplicatedStorage.Events.Chunk
local Data = require(game.ReplicatedStorage.Data)
local Generator2 = require(script.Generator)
local ChunkClass = require(game.ReplicatedStorage.Chunk)
local Builder = require(script.ChunkBuilder)
local waitingPlayers = {}
local requested = {}


local function sendDataToClients(chunk,...)
    if not waitingPlayers[chunk] then return end 
    for v,i in waitingPlayers[chunk] do
        Remote:FireClient(v,chunk,...)
    end
    waitingPlayers[chunk] = nil
end



Generator2.Init().Event:Connect(function(data)
    for i,v in data do
        local block,surface,biomes,chunk = unpack(v)
        if not block then
            sendDataToClients(chunk,false)
            requested[chunk] = nil
            continue
        end
        local newChunk = ChunkClass.new(data.X,data.Z,block,biomes)
        Data.insertChunk(chunk.X,chunk.Z,newChunk)
        sendDataToClients(chunk,Builder.compress(block),biomes)
        requested[chunk] = nil
    end
    --Remote:FireAllClients(chunk,Builder.compress(shape))
end)
--mainQueue[Vector3.new(0,0,0)] = true
Remote.OnServerEvent:Connect(function(player,requestedChunk)
    local found = Data.getChunk(requestedChunk.X,requestedChunk.Z)
    if found then
        Remote:FireClient(player,requestedChunk,Builder.compress(found.Blocks),found.BiomeMap)
        return
    end
    if not waitingPlayers[requestedChunk] then
        waitingPlayers[requestedChunk]  = {}
    
    end
    waitingPlayers[requestedChunk][player] = true
    if requested[requestedChunk] then return end 
    Generator2.queueChunk(requestedChunk)
    requested[requestedChunk] = true
    return
end)

return manager  