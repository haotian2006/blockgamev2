local Remote:UnreliableRemoteEvent = script.Replicator

local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")

local Data = require(game.ReplicatedStorage.Data)
local BiomeHandler = require(game.ReplicatedStorage.Biomes)
local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local RegionUtils = require(game.ReplicatedStorage.Utils.RegionUtils)

local IS_SERVER = RunService:IsServer()

local Stats = {}

local Server = {}

Stats.Server = Server

local Client = {
    Location = Vector3.zero,
    Chunk = Vector3.zero,
    BiomeId = -1,
    Biome = "null",
    Velocity = Vector3.zero,
    Region = Vector2.zero

}

Stats.Client = Client

local TimeFunction = RunService:IsRunning() and time or os.clock

local LastIteration, Start = 0 ,TimeFunction()
local FrameUpdateTable = {}

local function getFPS()
	LastIteration = TimeFunction()
	for Index = #FrameUpdateTable, 1, -1 do
		FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
	end

	FrameUpdateTable[1] = LastIteration
	return math.floor(TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start))
end

local function InitServer()
    local GeneratorWorkers = require(game.ServerStorage.core.Chunk.Generator)
    return function()
        local Chunk,Weak,Destroy = GeneratorWorkers.getStats()
        Server["Gen_Chunks"] = Chunk
        Server["Gen_Weak_Chunks"] = Weak
        Server["Gen_Destroy_Stack"] = Destroy
    end
end

local function InitClient()
    Remote.OnClientEvent:Connect(function(data)
        for i,v in data do
            Server[i] = v
        end
      
    end)
    local Scripts = game.Players.LocalPlayer.PlayerScripts
    local Core  =Scripts:WaitForChild("core")
    local Render = Core:WaitForChild("chunk"):WaitForChild("Rendering")
    local RHandler = require(Render:WaitForChild("Handler"))
    local RCache = require(Render:WaitForChild("RenderCache"))
    return function()
        local Entity = Data.getPlayerEntity()
        if Entity then
            local Position = Entity.Position
            Client.Location = Position
            local Biome = Data.getBiome(Position.X,Position.Y,Position.Z) or -1
            Client.BiomeId = Biome
            Client.Biome = BiomeHandler.getBiomeFrom(Biome) 
            Client.Chunk = (Position+Vector3.one*.5)//8
            Client.Velocity = EntityHandler.getTotalVelocity(Entity)
            local Region = RegionUtils.getRegion(Client.Chunk)
            Client.Region = Vector2.new(Region.X,Region.Z)

        end


        local SubChunk,Cull,ToBuild = RHandler.getStats()
        Client["Render_SubChunk"] = SubChunk
        Client["Render_Cull"] = Cull
        Client["Render_Build"] = ToBuild

        local BlockC,TextureC = RCache.getStats()

        Client["Render_Cache_Block"] = BlockC
        Client["Render_Cache_Texture"] = TextureC

    end
end

local UpdateFunction = if IS_SERVER then InitServer() else InitClient()

local function Update()
    local TableToUpdate

    if IS_SERVER then
        TableToUpdate = Server
    else
        TableToUpdate = Client
    end
    TableToUpdate["Fps"] = getFPS()
    TableToUpdate["Memory"] = StatsService:GetTotalMemoryUsageMb()
    TableToUpdate["Send"] = StatsService.DataSendKbps
    TableToUpdate["Recv"] = StatsService.DataReceiveKbps
    TableToUpdate["HeartbeatTime"] = StatsService.HeartbeatTimeMs
    UpdateFunction()
    if IS_SERVER then
        Remote:FireAllClients(TableToUpdate)
    end
end

RunService.Stepped:Connect(Update)

return Stats