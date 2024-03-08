local BehaviorHandler = {}
local Data = {
    Containers = {},
    Functions = {},
    Items = {},
    Crafting = {},
    Blocks = {},
    Biomes = {},
    Entities = {},
    BlockCollisionBoxes = {},
    Behaviors = {},
    Foliage = {},
    Ores = {},
    Structures = {},
    Family = {},
    FieldTypes = {}
}

local Blocks = Data.Blocks
local Items = Data.Items
local Families = Data.Family


local BehaviorPacks = game.ReplicatedStorage.BehaviorPacks or Instance.new("Folder",game.ReplicatedStorage)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ResourcePacks = require(ReplicatedStorage.ResourceHandler) 

--Parsers
local parser = require(script.defaultParser)
BehaviorPacks.Name = "BehaviorPacks"

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

local function FormatTable(x,p)
    p = p or {}
    for i,v in x do
        if type(v) == "table" and v.NameSpace then
            i = CheckKeyLength(v.NameSpace)
        end
        p[i] = v
    end 
    return p
end
local function AddInstanceChildren(Object,Folder,depth)
    for i,stuff in Object:GetChildren() do
        local Key = CheckKeyLength(stuff.Name)
        if stuff:IsA("Folder") then
            Folder[Key] = Folder[Key] or {}
           -- Folder[stuff.Name].ISFOLDER = true
            AddInstanceChildren(stuff,Folder[Key],depth+1)
        elseif stuff:IsA("ModuleScript") then
            local data = require(stuff)
            local key = (type(data) == "table" and CheckKeyLength(data.NameSpace)) or Key
            Folder[key] = Folder[key] or {}
            local touse =  type(data) =="table" and FormatTable(data) or data

            if depth <=0 and false then
                addTo(Folder[key] , touse)
            else
                Folder[key] = touse
            end
            AddInstanceChildren(stuff,Folder[key],depth+1)
        else
            Folder[Key] = stuff
        end
    end
end
local function loop(v)
    local Key = CheckKeyLength(v.Name)
    if v:IsA("Folder") then
        Data[Key] = Data[Key] or {}
        Data[Key].ISFOLDER = true
        AddInstanceChildren(v, Data[Key],0)
    elseif v:IsA("ModuleScript") and Key ~= "Info" then
        Data[v.Name] = Data[v.Name] or {}
        local data = require(v)
        addTo(Data[Key], type(data) =="table" and FormatTable(data) or data)
        AddInstanceChildren(v, Data[Key],0)
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
    parser(Blocks,Families)
    parser(Items,Families)
    print(Data.Entities)
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

function BehaviorHandler.getBlock (name,id)
    local blockData = Blocks[name]
    if not blockData then 
        return 
    end 
    if blockData.__NoDefault then
        return blockData
    end
    
    if not id or id == 0 then
        return  blockData.Default
    end

    return blockData[(id and id or "1")] or blockData.Default
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

function BehaviorHandler.getFamily(name)
    return Families[name]
end
return table.freeze(BehaviorHandler)