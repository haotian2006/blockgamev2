return function()
    local Communicator = require(script.Parent.Communicator)
    require(game.ReplicatedStorage.WorldConfig).Init()
    local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
    BehaviorHandler.loadComponent("Biomes")
    BehaviorHandler.loadComponent("Structures")
    BehaviorHandler.loadComponent("Ores")
    BehaviorHandler.loadComponent("Foilage")
    --BehaviorHandler.loadComponent("Blocks")
    local Blocks = require(game.ReplicatedStorage.Block).Init()
    local biomes = require(game.ReplicatedStorage.Biomes)
    local Registry = require(script.Parent.Registry)
    biomes.init()
    Communicator.runParallel(function()
        Registry.init()
    end)
end
