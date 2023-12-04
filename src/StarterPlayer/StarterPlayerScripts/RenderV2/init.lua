local Render = {}
local Remote:RemoteEvent = game.ReplicatedStorage.Events.ChunkV2
local ChunkHandler = require(game.ReplicatedStorage.ChunkV2)
local DataHandler = require(game.ReplicatedStorage.Data)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)

function Render.render(cx,cz,blocks)
    local model = Instance.new("Model")
    model.Name = "3213131213321"
    for i,v in blocks do
        if v then
            local loc = IndexUtils.to3D[i]
            local p = Instance.new("Part",model)
            p.Size = Vector3.new(3,3,3)
            p.Position = loc*3
            p.Anchored = true
        end
    end
    model.Parent = workspace
end
function Render.Init()
    Remote.OnClientEvent:Connect(function(x,z,Data)  
        local new = ChunkHandler.new(x, z,Data)
        DataHandler.insertChunk(x, z, new)
        Render.render(x,z,Data)
    end)
    Remote:FireServer(0,0)
end

return Render