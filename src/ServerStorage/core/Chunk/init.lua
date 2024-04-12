local manager = {}
local Remote:RemoteEvent = game.ReplicatedStorage.Events.Chunk
local Data = require(game.ReplicatedStorage.Data)
local Generator2 = require(script.Generator)
local BlockClass = require(game.ReplicatedStorage.Handler.Block)
local ChunkClass = require(game.ReplicatedStorage.Chunk)
local ItemClass = require(game.ReplicatedStorage.Handler.Item)
local Builder = require(script.ChunkBuilder)
local RegionHandler = require(script.RegionManager)
local EntityUtils = require(game.ReplicatedStorage.Utils.EntityUtils)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)
local EntityRegionManager = require(script.Parent.Entity.EntityRegionSaver)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local CollisionUtils = require(game.ReplicatedStorage.Utils.CollisionUtils)
local EntityHandler = require(game.ReplicatedStorage.Handler.EntityHandler)
local Events = require(game.ReplicatedStorage.Events)

local SIMULATED_DISTANCE = 6
local RENDER_DISTANCE  = 13

local waitingPlayers = {}
local requested = {}
local Simulated = Data.getSimulated()

local function sendDataToClients(chunk,...)
    if not waitingPlayers[chunk] then return end 
    for v,i in waitingPlayers[chunk] do
        Remote:FireClient(v,chunk,...)
    end
    waitingPlayers[chunk] = nil
end

local RenderOffset = OtherUtils.preComputeSquare(RENDER_DISTANCE)
local SimulatedOffset = OtherUtils.flip(OtherUtils.preComputeSquare(SIMULATED_DISTANCE))
local function startMainLoop()
    local AllChunks = {}
    local HasYielded = false
    local Checked = 0
    local function combine(t)
        for i,v in t do
            if v then
                Simulated[i] = true
            end
            if AllChunks[i] then continue end 
            AllChunks[i] = v
        end
    end
    local function PlayerCheck(v)
        if Checked == 7 then
            HasYielded = coroutine.running()
            coroutine.yield()
            Checked = 0
        end
        Checked+=1
        local Entity = Data.getEntityFromPlayer(v)
        if not Entity then return end 
        local Chunk = EntityUtils.getChunk(Entity)
        local last = Entity.__localData.LASTCHUNKCHECK 
        local NearByChunks = Entity.__localData.NearByChunks or {}
        if Chunk == last then 
            combine(NearByChunks)
            return 
        end 
        Entity.__localData.LASTCHUNKCHECK  = Chunk
        table.clear(NearByChunks)
        for _,offset in RenderOffset do
            local real = Chunk + offset
            NearByChunks[real] = SimulatedOffset[offset] and true or false 
        end
        Entity.__localData.NearByChunks = NearByChunks
        combine(NearByChunks)
    end
    game:GetService("RunService").Heartbeat:Connect(function(dt)
        if HasYielded then
            task.spawn(HasYielded)
            HasYielded = false
            return
        end
        Checked = 0
        table.clear(AllChunks)
        for i,v in game:GetService("Players"):GetPlayers() do
            PlayerCheck(v)
        end

        for i,v in Simulated do
            local C = Data.getChunkFrom(i)
            if not AllChunks[i] then
                Simulated[i] = nil
                if C then
                    C.Status.Simulated = false
                end
                continue
            end
            if not C then continue end 
            C.Status.Simulated = true
        end
        for i,v in AllChunks do
            if Data.getChunkFrom(i) or requested[i] then continue end 
            RegionHandler.addChunk(i)
            Generator2.queueChunk(i)
            requested[i] = true
        end
    end)
end



Generator2.Init().Event:Connect(function(msgType,data)
    if msgType == "Generator" then
        for i,v in data do
            local block,biomes,chunk,compressed = unpack(v)
            if not block then
                sendDataToClients(chunk,false)
                requested[chunk] = nil
                continue
            end
            local newChunk = ChunkClass.new(chunk.X,chunk.Z,block,biomes)
            Data.insertChunk(chunk.X,chunk.Z,newChunk)
            local Entities = EntityRegionManager.getEntitiesFromChunk(chunk)
            if Entities then 
                for _,entity in Entities do
                    Data.addEntity(entity)
                end
            end
            sendDataToClients(chunk,compressed,biomes)
            requested[chunk] = nil
        end
    end

    --Remote:FireAllClients(chunk,Builder.compress(shape))
end)
--mainQueue[Vector3.new(0,0,0)] = true
Remote.OnServerEvent:Connect(function(player,requestedChunk)
    RegionHandler.addChunk(requestedChunk)
    local found = Data.getChunk(requestedChunk.X,requestedChunk.Z)
    if found then
        Remote:FireClient(player,requestedChunk,Builder.compress(found.Blocks),found.BiomeMap)
        return
    end
    if not waitingPlayers[requestedChunk] then
        waitingPlayers[requestedChunk]  = {}
    
    end
    waitingPlayers[requestedChunk][player] = true
end)
startMainLoop()

return manager  