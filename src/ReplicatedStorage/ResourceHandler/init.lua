local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local defaultParse = require(script.defaultParser)
local BlockParse = require(script.Block)
local BTexture = require(script.BlockTexture)
local Other = require(script.Other)
local ItemParser = require(script.Item)

local Data = {
    Animations = {},
    Items = {},
    Ui = {},
    Assets = {},
    Containers = {},
    Crafting = {},
    Blocks = {},
    Entities = {},
    EntityModels = {},
    Family = {}
}

local Blocks = Data.Blocks
local Items = Data.Items

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

    Other.init(Data)
    BTexture.init(Blocks)
    BlockParse.init(Blocks)
    ItemParser.Init(Data.Items,Data.Family)
end

function ResourceHandler.getAsset(id)
    return Data.Assets and Data.Assets[id]
end
function ResourceHandler.getBlock(Name)
    return Data["Blocks"] and Data["Blocks"][Name] or nil
end

function ResourceHandler.getBlockData(name,id)
    local blockData = Blocks[name]
    if not blockData then 
        return 
    end 
    if blockData.__NoDefault then
        return blockData
    end
    
    -- if biome and blockData[biome] then
    --     return blockData[biome]
    -- end
    if not id or id == 0 then
        return  blockData.Default
    end

    return blockData[(id and id or "1")] or blockData.Default
end

function ResourceHandler.getAllBlocks()
    return Data["Blocks"]
end

function ResourceHandler.getEntity(Name)
    return Data["Entities"] and Data["Entities"][Name] or nil 
end
function ResourceHandler.getItem(name,id)
    local itemData = Items[name]
    if not itemData then 
        return 
    end 
    if itemData.__NoDefault then
        return itemData
    end
    
    -- if biome and blockData[biome] then
    --     return blockData[biome]
    -- end
    if not id or id == 0 then
        return  itemData.Default
    end

    return itemData[(id and id or "1")] or itemData.Default
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

function ResourceHandler.getFamily(name)
    return Data.Family[name]
end

function ResourceHandler.getAllData()
    return Data
end

return table.freeze(ResourceHandler)

