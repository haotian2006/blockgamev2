local qf = require(game.ReplicatedStorage.QuickFunctions)
local data = {}
--<Both
data.LoadedChunks = {}
data.LoadedEntitys = {}
--<Client Only
data.LocalPlayer = {}
--<Server Only
data.CompressedChunks = {}
data.Players = {}

local multihandeler = require(game.ReplicatedStorage.MultiHandler)
local runservice = game:GetService("RunService")
local ChunkObj = require(game.ReplicatedStorage.Chunk)
local compresser = require(game.ReplicatedStorage.compressor)
function data.GetChunk(cx,cz)
    return data.LoadedChunks[qf.cv2type("string",cx,cz)] 
end
function data.CreateChunk(cdata,cx,cz)
    data.LoadedChunks[qf.cv2type("string",cx,cz)] = ChunkObj.new(cx,cz,cdata)
    return data.LoadedChunks[qf.cv2type("string",cx,cz)] 
end
if runservice:IsClient() then return data end
--<server functions
game.ReplicatedStorage.Events.GetChunk.OnServerEvent:Connect(function(player,cx,cz)
   -- local position = player.Character.PrimaryPart.Position
    if not data.GetChunk(cx,cz) then
        local new = data.CreateChunk(nil,cx,cz)
        new:Generate()
    end
    --print("e")
   game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,data.GetChunk(cx,cz):GetBlocks() )
    -- game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,compresser.compresslargetable(data.GetChunk(cx,cz):GetBlocks(),6) )
end)
return data