local RunService = game:GetService("RunService")
local dataHandler = require(game.ReplicatedStorage.DataHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local event = game.ReplicatedStorage.Events.GetChunk
local Render = {}
local queued = {}
local toLoad = {}
local toCull = {}
local DELOAD_DISTANCE = 12
local RENDER_DISTANCE = 9
function Render.deLoad(cx,cz)
    dataHandler.DestroyChunk(cx,cz)
    if game.Workspace.Chunks:FindFirstChild(cx..","..cz) then
        local c = game.Workspace.Chunks:FindFirstChild(cx..","..cz)
        c.Parent = nil
        c:Destroy()
    end
end
local function cull(str,chunk)
    
end

function Render.checkForDeload(p)
    for v,i in dataHandler.LoadedChunks  do
        local splited = v:split(",")
        local vector = Vector2.new(splited[1],splited[2])*settings.ChunkSize.X*settings.GridSize
        local pv = Vector2.new(p.Position.X,p.Position.Z)
        if (vector-pv).Magnitude > DELOAD_DISTANCE*settings.ChunkSize.X*settings.GridSize then
            task.spawn( function()
                toLoad[v] = nil
                queued[v] = nil
                Render.deLoad(splited[1],splited[2])
            end)
        end
    end
end
function  Render.onRecieve(chunks,key)
    for str,data in chunks do
        queued[str] = false
        local c = dataHandler.CreateChunk({},str:match("([^,]*),?([^,]*),?([^,]*)"))
        c:DeCompresAndInsert(data[1],key)
        toLoad[str] = c
    end
end
function Render.requestNearby(position)
    local cx1,cz1 = qf.GetChunkfromReal(position.X,position.Y,position.Z) 
    local s= qf.GetSurroundingChunk(cx1,cz1,DELOAD_DISTANCE)
    local passed = 0
    for i,v in qf.SortTables(position,s) do
        v = v[1]
        passed+=1
        local cx,cz = v:match("([^,]*),?([^,]*)")
        local ccx,ccz =  qf.GetChunkfromReal(position.X,position.Y,position.Z) 
        if (ccx ~= cx1 or ccz ~= cz1 )and passed>=6 then
          --  break
        end
        if not dataHandler.GetChunk(cx,cz) and not queued[v] then
            event:FireServer(cx,cz)
            queued[v] = true

        end
    end
end
function Render:Init()
    RunService.Heartbeat:Connect(function(deltaTime)
       
     
    end)
end

return Render