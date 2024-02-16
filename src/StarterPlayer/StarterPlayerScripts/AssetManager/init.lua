local manager = {}
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
ResourceHandler.Init()

local Blocks = require(script.Block)
local BTexture = require(script.BlockTexture)
local Other = require(script.Other)
manager.Blocks = Blocks
manager.Resources = ResourceHandler
function manager.init()
    Other.init()
    task.wait()
    BTexture.init()
    Blocks.init()
end

return table.freeze(manager)