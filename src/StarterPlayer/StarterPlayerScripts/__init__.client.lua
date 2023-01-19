
local qf = require(game.ReplicatedStorage.QuickFunctions)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local EntityBridge = bridge.CreateBridge("EntityBridge")
--bridge.Start({})
local GetChunk = bridge.CreateBridge("GetChunk")
local datahandler = require(game.ReplicatedStorage.DataHandler)
local mulithandler = require(game.ReplicatedStorage.MultiHandler)
local toload = {}
local currentlyloading = {}
local queued = {}
local render = require(game.ReplicatedStorage.RenderStuff.Render)
local settings = require(game.ReplicatedStorage.GameSettings)
local resource = require(game.ReplicatedStorage.ResourceHandler)
local control = require(script.Parent.Controller)
local entityhandler = require(game.ReplicatedStorage.EntityHandler)
local Players = game:GetService("Players")
local tweenservice = game:GetService("TweenService")
resource:Init()
local runservicer = game:GetService("RunService")
local function createAselectionBox(parent,color) local sb = Instance.new("SelectionBox",parent) sb.Visible = false sb.Color3 = color or Color3.new(0.023529, 0.435294, 0.972549) sb.Adornee = parent sb.LineThickness = 0.025 return sb end
local function createEye(offset,hitbox)
    local eye = Instance.new("Part",hitbox.Parent)
    eye.Size = Vector3.new(hitbox.Size.X,0,hitbox.Size.Z)
    eye.Name = "Eye"
    eye.Transparency = 1
    local weld = Instance.new("Motor6D",eye)
    weld.Part0 = hitbox
    weld.Part1 = eye
    weld.C0 = offset and CFrame.new(hitbox.Position + Vector3.new(0,offset/2,0)*settings.GridSize) or CFrame.new(hitbox.Position)
    return eye
end
local function CreateModel(Data,ParentModel)
    local model = resource.GetEntityModelFromData(Data)
    if model then
        model = model:Clone()
        model.Parent = ParentModel
        model.Name = "EntityModel"
        local weld = Instance.new("Motor6D",ParentModel.PrimaryPart)
        weld.Name = "EntityModelWeld"
        weld.Part0 = ParentModel.PrimaryPart
        weld.Part1 = model.PrimaryPart
        local MiddleOffset = ParentModel.PrimaryPart.Size.Y-(ParentModel.PrimaryPart.Size.Y/2+model.PrimaryPart.Size.Y/2)
        local pos =ParentModel.PrimaryPart.Position 
        model.PrimaryPart.CFrame = CFrame.new(pos.X,pos.Y-MiddleOffset,pos.Z)
        weld.C0 = CFrame.new(0,-MiddleOffset,0)
        return model
    end
end
local function updateorientation(entity,entitydata,tween)
    for i,v in entitydata["OrientationData"] or {} do
        local c = entity:FindFirstChild(i,true)
        if c then
            local cfram =CFrame.new(c.C0.Position)*v*resource.GetEntityModelFromData(entitydata):FindFirstChild(i,true).C0.Rotation
            if not tween then
                c.C0 = cfram
            else
                tweenservice:Create(c,TweenInfo.new(0.1),{C0 = cfram}):Play()
            end
        end
    end
end
local function combinevelocity(v1,v2)
    for i,v in v2.Velocity do
        v1:AddVelocity(i,v)
    end
end
bridge.CreateBridge("DoMover"):Connect(function(entity,Mover,...)
    local mover = game.ReplicatedStorage.EntityMovers:FindFirstChild(Mover)
    if mover and datahandler.LoadedEntities[entity] then
        require(mover).new(datahandler.LoadedEntities[entity],...)
    end
end)
EntityBridge:Connect(function(entitys)
    for i,v in game.Workspace.Entities:GetChildren() do
        if not entitys[v.Name] then
            v:Destroy()
            i = v.Name
            if datahandler.LoadedEntities[i] then
                local last = datahandler.LoadedEntities[i]
                local chunk = datahandler.GetChunk(last.Chunk.X,last.Chunk.Y)
                datahandler.LoadedEntities[i]:Destroy()
            end
        end
    end
    for i,v in entitys do
        local e = game.Workspace.Entities:FindFirstChild(i)
        -- if datahandler.LoadedEntities[i] then
        --     local last = datahandler.LoadedEntities[i]
        --     if v.Chunk ~= datahandler.LoadedEntities[i].Chunk then
        --         local chunk = datahandler.GetChunk(last.Chunk.X,last.Chunk.Y)
        --         if chunk then
        --             chunk.Entities[i] = nil
        --         end
        --     end
        --     local chunk = datahandler.GetChunk(v.Chunk.X,v.Chunk.Y)
        --     if chunk then
        --         chunk.Entities[i] = v
        --     end
        -- end
        if e and tostring(i) ~= tostring(Players.LocalPlayer.UserId) then
            datahandler.LoadedEntities[i]:UpdateEntity(v)
            tweenservice:Create(e.PrimaryPart,TweenInfo.new(0.1),{CFrame = CFrame.new(v.Position*3)}):Play()
            updateorientation(e,v or {},true)
        elseif not e then
            --datahandler.LoadedEntities[i] = v
            local entity = entityhandler.new(v)
            datahandler.AddEntity(i,entity)
            local model = Instance.new("Model",workspace.Entities)
            entity.Entity = model
            local hitbox = Instance.new("Part",model)
            model.PrimaryPart = hitbox
            hitbox.Size = (Vector3.new(v.HitBox.X,v.HitBox.Y,v.HitBox.X) or Vector3.new(1,1,1))*settings.GridSize 
            local eye = createEye(v.EyeLevel,hitbox)
            local eyebox = createAselectionBox(eye,Color3.new(1, 0, 0))
            eyebox.Parent = hitbox
            CreateModel(v,model)
            createAselectionBox(hitbox)
            hitbox.CanCollide = false
            hitbox.Anchored = true
            hitbox.Transparency = 1
            hitbox.Name = "HitBox"
            hitbox.CFrame = CFrame.new(v.Position*3)
            model.Name = i
            updateorientation(model,v["OrientationData"] or {})
            if i == tostring(game.Players.LocalPlayer.UserId) then
                -- datahandler.GLocalPlayer.Position = v.Position
                -- datahandler.GLocalPlayer.Velocity = {}
                -- datahandler.GLocalPlayer.Grounded = v.Grounded
                workspace.CurrentCamera.CameraSubject = eye
                task.spawn(function()
                    while task.wait(.5) and datahandler.LoadedEntities[i] do
                        game.Players.LocalPlayer.Character.PrimaryPart.Anchored = true
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(datahandler.LoadedEntities[i].Position*3-Vector3.new(0,30,0)))
                    end
                end)
            end
        end
        if i == tostring(game.Players.LocalPlayer.UserId) then
            datahandler.LoadedEntities[i]:UpdateEntityClient(v)
            combinevelocity(datahandler.LoadedEntities[i],v)
            datahandler.LocalPlayer = datahandler.LoadedEntities[i]
        end
    end
end)
task.spawn(function()
    while false do
        for i=0,20 do
            local chr = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
            chr:WaitForChild("HumanoidRootPart")
            local c =  qf.SortTables(game.Players.LocalPlayer.Character.PrimaryPart.Position,toload)
            game.Players.LocalPlayer.PlayerGui.Debugging.Storage.Text = "ToLoad: "..#c
            for i,v in c do
                local chunk = v[1]
                local cx,cz = qf.cv2type("tuple",chunk)
                if render.UpdateChunk(cx,cz) then
                    toload[chunk] = nil
                    --break
                end
            end
        end
        runservicer.Heartbeat:Wait()
    end
end)
-- local todecode = {}
-- task.spawn(function()
--     while true do
--         runservicer.Heartbeat:Wait()
--         task.wait(1)
--         local chr = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait() chr:WaitForChild("HumanoidRootPart")
--         for i,v in qf.SortTables(game.Players.LocalPlayer.Character.PrimaryPart.Position,todecode) do
--             i = v[1]
--             v = todecode[i]
--             todecode[i] = nil
--             task.spawn(function()
--                 local cx,cz = qf.cv2type("tuple",i)
--                 queued[i] = false
--                 datahandler.CreateChunk({Blocks = mulithandler.DoSmt("DecompressBlockData",v,2)},cx,cz)
--                 toload[i] = true
--             end)
--             if i == 12 then
--                 break
--             end
--         end
--     end
-- end)
local function GetChunks(cx,cz)
    queued[cx..','..cz] = true
    game.ReplicatedStorage.Events.GetChunk:FireServer(cx,cz)
end
bridge.CreateBridge("UpdateBlocks"):Connect(function(data)
    local chtoup = {}
    for i,v in data.Remove or {} do
        local chunk = datahandler.RemoveBlock(v.X,v.Y,v.Z)
        chtoup[chunk:GetNString()]= chunk
        local cx,cz = chunk:GetNTuple()
        local v3 = qf.GridToLocal(v)
        local isedge,edges = qf.CheckIfChunkEdge(v3.X,v3.Y,v3.Z)
        if isedge then
            local chx = datahandler.GetChunk(cx+edges.X,cz)
            local chz = datahandler.GetChunk(cx,cz+edges.Y)
            if edges.X ~= 0 and chx then
                chtoup[chx:GetNString()]= chx
            end
            if edges.Y ~= 0 and chz then
                chtoup[chz:GetNString()]= chz
            end
        end
    end
    for i,v in chtoup do
        local cx,cz = v:GetNTuple()
        render.UpdateChunk(cx,cz,true)
    end
end)
game.ReplicatedStorage.Events.GetChunk.OnClientEvent:Connect(function(cx,cz,data)
    toload[cx..','..cz] = true
    queued[cx..','..cz] = false
    datahandler.CreateChunk({Blocks = data},cx,cz)
   if false then  
    local p = Instance.new("Part",workspace)
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Position = Vector3.new(cx*8*3,180,cz*8*3)
   end
   -- todecode[cx..','..cz] = data
   -- datahandler.CreateChunk({Blocks =data},cx,cz)
end)
local function GetCleanedChunk(cx,cz)
    return mulithandler.HideBlocks(cx,cz)
end
local function srender(p)
    for v,i in datahandler.LoadedChunks  do
		local splited = v:split(",")
		local vector = Vector2.new(splited[1],splited[2])*settings.ChunkSize.X*settings.GridSize
        local pv = Vector2.new(p.Position.X,p.Position.Z)
		if (vector-pv).Magnitude > 10*settings.ChunkSize.X*settings.GridSize then
           -- print()
            task.spawn( function()
                toload[v] = nil
                queued[v] = nil
                render.DeLoad(splited[1],splited[2])
            end)
        end
	end
    local cx1,cz1 = qf.GetChunkfromReal(qf.cv3type("tuple",p.Position)) 
    local s= qf.GetSurroundingChunk(cx1,cz1,3)
    local passed = 0
    for i,v in qf.SortTables(p.Position,s) do
        v = v[1]
        passed+=1
        local cx,cz = qf.cv2type("tuple",v)
        local ccx,ccz =  qf.GetChunkfromReal(qf.cv3type("tuple",p.Position)) 
        if (ccx ~= cx1 or ccz ~= cz1 )and passed>=6 then
          --  break
        end
        if not datahandler.GetChunk(cx,cz) and not queued[cx..','..cz] then
            GetChunks(cx,cz)
            task.wait(.08)
        end
    end
end
local char = game.Workspace:WaitForChild(game.Players.LocalPlayer.Name,math.huge)
task.wait(1)
local oldchunk =""
    srender(char.PrimaryPart)
	print("done")
    print(require(game.ReplicatedStorage.DelayHandler).PrintAverageTime("Greedy"))
while char and false do
    local currentChunk,c = qf.GetChunkfromReal(qf.cv3type("tuple",char.PrimaryPart.Position)) 
    currentChunk = currentChunk.."x"..c
    --shouldprint(currentChunk ~= oldchunk)
    if currentChunk ~= oldchunk and true then
        oldchunk = currentChunk
    --	newload(char.PrimaryPart)
        srender(char.PrimaryPart)
    end
	task.wait(0.1)
end

