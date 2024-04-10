local Generator = {}

local Workers = {}

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

function Generator.getStats()
    local ChunksInQueue,WeakChunks,ToDestroy = 0,0,0
    for i,v in Workers do
        local Bindable:BindableFunction = v.Info
        local ChunksInQueue_,WeakChunks_,ToDestroy_ = Bindable:Invoke()
        ChunksInQueue += ChunksInQueue_
        WeakChunks+= WeakChunks_
        ToDestroy += ToDestroy_
    end
    return ChunksInQueue,WeakChunks,ToDestroy
end

local alreadyInit = false
function Generator.Init()
    if alreadyInit then return end 
    alreadyInit = true
    for i=1,Configs.Actors do
        local Worker = createWorker(i)
        Workers[i] = Worker
        Worker:SendMessage("Init",Bindable)
    end
    Communicator.Init()
    return Bindable
end


return Generator