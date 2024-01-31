local Actor:Actor = script.Parent
local Generator =  game.ServerStorage.core.Chunk.Generator

local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local runner = require(script.Parent.ParallelRunner)

local Communicator = require(Generator.Communicator)
Actor:BindToMessage("Init", function(bindable)
    BehaviorHandler.loadComponet("Biomes")
    Communicator.Init(bindable,Actor)
    local Handler = require(Generator.Handler)
end)

local storage = unpack(require(Generator.ChunkAndStorage))

script.Parent.Info.OnInvoke = function()
    return storage.getInfo()
end
