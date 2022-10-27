local self = {}
local qf = require(game.ReplicatedStorage.QuickFunctions)
local blockdata = require(game.ReplicatedStorage.blockdata)
local mulithandler = require(game.ReplicatedStorage.MultiHandler)
local rendering = require(game.ReplicatedStorage.RenderHandler)
function self.GetChunk(cx,cz)
    return game.ReplicatedStorage.Events.GetChunk:InvokeServer(cx,cz)
end
function self.GetCleanedChunk(cx,cz)
    return mulithandler.HideBlocks(cx,cz)
end
return self