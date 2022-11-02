
local qf = require(game.ReplicatedStorage.QuickFunctions)
local datahandler = require(game.ReplicatedStorage.DataHandler)
local mulithandler = require(game.ReplicatedStorage.MultiHandler)
local toload = {}
local currentlyloading = {}
local queued = {}
local render = require(game.ReplicatedStorage.RenderHandler.Render)
local runservicer = game:GetService("RunService")
task.spawn(function()
    while true do
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
        runservicer.RenderStepped:Wait()
    end
end)
local function GetChunks(cx,cz)
    queued[cx..','..cz] = true
    game.ReplicatedStorage.Events.GetChunk:FireServer(cx,cz)
end
game.ReplicatedStorage.Events.GetChunk.OnClientEvent:Connect(function(cx,cz,data)
    toload[cx..','..cz] = true
    queued[cx..','..cz] = false
    datahandler.CreateChunk({Blocks = data},cx,cz)
end)
local function GetCleanedChunk(cx,cz)
    return mulithandler.HideBlocks(cx,cz)
end
local function srender(p)
    local cx,cz = qf.GetChunkfromReal(qf.cv3type("tuple",p)) 
    local s= qf.GetSurroundingChunk(cx,cz,10)
    for i,v in s do
        local cx,cz = qf.cv2type("tuple",v)
        if not datahandler.GetChunk(cx,cz) and not queued[cx..','..cz] then
            GetChunks(cx,cz)
            runservicer.RenderStepped:Wait()
        end
    end
end
local char = game.Workspace:WaitForChild(game.Players.LocalPlayer.Name,math.huge)
task.wait(1)
local oldchunk =""
    srender(char.PrimaryPart.Position)
	print("done")
	while char do
		local currentChunk,c = qf.GetChunkfromReal(qf.cv3type("tuple",char.PrimaryPart.Position)) 
		currentChunk = currentChunk.."x"..c
		--shouldprint(currentChunk ~= oldchunk)
		if currentChunk ~= oldchunk and true then
			oldchunk = currentChunk
		--	newload(char.PrimaryPart)
            srender(char.PrimaryPart.Position)
		end
	task.wait(0.1)
end

