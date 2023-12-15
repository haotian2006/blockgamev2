local Render = {}
local Remote:RemoteEvent = game.ReplicatedStorage.Events.Chunk
local ChunkHandler = require(game.ReplicatedStorage.Chunk)
local DataHandler = require(game.ReplicatedStorage.Data)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local WorkerM = require(script.RenderWorker)
local RenderWorks = WorkerM.create("Render", 14)
local a = {}
function Render.render(chunk,center,n,e,s,w)
    RenderWorks:DoWork("cull",chunk,center,n,e,s,w)
end


return Render