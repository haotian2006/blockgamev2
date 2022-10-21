local data = {}
--<Both
data.LoadedChunks = {}
data.LoadedEntitys = {}
--<Client Only
data.LocalPlayer = {}
--<Server Only
data.CompressedChunks = {}
data.Entitys = {}
data.Players = {}

local runservice = game:GetService("RunService")
local ChunkObj = require(game.ReplicatedStorage.Chunk)
function data.GetChunk(cx,cz)
    return data.LoadedChunks[cx] and data.LoadedChunks[cx][cz] 
end
function data.CreateChunk(data,cx,cz)
    
end
if runservice:IsClient() then return data end
--server functions

return data