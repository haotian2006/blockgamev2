local Communicator = {}

local RegionHelper = require(script.Parent.RegionHelper)

local Actors = {}::{[number]:Actor}
local ActorID = 0
local Actor:Actor = nil
local Main:BindableEvent = nil
local Runner

local CallBacks = {

}

local ToSend = {}

local function BindToRecv()
    if not Actor then return end 
    Runner = require(Actor:FindFirstChild("ParallelRunner"))
    Actor:BindToMessage("Message", function(From,Message,...)
        CallBacks[Message](From,...)
    end)
end

function Communicator.chunkNotInActor(chunk)
    local Region = RegionHelper.GetIndexFromChunk(chunk)
    return if Region == ActorID then false else Region
end

function Communicator.isActor()
    return Actor and true or false
end

function Communicator.getActor()
    return Actor,ActorID 
end

function Communicator.getRunner():(any)->(any)
    return Runner
end

function Communicator.runParallel(task:(any)->(any),...:any):(any)
    return Runner(task,...)
end

function Communicator.bindToMessage(message,callBack)
    CallBacks[message] = callBack
end

function Communicator.sendMessageToId(Id,MessageType,...)
   debug.profilebegin(MessageType)
   if MessageType == "Q" then 
   end
   Actors[Id]:SendMessage("Message",ActorID,MessageType,...)
   debug.profileend()
end

function Communicator.delayMessageToId(Id,MessageType,...)
    ToSend[Id] = ToSend[Id] or {}
 end
 

function Communicator.sendMessageMain(...)
    Main:Fire(...)
end

function Communicator.Init(Main_,Actor_)
    local ChunkFolder = game.ServerScriptService:WaitForChild("ChunkWorkers")
    for i,v in ChunkFolder:GetChildren() do
        Actors[tonumber(v.Name)] = v
    end
    Main = Main_
    Actor = Actor_
    ActorID = if Actor_ then tonumber(Actor_.Name) else 0
    BindToRecv()
end

return Communicator