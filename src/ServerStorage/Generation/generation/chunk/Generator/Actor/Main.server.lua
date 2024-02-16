local Actor:Actor = script.Parent
local DataHandler:BindableEvent
local ChunkGeneration = game.ServerStorage.Generation.generation.chunk
local Tasks = require(ChunkGeneration.Generator.Tasks)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)

Actor:BindToMessage("Init", function(bindable)
    DataHandler = bindable
end)
Actor:BindToMessageParallel("M", function(Idx,task,...)
    local func = Tasks[task]
    if not func then warn(`{task} is not a valid task`) end 
    DataHandler:Fire(Idx,func(...))
end)
Actor:BindToMessage("D", function(idx,taskToDO,...)
    task.spawn(function(...)
        task.wait()
        task.desynchronize()
        local func = Tasks[taskToDO]
        if not func then warn(`{taskToDO} is not a valid task`) end 
        DataHandler:Fire(idx,func(...))
    end,...)
end)
