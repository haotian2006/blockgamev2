
local qf = require(game.ReplicatedStorage.QuickFunctions)
local datahandler = require(game.ReplicatedStorage.DataHandler)
local mulithandler = require(game.ReplicatedStorage.MultiHandler)
local toload = {}
local currentlyloading = {}
local queued = {}
local render = require(game.ReplicatedStorage.RenderStuff.Render)
local runservicer = game:GetService("RunService")
task.spawn(function()
    while true do
        for i=0,6 do
            local chr = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
            chr:WaitForChild("HumanoidRootPart")
            for i,v in qf.SortTables(game.Players.LocalPlayer.Character.PrimaryPart.Position,toload) do
                local chunk = v[1]
                local cx,cz = qf.cv2type("tuple",chunk)
                if render.render(cx,cz) then
                    toload[chunk] = nil
                    break
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
   -- todecode[cx..','..cz] = data
    toload[cx..','..cz] = true
    queued[cx..','..cz] = false
    datahandler.CreateChunk({Blocks = data},cx,cz)
   -- datahandler.CreateChunk({Blocks =data},cx,cz)
end)
local function GetCleanedChunk(cx,cz)
    return mulithandler.HideBlocks(cx,cz)
end
local function srender(p)
    local cx1,cz1 = qf.GetChunkfromReal(qf.cv3type("tuple",p.Position)) 
    local s= qf.GetSurroundingChunk(cx1,cz1,5)
    local passed = 0
    for i,v in qf.SortTables(p.Position,s) do
        v = v[1]
        passed+=1
        local cx,cz = qf.cv2type("tuple",v)
        local ccx,ccz =  qf.GetChunkfromReal(qf.cv3type("tuple",p.Position)) 
        if (ccx ~= cx1 or ccz ~= cz1 )and passed>=18 then
            break
        end
        if not datahandler.GetChunk(cx,cz) and not queued[cx..','..cz] then
            GetChunks(cx,cz)
            task.wait(.1)
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

