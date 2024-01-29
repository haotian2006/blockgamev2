local Generator = {}

local Configs = require(script.Config)
local RegionHelper = require(script.RegionHelper)
local Actor = script.Actor
local WorkerFolder = game.ServerScriptService:FindFirstChild("ChunkWorkers") or Instance.new("Folder",game.ServerScriptService)
WorkerFolder.Name = "ChunkWorkers"

local Communicator = require(script.Communicator)

local Bindable = Instance.new("BindableEvent",script)

function Generator.queueChunk(chunk)
    local Id = RegionHelper.GetIndexFromChunk(chunk)
    Communicator.sendMessageToId(Id,"Q",chunk.X,chunk.Z)
end

local function createWorker(index):Actor
    local clone = Actor:Clone()
    clone.Name = index
    clone.Parent = WorkerFolder
    clone.GenerationMain.Enabled = true 
    return clone
end

local Remote:RemoteEvent = game.ReplicatedStorage.Events.Chunk
local Builder = require(script.Parent.ChunkBuilder)
local alreadyInit = false
function Generator.Init()
    if alreadyInit then return end 
    alreadyInit = true
    for i=1,Configs.Actors do
        local Worker = createWorker(i)
        Worker:SendMessage("Init",Bindable)
    end
    Communicator.Init()
end

Bindable.Event:Connect(function(data)
    for i,v in data do
        local block,surface,biomes,chunk = unpack(v)
        Remote:FireAllClients(chunk,Builder.compress(block))
    end
    --Remote:FireAllClients(chunk,Builder.compress(shape))
end)
return Generator