local Chunk = {}
local Asked = {}
local Recieved = {}
local Rendered = {}

local Data = require(game.ReplicatedStorage.Data)
local Entity = Data.getPlayerEntity
local Runner = require(game.ReplicatedStorage.Runner)
local Render = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("Render"))

local RemoteEvent:RemoteEvent = game.ReplicatedStorage.Events.Chunk


function Chunk.requestChunk(Chunk)
    if Asked[Chunk] or Recieved[Chunk] then return end 
    RemoteEvent:FireServer(Chunk)
    Asked[Chunk] = true
end

local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local ChunkClass = require(game.ReplicatedStorage.Chunk)
RemoteEvent.OnClientEvent:Connect(function(chunk,data)  
    task.spawn(function()
        local t =table.create(8*8*256)
        for i = 0,buffer.len(data)-1 do
            t[i+1] = buffer.readu8(data, i) == 1 
        end
        local newchunk = ChunkClass.new(chunk.X, chunk.Z,t)
        Data.insertChunk(chunk.X, chunk.Z, newchunk)
    end)

    Recieved[chunk] = data
end)
local limit =4
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