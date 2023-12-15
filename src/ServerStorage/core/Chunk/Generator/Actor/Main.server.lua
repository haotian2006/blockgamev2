local Actor:Actor = script.Parent
local DataHandler:BindableEvent
local Tasks = require(game.ServerStorage.core.Chunk.Generator.Tasks)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)

Actor:BindToMessage("Init", function(bindable)
    DataHandler = bindable
    BehaviorHandler.loadComponet("Biomes")
end)
Actor:BindToMessageParallel("M", function(Idx,task,...)
    local func = Tasks[task]
    if not func then warn(`{task} is not a valid task`) end 
    DataHandler:Fire(Idx,func(...))
end)
