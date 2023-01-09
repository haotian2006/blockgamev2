local deb = {}
local highlight = Instance.new("Highlight",workspace.Part)
function deb.HighLightEntity(id,remove)
    local e =game.Workspace.Entities:FindFirstChild(id)
    if e then
        highlight.Adornee = e
    end
    if remove then
        task.delay(remove,function()
            highlight.Adornee = nil
        end)
    end
end
local a = workspace.IDK a.Size = Vector3.new(3,3,3) a.Anchored = true
function deb.HighLightBlock(x,y,z)
    a.Position = Vector3.new(x,y,z)*3
end
local b = workspace.IDK:Clone()
b:ClearAllChildren()
function deb.HighLightMutiBlocks(positions,remove)
    local model = Instance.new("Model",workspace.HighLightStuff)
    remove = remove or 3
    for i,v in positions do
        local a = b:Clone()
        a.Parent = model
        a.Position = v*3
    end
    if remove then
        task.delay(remove,function()
            model:Destroy()
        end)
    end
end
return deb