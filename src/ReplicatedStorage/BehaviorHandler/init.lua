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


--Parsers
local parser = require(script.defaultParser)
local familyParser = require(script.parseFamily)
BehaviorPacks.Name = "BehaviorPacks"

local function CheckKeyLength(Key)
    if type(Key) ~= "string" then return Key end 
    Key = Key
    if #Key > 50 then
        Key = string.sub(Key, 1,50)
    end
    return Key
end


local function addTo(to,from)
    if type(from) ~= "table" then
        return false
    end
    for i,v in from do
        local Alias = type(v) == "table" and v.Alias
        i = CheckKeyLength(Alias or i)
        if to[i] then continue end 
        to[i] = v
    end
    return true
end


local function ParseChildren(Object,MainModule)
    for i,stuff in Object:GetChildren() do
        local Key = CheckKeyLength(stuff.Name)
        if stuff:IsA("Folder") then
            ParseChildren(stuff,MainModule)
        elseif stuff:IsA("ModuleScript") then
            local data = require(stuff)
            local key = (type(data) == "table" and CheckKeyLength(data.Alias)) or Key
            MainModule[key] = MainModule[key] or data

        else
            MainModule[Key] = stuff
        end
    end
end
local function LoadComponent(v)
    local Key = CheckKeyLength(v.Name)
    if v:IsA("Folder") then
        Data[Key] = Data[Key] or {}
        ParseChildren(v, Data[Key])
    elseif v:IsA("ModuleScript") and Key ~= "Info" then
        Data[Key] = Data[Key] or {}
        local data = require(v)
        addTo(Data[Key], data)
        ParseChildren(v, Data[Key])
    end
end

function BehaviorHandler.LoadPack(PackName:string,loadComponent)
    local pack = BehaviorPacks:FindFirstChild(PackName)
    if pack then
        if loadComponent then
            if pack:FindFirstChild(loadComponent) then
                LoadComponent(pack:FindFirstChild(loadComponent))
            end
            return
        end
        for i,v in pack:GetChildren() do
            LoadComponent(v)
        end 
    end
end
local Init = false
function BehaviorHandler.loadComponent(Component) 
    for i,v in BehaviorPacks:GetChildren()do
        BehaviorHandler.LoadPack(v.Name,Component)
    end
end
function BehaviorHandler.Init() 
    if Init then return end 
    for i,v in BehaviorPacks:GetChildren()do
        BehaviorHandler.LoadPack(v.Name)
    end
    familyParser(Families)
    parser(Blocks,Families)
    parser(Items,Families)
    --print(BehaviorHandler.isFamily(Blocks["c:grassBlock"], "item_block"))
    Init = true
    return BehaviorHandler 
end

function BehaviorHandler.isFamily(t,family)
    if t.__Family then 
        return t.__Family[family]
    end
    return false
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


function BehaviorHandler.getBlock (name)
    return Blocks[name]
end

function BehaviorHandler.getBlockInfo (name,id)
    local blockData = Blocks[name]
    if not blockData then 
        return 
    end 
    
    if not id or id == 0 then
        return  blockData.default
    end

    return blockData[(id and id or "default")] or blockData.default
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