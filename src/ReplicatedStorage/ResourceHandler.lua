local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Data = {
    Animations = {},
    Items = {},
    Ui = {},
    Assets = {},
    Containers = {},
    Crafting = {},
    Blocks = {},
    Entities = {},
    EntityModels = {}
}

local ResourceHandler = {}
local ResourcePacks = game.ReplicatedStorage.ResourcePacks or Instance.new("Folder",game.ReplicatedStorage)
ResourcePacks.Name = "ResourcePacks"

local function addTo(to,from)
    for i,v in from do
        if to[i] then continue end 
        to[i] = v
    end
end

function ResourceHandler.AddInstanceChildren(Object,AssetObj,depth)
    local Folder = AssetObj
    for i,stuff in Object:GetChildren() do
        Folder[stuff.Name] = Folder[stuff.Name] or {}
        if stuff:IsA("Folder") then
            --Folder[stuff.Name].ISFOLDER = true
            ResourceHandler.AddInstanceChildren(stuff,Folder[stuff.Name],depth+1)
        elseif stuff:IsA("ModuleScript") then
            if depth <=0 then
                addTo(Folder[stuff.Name] , require(stuff))
            else
                Folder[stuff.Name] = require(stuff)
            end
        else
            Folder[stuff.Name] = stuff
        end
    end
end 
function ResourceHandler.loadComponet(Componet) 
    for i,v in ResourcePacks:GetChildren()do
        ResourceHandler.LoadPack(v.Name,Componet)
    end
end
function ResourceHandler.LoadPack(PackName:string,loadComponet)
    local pack = ResourcePacks:FindFirstChild(PackName)
    if not pack then return end 
    local function x(v)
        if v:IsA("Folder") then
            Data[v.Name] = Data[v.Name] or {}
            ResourceHandler.AddInstanceChildren(v, Data[v.Name],0)
        elseif v:IsA("ModuleScript") and v.Name ~= "Info" then
            Data[v.Name] = Data[v.Name] or {}
            addTo(Data[v.Name] , require(v))

            ResourceHandler.AddInstanceChildren(v, Data[v.Name],0)
            
        end
    end
    if loadComponet then
        if pack:FindFirstChild(loadComponet) then
            x(pack:FindFirstChild(loadComponet))
        end
        return
    end
    for i,v in pack:GetChildren() do
        x(v)
    end 
    
end
local init = false
function ResourceHandler.Init()
    if init then return end 
    init = true
    for i,v in ResourcePacks:GetChildren()do
        ResourceHandler.LoadPack(v.Name)
    end
end

function ResourceHandler.getAsset(id)
    return Data.Assets and Data.Assets[id]
end
function ResourceHandler.getBlock(Name)
    return Data["Blocks"] and Data["Blocks"][Name] or nil
end

function ResourceHandler.getAllBlocks()
    return Data["Blocks"]
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
function ResourceHandler.getAllData()
    return Data
end
return table.freeze(ResourceHandler)

