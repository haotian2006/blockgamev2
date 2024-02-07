local BehaviorHandler = {}
local Data = {
    Containers = {},
    Functions = {},
    Items = {},
    Crafting = {},
    Blocks = {},
    Biomes = {},
    Entities = {},
    BlockCollisionBoxes = {}
}
local BehaviorPacks = game.ReplicatedStorage.BehaviorPacks or Instance.new("Folder",game.ReplicatedStorage)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ResourcePacks = require(ReplicatedStorage.ResourceHandler) 

BehaviorPacks.Name = "BehaviorPacks"


local function FormatTable(x,p)
    local p = p or {}
    for i,v in x do
        if type(v) == "table" and v.NameSpace then
            i = v.NameSpace
        end
        p[i] = v
    end 
    return p
end
local function AddInstanceChildren(Object,Folder)
    for i,stuff in Object:GetChildren() do
        if stuff:IsA("Folder") then
            Folder[stuff.Name] = Folder[stuff.Name] or {}
            Folder[stuff.Name].ISFOLDER = true
            AddInstanceChildren(stuff,Folder[stuff.Name])
        elseif stuff:IsA("ModuleScript") then
            local data = require(stuff)
            Folder[(type(data) == "table" and data.NameSpace) or stuff.Name] = type(data) =="table" and FormatTable(data) or data
            AddInstanceChildren(stuff,Folder[stuff.Name])
        else
            Folder[stuff.Name] = stuff
        end
    end
end
local function loop(v)
    if v:IsA("Folder") then
        Data[v.Name] = Data[v.Name] or {}
        Data[v.Name].ISFOLDER = true
        AddInstanceChildren(v, Data[v.Name])
    elseif v:IsA("ModuleScript") and v.Name ~= "Info" then
        Data[v.Name] = Data[v.Name] or {}
        local data = require(v)
        Data[v.Name] = type(data) =="table" and FormatTable(data) or data
        AddInstanceChildren(v, Data[v.Name])
    end
end
function BehaviorHandler.LoadPack(PackName:string,loadComponet)
    local pack = BehaviorPacks:FindFirstChild(PackName)
    if pack then
        if loadComponet then
            if pack:FindFirstChild(loadComponet) then
                loop(pack:FindFirstChild(loadComponet))
            end
            return
        end
        for i,v in pack:GetChildren() do
            loop(v)
        end 
    end
end
local Init = false
function BehaviorHandler.loadComponet(Componet) 
    for i,v in BehaviorPacks:GetChildren()do
        BehaviorHandler.LoadPack(v.Name,Componet)
    end
end
function BehaviorHandler.Init() 
    if Init then return end 
    for i,v in BehaviorPacks:GetChildren()do
        BehaviorHandler.LoadPack(v.Name)
    end
    Init = true
    return BehaviorHandler 
end

--//getters
function BehaviorHandler.getItemData(name)
    if not Data.Items then return end
    return Data.Items[name]
end

function BehaviorHandler.getEntityBehavior(name)
    if not Data.Behaviors then return end
    return Data.Behaviors[name]
end
function BehaviorHandler.getEntity(Name)
    if not Data.Entities then return end 
    return Data.Entities[Name]
end
function BehaviorHandler.getItem(name)
    if not Data.Items then return end
    return Data.Items[name]
end
function BehaviorHandler.getBlock(Name)
    if not Data.Blocks then return end
    return Data.Blocks[Name]
end
function BehaviorHandler.getBlockCollisionBox(Name)
    if not Data.BlockCollisionBoxes then return end
    return Data.BlockCollisionBoxes[Name]
end
function BehaviorHandler.getfunction(name)
    return Data.Functions and  Data.Functions[name]
end
function BehaviorHandler.getBiome(path)
    local gen = Data.Biomes or {}
    return gen[path]
end
function BehaviorHandler.getContainer(type)
    return Data.Containers[type]
end
function BehaviorHandler.getAllData()
    return Data
end
return table.freeze(BehaviorHandler)