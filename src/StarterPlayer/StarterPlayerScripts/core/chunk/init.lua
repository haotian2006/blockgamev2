local Chunk = {}
local Asked = {}
local Recieved = {}
local Rendered = {}

local Data = require(game.ReplicatedStorage.Data)
local Entity = Data.getPlayerEntity
local Runner = require(game.ReplicatedStorage.Runner)
local PlayerScripts = game:GetService("Players").LocalPlayer.PlayerScripts
local Render = require(PlayerScripts:WaitForChild("Render"))
local BlockPool = require(game.ReplicatedStorage.Block.BlockPool)

local Worker = require(PlayerScripts:WaitForChild("ClientWorker"))
local ChunkWorkers =Worker.create("Chunk Worker", 10,nil,script.ChunkTasks)
local RemoteEvent:RemoteEvent = game.ReplicatedStorage.Events.Chunk


function Chunk.requestChunk(Chunk)
    if Asked[Chunk] or Recieved[Chunk] then return end 
    RemoteEvent:FireServer(Chunk)
    Asked[Chunk] = true
end

local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local ChunkClass = require(game.ReplicatedStorage.Chunk)
local once = false
RemoteEvent.OnClientEvent:Connect(function(chunk,blocks,biome)  
    local decomp =  ChunkWorkers:DoWork("deCompress",blocks)
    local newchunk = ChunkClass.new(chunk.X, chunk.Z,decomp,biome)
    Data.insertChunk(chunk.X, chunk.Z, newchunk)
    if not once then
        once = true
        print(buffer.tostring(blocks))
    end
    Recieved[chunk] = decomp
end)
local limit =2
game:GetService("RunService").RenderStepped:Connect(function(a0: number)  
    local done = 0
    for i,v in Recieved do
        if Rendered[i] then continue end
        local n,e,s,w = Recieved[i+Vector3.xAxis],Recieved[i+Vector3.zAxis],Recieved[i-Vector3.xAxis],Recieved[i-Vector3.zAxis]
        if not( n and e and s and w) then continue end 
        done+=1
        if done > limit then break end 
        Rendered[i] = true
        task.spawn(function()
            Render.render(i,v,n,e,s,w)
        end)
    end
end)
for x = 0,4 do
    for z = 0,4 do
        Chunk.requestChunk(Vector3.new(x,0,z))
    end
end
local utils = require(game.ReplicatedStorage.Utils.EntityUtils)
local r = 16
task.spawn(function()
    while true do
        local CEntity = Entity()
        if CEntity then
            for x = -r,r do
                for z = -r,r do
                    Chunk.requestChunk(Vector3.new(x,0,z)+utils.getChunk(CEntity))
                end
            end
        end
        task.wait()
    end
    
end)
return Chunk