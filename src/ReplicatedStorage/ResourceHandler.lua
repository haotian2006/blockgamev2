local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Data = {}
local ResourceHandler = {}
local ResourcePacks = game.ReplicatedStorage.ResourcePacks or Instance.new("Folder",game.ReplicatedStorage)
ResourcePacks.Name = "ResourcePacks"
function ResourceHandler.AddInstanceChildren(Object,AssetObj)
    local Folder = AssetObj
    for i,stuff in Object:GetChildren() do
        if stuff:IsA("Folder") then
            Folder[stuff.Name] = Folder[stuff.Name] or {}
            ResourceHandler.AddInstanceChildren(stuff,Folder[stuff.Name])
        elseif stuff:IsA("ModuleScript") then
            Folder[stuff.Name] = require(stuff)
        else
            Folder[stuff.Name] = stuff
        end
    end
end 
function ResourceHandler.LoadPack(PackName:string)
    local pack = ResourcePacks:FindFirstChild(PackName)
    if not pack then return end 
    for _,v in pack:GetChildren() do
        if v:IsA("Folder") then
            Data[v.Name] = Data[v.Name] or {}
                ResourceHandler.AddInstanceChildren(v, Data[v.Name])
        elseif v:IsA("ModuleScript") and v.Name ~= "Info" then
            Data[v.Name] = Data[v.Name] or {}
            for i,data in require(v)do
                Data[v.Name][i] = data
            end
            ResourceHandler.AddInstanceChildren(v, Data[v.Name])
        end
    end
end
function ResourceHandler.Init()
    for i,v in ResourcePacks:GetChildren()do
        ResourceHandler.LoadPack(v.Name)
    end
    print(Data)
end

function ResourceHandler.getAsset(id)
    return Data.Assets and Data.Assets[id]
end
function ResourceHandler.getBlock(Name)
    return Data["Blocks"] and Data["Blocks"][Name] or nil
end
function ResourceHandler.getEntity(Name)
    return Data["Entities"] and Data["Entities"][Name] or nil 
end
function ResourceHandler.getItem(name)
    return Data.Items and Data.Items[name]
end
function ResourceHandler.getUiContainer(name)
    if Data.Containers then
        return Data.Containers[name]
    end
end
function ResourceHandler.getUI(name)
    return Data.Ui and Data.Ui[name]
end

function ResourceHandler.getAnimationFromName(name)
    return Data.Animations[name] or Data.AnimationFolder[name] or nil
end
function ResourceHandler.getEntityModel(name)
    return (Data.EntityModels or {})[name]
end

return table.freeze(ResourceHandler)

