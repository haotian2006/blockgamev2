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

local function CheckKeyLength(Key)
    if not Key then return end 
    if #Key > 50 then
        Key = string.sub(Key, 1,50)
    end
    return Key
end

local function addTo(to,from)
    for i,v in from do
         i = CheckKeyLength(i)
        if to[i] then continue end 
        to[i] = v
    end
end

function ResourceHandler.AddInstanceChildren(Object,AssetObj,depth)
    local Folder = AssetObj
    for i,stuff in Object:GetChildren() do
        local key = CheckKeyLength(stuff.Name)
        if stuff:IsA("Folder") then
            --Folder[stuff.Name].ISFOLDER = true
            Folder[key] = Folder[key] or {}
            ResourceHandler.AddInstanceChildren(stuff,Folder[key],depth+1)
        elseif stuff:IsA("ModuleScript") then
            local data = require(stuff)
            key = data.RealName or key
            if depth <=0 and false then
                addTo(Folder[key] , data)
            else
                Folder[key] = data
            end
        else
            Folder[key] = stuff
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
            local key = CheckKeyLength(v.Name)
            Data[key] = Data[key] or {}
            ResourceHandler.AddInstanceChildren(v, Data[key],0)
        elseif v:IsA("ModuleScript") and v.Name ~= "Info" then
            local key = CheckKeyLength(v.Name)
            Data[key] = Data[key] or {}
            addTo(Data[key] , require(v))

            ResourceHandler.AddInstanceChildren(v, Data[key],0)
            
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

