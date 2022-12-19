local ReplicatedStorage = game:GetService("ReplicatedStorage")
local self = {}
local ResourcePacks = game.ReplicatedStorage.ResourcePacks or Instance.new("Folder",game.ReplicatedStorage)
ResourcePacks.Name = "ResourcePacks"
local Assets = game.ReplicatedStorage.Assets
function self.AddInstanceChildren(Object,AssetObj)
    local Folder = AssetObj
    for i,stuff in Object:GetChildren() do
        if stuff:IsA("Folder") then
            local items = Folder:FindFirstChild(stuff.Name) or Instance.new("Folder",Folder)
            items.Name =stuff.Name
            self.AddInstanceChildren(stuff,items)
        else
            if Folder:FindFirstChild(stuff.Name) then  Folder:FindFirstChild(stuff.Name):Destroy() end
            stuff.Parent = AssetObj
        end
    end
end
function self.LoadPack(PackName:string)
    local pack = ResourcePacks:FindFirstChild(PackName)
    if pack then
        for i,v in pack:GetChildren() do
            if v:IsA("Folder") then
                local Folder = Assets:FindFirstChild(v.Name) or Instance.new("Folder",Assets)
                Folder.Name = v.Name
                self.AddInstanceChildren(v,Folder)
            elseif v:IsA("ModuleScript") and v.Name ~= "Info" then
                self[v.Name] = self[v.Name] or {}
                for i,data in require(v)do
                    self[v.Name][i] = data
                end
            end
        end
        local Info
        if pack:FindFirstChild("Info") then Info = pack:FindFirstChild("Info") end
        if Info then Info.Parent = nil end
        pack:ClearAllChildren()
        if Info then Info.Parent = pack end
    end
end
function self:Init()
    for i,v in ResourcePacks:GetChildren()do
        self.LoadPack(v.Name)
    end
end
function self.GetBlock(Name)
    return self["Blocks"] and self["Blocks"][Name] or nil
end
function self.GetEntity(Name)
    return self["Entities"] and self["Entities"][Name] or nil 
end
return self