
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
local Players = game:GetService("Players")
local tweenservice = game:GetService("TweenService")
resource:Init()
local runservicer = game:GetService("RunService")
local function createAselectionBox(parent,color) local sb = Instance.new("SelectionBox",parent)  sb.Color3 = color or Color3.new(0.023529, 0.435294, 0.972549) sb.Adornee = parent sb.LineThickness = 0.025 return sb end
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
EntityBridge:Connect(function(entitys)
    for i,v in game.Workspace.Entities:GetChildren() do
        if not entitys[v.Name] then
            v:Destroy()
        end
    end
    for i,v in entitys do
        local e = game.Workspace.Entities:FindFirstChild(i)

        if e and tostring(i) ~= tostring(Players.LocalPlayer.UserId) then
            tweenservice:Create(e.PrimaryPart,TweenInfo.new(0.01),{CFrame = CFrame.new(v.Position*3)}):Play()
        elseif not e then
            --datahandler.LoadedEntities[i] = v
            local model = Instance.new("Model",workspace.Entities)
            local hitbox = Instance.new("Part",model)
            model.PrimaryPart = hitbox
            hitbox.Size = (Vector3.new(v.HitBox.X,v.HitBox.Y,v.HitBox.X) or Vector3.new(1,1,1))*settings.GridSize 
            local eye = createEye(v.EyeLevel,hitbox)
            local eyebox = createAselectionBox(eye,Color3.new(1, 0, 0))
            eyebox.Parent = hitbox
            createAselectionBox(hitbox)
            hitbox.CanCollide = false
            hitbox.Anchored = true
            hitbox.Transparency = 1
            hitbox.Name = "HitBox"
            hitbox.CFrame = CFrame.new(v.Position*3)
            model.Name = i
            if i == tostring(game.Players.LocalPlayer.UserId) then
                datahandler.GLocalPlayer.Position = v.Position
                datahandler.GLocalPlayer.Velocity = v.Velocity
                datahandler.GLocalPlayer.Grounded = v.Grounded
                workspace.CurrentCamera.CameraSubject = eye
                task.spawn(function()
                    while task.wait(.5) do
                        game.Players.LocalPlayer.Character.PrimaryPart.Anchored = true
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(datahandler.GLocalPlayer.Position*3-Vector3.new(0,30,0)))
                    end
                end)
            end
        end
        if i == tostring(game.Players.LocalPlayer.UserId) then
            v.Jumping = datahandler.GLocalPlayer.Jumping
            v.Entity =  game.Workspace.Entities:FindFirstChild(i)
            v.Velocity = datahandler.GLocalPlayer.Velocity
            v.Position = datahandler.GLocalPlayer.Position 
            v.Grounded = datahandler.GLocalPlayer.Grounded 
            datahandler.LocalPlayer = v
        end
    end
end)
task.spawn(function()
    while true do
        for i=0,20 do
            local chr = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
            chr:WaitForChild("HumanoidRootPart")
            local c =  qf.SortTables(game.Players.LocalPlayer.Character.PrimaryPart.Position,toload)
            game.Players.LocalPlayer.PlayerGui.Debugging.Storage.Text = "ToLoad: "..#c
            for i,v in c do
                local chunk = v[1]
                local cx,cz = qf.cv2type("tuple",chunk)
                if render.render(cx,cz) then
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
    local s= qf.GetSurroundingChunk(cx1,cz1,7)
    local passed = 0
    for i,v in qf.SortTables(p.Position,s) do
        v = v[1]
        passed+=1
        local cx,cz = qf.cv2type("tuple",v)
        local ccx,ccz =  qf.GetChunkfromReal(qf.cv3type("tuple",p.Position)) 
        if (ccx ~= cx1 or ccz ~= cz1 )and passed>=6 then
            break
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
	while char do
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

