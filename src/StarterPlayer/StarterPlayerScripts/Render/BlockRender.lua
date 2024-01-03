local render = {}
local Texture = require(script.Parent.BlockTexture)
local Block = require(game.ReplicatedStorage.Block)
local RotationUtils = require(game.ReplicatedStorage.Utils.RotationUtils)
local storage = require(script.Parent.RenderStorage)

local Chunks = {}
render.Destroyed = {}

function render.render(chunk,meshed,override)
    if render.Destroyed[chunk] then return end 
    local chunkData = {}
    local hasChunk = false
    local generate = true
    override:Connect(function()
        generate = false
    end)
    if Chunks[chunk] then
        chunkData = Chunks[chunk] 
        hasChunk = true
    else
        chunkData = {} 
        Chunks[chunk] = chunkData
    end
    
    local model = Instance.new("Model")
    model.Name = `{chunk.X},{chunk.Z}`
    local  m =  workspace.Chunks:FindFirstChild( model.Name) 
    local removed = {}
    local cOfx = chunk*8
    local times = 0
    for key,data in meshed do
        times +=1
        if not generate then break end 
        local blockID,rot,id = Block.decompressCache(data.data.X)
        local partName = `{tostring(data.data)}|{tostring(data.size)}|{tostring(data.midPoint)}`
        if chunkData[partName] then 
            removed[partName] = true 
            continue 
        end 
        rot = RotationUtils.indexPairs[rot]
        local walls = data.data.Y
        local BlockName = Block.getBlock(blockID)
        local p,textures = Texture.CreateBlock(BlockName,walls)
        p.Size = data.size*3
        p.Position = (data.midPoint+cOfx)*3
        p.Parent = hasChunk and m or  model
        chunkData[partName] = {p,textures}
        removed[partName] = true 
    end
    if not generate then return end 
    for i,v in chunkData do
        if removed[i] then continue end 
        chunkData[i] = nil
        for _,t in v[2] do
            storage.sendTextureBackToQueue(t)
        end
        storage.sendBlockBackToQueue( v[1])
    end
    if not hasChunk then
        model.Parent = workspace.Chunks
    end
end
function render.deload(chunk)
    render.Destroyed[chunk] = true
    local cData = Chunks[chunk]
    if not cData then return end 
    Chunks[chunk] = nil
    local m = workspace.Chunks:FindFirstChild(`{chunk.X},{chunk.Z}`) 
    m.Parent = script
    for i,v in cData do
        for _,t in v[2] do
            storage.sendTextureBackToQueue(t)
        end
        storage.sendBlockBackToQueue(v[1])
    end
    m:Destroy()
    
end
function render.renderOLD(chunk,meshed)
    local model = Instance.new("Model")
    model.Name = `{chunk.X},{chunk.Z}`
    local  m =  workspace.Chunks:FindFirstChild( model.Name) 
    local parts = {}
    if m then
        for i,v in m:GetChildren() do
            parts[v.Name] = v
        end
    end
    local i = 0
    for key,data in meshed do
        i+=1
        -- if i%10 == 0 then 

        --     task.wait() 
        -- end
        local blockID,rot,id = Block.decompressCache(data.data.X)
        local partName = `{tostring(data.data)}|{tostring(data.size)}|{tostring(data.midPoint)}`
        if parts[partName] then 
            parts[partName] = nil 
            continue 
        end 
        rot = RotationUtils.indexPairs[rot]
        local walls = data.data.Y
        local BlockName = Block.getBlock(blockID)
        local p = Texture.CreateBlock(BlockName,walls)
        p.Name = partName
        p.Size = data.size*3
        --p.Color = color[data.data]
        p.Position = (data.midPoint+chunk*8)*3
        p.Anchored = true
        p.Massless = true
        p.Parent = m or  model
    end
    for i,v in parts do
        v:Destroy()
    end
    if not m then
        model.Parent = workspace.Chunks
    end
end
return render