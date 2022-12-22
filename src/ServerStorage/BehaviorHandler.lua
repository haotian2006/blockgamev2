local self = {}
local BehaviorPacks = game.ServerStorage.BehaviorPacks or Instance.new("Folder",game.ServerStorage)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ResourcePacks = require(ReplicatedStorage.ResourceHandler) 
BehaviorPacks.Name = "BehaviorPacks"
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
    local pack = BehaviorPacks:FindFirstChild(PackName)
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
    end
end
function self:Init()
    for i,v in BehaviorPacks:GetChildren()do
        self.LoadPack(v.Name)
    end
    print(self)
end
function self.GetBehavior(name)
    if not self.Behaviors then return end
    return self.Behaviors[name]
end
function self.GetEntity(Name)
    if not self.Entities then return end 
    return self.Entities[Name]
end
return self