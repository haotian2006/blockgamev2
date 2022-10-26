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
    data.LoadedChunks[cx] = data.LoadedChunks[cx] or {}
    data.LoadedChunks[cx][cz] = ChunkObj.new(cx,cz,data)
end
if runservice:IsClient() then return data end
--<server functions

return data