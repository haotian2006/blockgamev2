local debris = {items = {},Running = {}}
local Item = {}
Item.__index = Item
debris.__index = debris
local debrisFolder = game.ReplicatedStorage:FindFirstChild("DebrisFolder") or Instance.new('Folder',game.ReplicatedStorage)
local safe = pcall(function()
    debrisFolder.Name = "DebrisFolder"
end)
debris.Safe = safe
function Item.newItem(data)
    local self = setmetatable({},Item)
end
function Item:Destroy()
    
end

function debris:AddItem(name,data,duration)
    if data == nil then return end 
    self.items[name] = {data,os.clock()+(duration or 0)}
end
function debris:Remove(name)
    self.items[name] = nil
end
function debris:GetItem(name)
    return self.Folder:FindFirstChild(name)
end
function debris:GetItemData(name)
    return self.items[name] and self.items[name][1]
end
function debris:SetTime(name,duration)
    if not self.items[name] then return end 
    self.items[name][2] = os.clock()+(duration or 0)
end
function debris:Update()
    for i,v in self.items do
        if v[2] -os.clock() <=0 then
            self:Remove(i)
        end
    end
end
function debris.GetFolder(name)
    local self = setmetatable({},debris)
    local folder = debrisFolder:FindFirstChild(name)
    if safe and not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = debrisFolder
    end
    if not debrisFolder:FindFirstChild(name) then return end 
    self.Folder = folder 
    return self
end
function debris.RemoveFolder(name)
    debris.Running[name] = nil
end
if safe then 
game:GetService('RunService').Heartbeat:Connect(function(deltaTime)
    for i,v in debris.Running do
        v:Update()
    end
end)
end
return debris