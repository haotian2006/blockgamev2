local self = {}
local qf = require(game.ReplicatedStorage.QuickFunctions)
local blockdata = require(game.ReplicatedStorage.blockdata)
local mulithandler = require(game.ReplicatedStorage.MultiHandler)
local rendering = require(game.ReplicatedStorage.RenderHandler)
local toload = {}
local currentlyloading = {}
function self.GetChunks(cx,cz)
    game.ReplicatedStorage.Events.GetChunk:FireServer(cx,cz)
end
game.ReplicatedStorage.Events.GetChunk.OnClientEvent:Connect(function(cx,cz,data)
    toload[cx..','..cz] = true
end)
function self.GetCleanedChunk(cx,cz)
    return mulithandler.HideBlocks(cx,cz)
end
return self