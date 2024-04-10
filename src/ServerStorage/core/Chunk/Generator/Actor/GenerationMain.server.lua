local Actor:Actor = script.Parent
local Generator =  game.ServerStorage.core.Chunk.Generator

local runner = require(script.Parent.ParallelRunner)

local Communicator = require(Generator.Communicator)
Actor:BindToMessage("Init", function(bindable)
    Communicator.Init(bindable,Actor)
    local Handler = require(Generator.Handler)
    require(Generator.initializer)()
    Communicator.Ready = true
end)

local storage = unpack(require(Generator.ChunkAndStorage))

script.Parent.Info.OnInvoke = function()
    return storage.getStats()
end
