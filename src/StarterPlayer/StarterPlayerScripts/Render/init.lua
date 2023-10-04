local RunService = game:GetService("RunService")
local dataHandler = require(game.ReplicatedStorage.DataHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local event = game.ReplicatedStorage.Events.GetChunk
local ChunkStorage = require(script.ChunkShared)
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local greedyMesh = require(script.GreedyMesh)
local multiHand = require(script.MultiHandler):Init(4)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local blockHandler = require(script.BlockHandler)
local rotationData = require(game.ReplicatedStorage.Libarys.RotationData)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
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
local function GILQ(x,y)
    return dataHandler.GetChunk(x,y)
end
local once = false
local csize = GameSettings.getChunkSize()
local gridS = GameSettings.GridSize
local function renderChunk(str,chunk,meshed,unmeshed)
    --//Handle deleated blocks
    local cx,cz = chunk()
    local chunkFolder = qf.GetFolder(chunk())
    local loadedBlocks = {}
    if chunkFolder then 
        for i,v in chunk.RenderedBlocks do
            if not meshed[i] and not unmeshed[i]  and chunkFolder:FindFirstChild(i) then
                chunkFolder:FindFirstChild(i):Destroy()
            end
        end
        --remove blocks that don't need to be changed
        for i,v in meshed do
            if not chunk.RenderedBlocks[i] then continue end 
            if qf.CompareTables(v,chunk.RenderedBlocks[i]) then
                loadedBlocks[i] = v
            else
                chunkFolder:FindFirstChild(i):Destroy()
            end
        end
        for i,v in unmeshed do
            if not chunk.RenderedBlocks[i] then continue end  
            if qf.CompareTables(v,chunk.RenderedBlocks[i]) then
                loadedBlocks[i] = v
            end
        end	
    end
    local index = 0
    chunk.RenderedBlocks = {}
    local folder = qf.GetFolder(cx,cz) or Instance.new("Model")
    for name,data in meshed do
        chunk.RenderedBlocks[name] = data
        if loadedBlocks[name] then continue end
        index +=1
        if index%2000 == 0 then task.wait() end
        local tt,oo,ss = unpack(data.data[1][1])
        if oo then
            oo = rotationData.indexPairs[tonumber(oo)]
        end
        local p = blockHandler.CreateBlock(data,nil,oo,CFrame.new(Vector3.new(data.real.X+cx*csize,data.real.Y,data.real.Z+cz*csize)*gridS)*(oo and rotationData.convertToCFrame(oo) or CFrame.new()).Position)
        p.Name = tostring(name)
        p.Size = Vector3.one
        p.CFrame  = CFrame.new(Vector3.new(data.real.X+cx*csize,data.real.Y,data.real.Z+cz*csize)*gridS)*(oo and rotationData.convertToCFrame(oo) or CFrame.new())
        p.Size = blockHandler.RotateStuff[oo or '0,0,0'](Vector3.new(data.l*gridS,data.h*gridS,data.w*gridS))
        p.Parent = folder
    end
        for i:Vector3,data in unmeshed do
            chunk.RenderedBlocks[i] = data[1]
            if loadedBlocks[i] then continue end
            index +=1
          --  v = qf.DecompressItemData(v)
            if index%2000 == 0 then task.wait() end
            local tt,oo,ss = unpack(data[1][1])
            if oo  then
                oo = rotationData.indexPairs[tonumber(oo)]
            end
            local dat= ResourceHandler.GetBlock(tt)
            local p =dat.Mesh:Clone()
            for i,v in  blockHandler.GetTextures(tt,data[2],oo) do
                v.Parent = p
            end
           -- p.Transparency = dat.Transparency
            p.Name = tostring(i)
            p.Anchored = true
            local x,y,z = i.X,i.Y,i.Z
            local offset = ResourceHandler.GetBlock(tt).Offset or Vector3.zero
            p.CFrame = CFrame.new(Vector3.new(x+cx*csize,y,z+cz*csize)*gridS)*(oo and rotationData.convertToCFrame(oo) or CFrame.new())*CFrame.new(offset*gridS)
            p.Parent = folder
        end
    folder.Parent = workspace.Chunks
    folder.Name = str
end
local function cull(str,chunk)
    if chunk.Destroyed then
        toCull[str] = nil
        return 
    end
    local cx,cz = chunk()
    local c10,c01,c20,c02 = GILQ(cx+1,cz),GILQ(cx,cz+1),GILQ(cx-1,cz),GILQ(cx,cz-1)
    if not (c10 and c01 and c20 and c02 ) then return end
    toCull[str] = nil
    if not once then 
    ChunkStorage:Upload(chunk:GetLastCompressed())
    ChunkStorage:Upload(c10:GetLastCompressed())
    ChunkStorage:Upload(c01:GetLastCompressed())
    ChunkStorage:Upload(c20:GetLastCompressed())
    ChunkStorage:Upload(c02:GetLastCompressed())
        --once = true
    local sides = multiHand:CullChunk(cx,cz)
    debug.profilebegin("greedy mesh")
    local meshed,unmeshed = greedyMesh.meshtable(chunk.Blocks or {},sides)
    debug.profileend()
    renderChunk(str,chunk,meshed,unmeshed)
    end
end
function HandleCull()
    for i,v in toCull do
        task.defer(cull,i,v)
    end
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
        local cx,cz = str:match("([^,]*),?([^,]*)")
        local c = dataHandler.CreateChunk({},cx,cz)
        c.lastCompressed = {data[1],key,0}
        c.Changed = false
        c:DeCompresAndInsert(data[1],key)
        toCull[str] = c
        --[[
        local m = Instance.new("Model")
        local ofx,ofy = GameSettings.getoffset(cx,cz)
        for idx,v in c.Blocks do
            if v:isFalse() then continue end 
            local p = Instance.new("Part")
            p.Size = Vector3.new(3,3,3)
            p.Anchored = true
            local x,y,z = GameSettings.to3D(idx)
            p.Position = Vector3.new(x+ofx,y,z+ofy)*3
            p.Parent = m
        end
     m.Parent = workspace]]
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
function Render.updateChunkAndNearby(cx,cz)
    local chunks = {
        dataHandler.GetChunk(cx,cz),
        dataHandler.GetChunk(cx+1,cz),
        dataHandler.GetChunk(cx-1,cz),
        dataHandler.GetChunk(cx,cz+1),
        dataHandler.GetChunk(cx,cz-1)
    }
    for i,v in chunks do
        toCull[tostring(v)] = v 
    end
end
function Render.updateBlocks(block,x,y,z)
    local cx,cz,x,y,z  = qf.GetChunkAndLocal(x,y,z)
    local chunk = dataHandler.GetChunk(cx,cz)
    if not chunk then return end 
    if not block then
        chunk:RemoveBlock(x,y,z)
    else
        chunk:InsertBlock(x,y,z,block)
    end
    Render.updateChunkAndNearby(cx,cz)
end
local tick = 0
local t = .02
function Render:Init()
    game.ReplicatedStorage.Events.GetChunk.OnClientEvent:Connect(Render.onRecieve)
    RunService.Heartbeat:Connect(function(deltaTime)
        tick += deltaTime
        --if tick  >= t then
            HandleCull()
            tick = 0
     --   end
    end)
    bridge.CreateBridge("UpdateBlocks"):Connect(Render.updateBlocks)
        
    return Render
end

return Render