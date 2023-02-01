local ReplicatedStorage = game:GetService("ReplicatedStorage")
local self = {}
local ResourcePacks = game.ReplicatedStorage.ResourcePacks or Instance.new("Folder",game.ReplicatedStorage)
ResourcePacks.Name = "ResourcePacks"
function self.AddInstanceChildren(Object,AssetObj)
    local Folder = AssetObj
    for i,stuff in Object:GetChildren() do
        if stuff:IsA("Folder") then
            Folder[stuff.Name] = Folder[stuff.Name] or {}
            self.AddInstanceChildren(stuff,Folder[stuff.Name])
        elseif stuff:IsA("ModuleScript") then
            Folder[stuff.Name] = require(stuff)
        else
            Folder[stuff.Name] = stuff
        end
    end
end
function self.LoadPack(PackName:string)
    local pack = ResourcePacks:FindFirstChild(PackName)
    if pack then
        for i,v in pack:GetChildren() do
            if v:IsA("Folder") then
                 self[v.Name] = self[v.Name] or {}
                 self.AddInstanceChildren(v, self[v.Name])
            elseif v:IsA("ModuleScript") and v.Name ~= "Info" then
                self[v.Name] = self[v.Name] or {}
                for i,data in require(v)do
                    self[v.Name][i] = data
                end
            end
        end
        -- local Info
        -- if pack:FindFirstChild("Info") then Info = pack:FindFirstChild("Info") end
        -- if Info then Info.Parent = nil end
        -- pack:ClearAllChildren()
        -- if Info then Info.Parent = pack end
    end
end
function self:Init()
    for i,v in ResourcePacks:GetChildren()do
        self.LoadPack(v.Name)
    end
   -- print(self)
end
function self.GetBlock(Name)
    return self["Blocks"] and self["Blocks"][Name] or nil
end
function self.GetEntity(Name)
    return self["Entities"] and self["Entities"][Name] or nil 
end
function self.GetEntityModelDataFromData(Data)
    local Type,model,ModelId,TextureId = Data.Type,Data.Model,Data.ModelId or 0,Data.TextureId or 0
    if model and self.Models.Entities[model] then
        return self.Models.Entities[model]
    else
        local entity = self.GetEntity(Type)
        return entity
    end
end
return self