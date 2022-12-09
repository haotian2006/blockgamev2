
local qf = require(game.ReplicatedStorage.QuickFunctions)
local datahandler = require(game.ReplicatedStorage.DataHandler)
local mulithandler = require(game.ReplicatedStorage.MultiHandler)
local toload = {}
local currentlyloading = {}
local queued = {}
local render = require(game.ReplicatedStorage.RenderStuff.Render)
local settings = require(game.ReplicatedStorage.GameSettings)
local resource = require(game.ReplicatedStorage.ResourceHandler)
local control = require(script.Parent.Controller)
local tweenservice = game:GetService("TweenService")
resource:Init()
local runservicer = game:GetService("RunService")
game.ReplicatedStorage.Events.SendEntities.OnClientEvent:Connect(function(entitys)
    for i,v in game.Workspace.Entities:GetChildren() do
        if not entitys[i] then
            v:Destroy()
        end
    end
    for i,v in entitys do
        local e = game.Workspace.Entities:FindFirstChild(i)
        if e then
            tweenservice:Create(e,TweenInfo.new(0.1),{Position = v.Position*3}):Play()
        else
            --datahandler.LoadedEntities[i] = v
            local hitbox = Instance.new("Part",workspace.Entities)
            hitbox.Size = Vector3.new(v.HitBox.X,v.HitBox.Y,v.HitBox.X)*settings.GridSize
            hitbox.CanCollide = false
            hitbox.Anchored = true
            hitbox.Transparency = 0.5
            hitbox.Position = v.Position*3
            hitbox.Name = i
            
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

