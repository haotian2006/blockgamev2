local debris = {items = {},Running = {}}
debris.__index = debris
local debrisFolder = game.ReplicatedStorage:FindFirstChild("DebrisFolder") or Instance.new('Folder',game.ReplicatedStorage)
local safe = pcall(function()
    debrisFolder.Name = "DebrisFolder"
end)
function debris:AddItem(name,data,duration)
    if data == nil then return end 
    self.items[name] = {data,os.clock()+(duration or 0)}
end
function debris:Remove(name)
    self.items[name] = nil
    if self.__remove then
        self.__remove(name)
    end
end
function debris:GetItem(name)
    return self.items[name] 
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
function debris.CreateFolder(name,NoAdd)
    local self = setmetatable({items = {}},debris)
    if not NoAdd then 
        debris.Running[name] = self
    end
    return self
end
function debris.RemoveFolder(name)
    debris.Running[name] = nil
end
function debris.Init()
    game:GetService('RunService').Heartbeat:Connect(function(deltaTime)
        for i,v in debris.Running do
            v:Update()
        end
    end)
    return debris
end
return debris