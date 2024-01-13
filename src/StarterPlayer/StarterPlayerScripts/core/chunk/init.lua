local Chunk = {}
local Asked = {}
local Recieved = {}
local Rendered = {}

local Data = require(game.ReplicatedStorage.Data)
local Entity = Data.getPlayerEntity
local EntityUtils = require(game.ReplicatedStorage.Utils.EntityUtils)
local Runner = require(game.ReplicatedStorage.Runner)
local PlayerScripts = game:GetService("Players").LocalPlayer.PlayerScripts
local Render = require(PlayerScripts:WaitForChild("Render"))
local BlockRender = require(PlayerScripts:WaitForChild("Render"):WaitForChild("BlockRender"))
local BlockPool = require(game.ReplicatedStorage.Block.BlockPool)
local SubChunkHelper = require(PlayerScripts:WaitForChild("Render"):WaitForChild("SubChunkHelper"))

local Worker = require(PlayerScripts:WaitForChild("ClientWorker"))
local ChunkWorkers =Worker.create("Chunk Worker", 10,nil,script.ChunkTasks)
local RemoteEvent:RemoteEvent = game.ReplicatedStorage.Events.Chunk
local destroyed = {}
function Chunk.requestChunk(chunk)
    if Asked[chunk] or Recieved[chunk] then return end 
    destroyed[chunk] = nil 
    RemoteEvent:FireServer(chunk)
    Asked[chunk] = true
end

local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local ChunkClass = require(game.ReplicatedStorage.Chunk)
local once = false

RemoteEvent.OnClientEvent:Connect(function(chunk,blocks,biome)  
    if destroyed[chunk] then return end 
    local decomp =  ChunkWorkers:DoWork("deCompress",blocks)
    local newchunk = ChunkClass.new(chunk.X, chunk.Z,decomp,biome)
    Data.insertChunk(chunk.X, chunk.Z, newchunk)
    if not once then
        once = true 
    end
    BlockRender.Destroyed[chunk] = nil
    Asked[chunk] = false
    Recieved[chunk] = true
    Render.Recieved[chunk] = decomp
    Render.subChunkQueue[chunk] = 1
end)

local utils = require(game.ReplicatedStorage.Utils.EntityUtils)
local offsets = {}
local Inrange = {}
local r =  16
r+=2
for dist = 0, r do
    for x = -dist, dist do
        local zBound = math.floor(math.sqrt(r * r - x * x)) -- Bound for 'z' within the circle
        for z = -zBound, zBound do
            local radius = x*x +z*z 
            if radius > r*r then continue end 
            if table.find(offsets,Vector3.new(x,0,z)) then continue end 
            table.insert(offsets,Vector3.new(x,0,z))
            if radius > (r-2)^2 then continue end 
            Inrange[Vector3.new(x,0,z)] = true
        end
    end
end
    
local last = Vector3.new(0,-1,0)
game:GetService("RunService").Heartbeat:Connect(function(a0: number)  
    local CEntity = Entity()
    if CEntity then
        local current = EntityUtils.getChunk(CEntity)
        if last == current then return end 
        last = current
        local checked = {}
        for i,offset in offsets do
            local c = offset+utils.getChunk(CEntity)
            if Inrange[offset] then
                Chunk.requestChunk(c)
            end
            checked[c] = true
        end 
        for i,v in Recieved do
            if checked[i] then continue end 
            destroyed[i] = true
            Recieved[i] = nil
            Render.deloadChunk(i)
        end
    end
end)

return Chunk