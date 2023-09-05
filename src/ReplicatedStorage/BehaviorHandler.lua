local self = {}
local BehaviorPacks = game.ReplicatedStorage.BehaviorPacks or Instance.new("Folder",game.ReplicatedStorage)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ResourcePacks = require(ReplicatedStorage.ResourceHandler) 
local qf = require(game.ReplicatedStorage.QuickFunctions)
BehaviorPacks.Name = "BehaviorPacks"
local STR = game:GetService("SharedTableRegistry")
self.LoadOrder = {
    'LoadOrder','Components','ItemTypes' 
}
self.Shared = {
    --'WorldGeneration' 
}
self.SPECIALLOAD = {
    'WorldGeneration'
}
function self.GetOrCreated(name)
    if not table.find(self.Shared,name)  then
        return self[name] or {}
    end
    if STR:GetSharedTable(name) then
        return STR:GetSharedTable(name)
    else
        print(name)
        local t = SharedTable.new()
        STR:SetSharedTable(name,t)
        return t
    end
end
function self.FormatTable(x,p)
    local p = p or {}
    for i,v in x do
        if type(v) == "table" and v.NameSpace then
            i = v.NameSpace
        end
        p[i] = v
    end
    return p
end
function self.AddInstanceChildren(Object,AssetObj)
    local Folder = AssetObj
    for i,stuff in Object:GetChildren() do
        if stuff:IsA("Folder") then
            Folder[stuff.Name] = Folder[stuff.Name] or {}
            Folder[stuff.Name].ISFOLDER = true
            self.AddInstanceChildren(stuff,Folder[stuff.Name])
        elseif stuff:IsA("ModuleScript") then
            local data = require(stuff)
            Folder[(type(data) == "table" and data.NameSpace) or stuff.Name] = type(data) =="table" and self.FormatTable(data) or data
            self.AddInstanceChildren(stuff,Folder[stuff.Name])
        else
            Folder[stuff.Name] = stuff
        end
    end
end
local Scripts = {
    [true] ={},
    [false] = {}
}
function self.LoadPack(PackName:string,loadComponet,SPECIAL)
    local pack = BehaviorPacks:FindFirstChild(PackName)
    if pack then
        local function x(v)
            if not table.find(self.SPECIALLOAD,v.Name) and SPECIAL then
                return 
            end
            if v:IsA("Folder") then
                self[v.Name] = self.GetOrCreated(v.Name)
                self[v.Name].ISFOLDER = true
                 self.AddInstanceChildren(v, self[v.Name])
            elseif v:IsA("ModuleScript") and v.Name ~= "Info" then
                if (v.Name == "Server" and RunService:IsServer()) or (v.Name == "Client" and RunService:IsClient()) then
                    table.insert(Scripts[RunService:IsServer()],v)
                    return
                end
                self[v.Name] = self.GetOrCreated(v.Name)
                local data = require(v)
                self[v.Name] = type(data) =="table" and self.FormatTable(data) or data
                self.AddInstanceChildren(v, self[v.Name])
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
end
function self:Init(SPECIAL) 
    for i,name in self.LoadOrder do
        for i,v in BehaviorPacks:GetChildren()do
            self.LoadPack(v.Name,name,SPECIAL)
        end
    end
    for i,v in BehaviorPacks:GetChildren()do
        self.LoadPack(v.Name,nil,SPECIAL)
    end
    if SPECIAL then return end 
    for ii,v in Scripts do
        for i,s in v do
            if ii == RunService:IsServer() then
                local m = require(s)
                if m.Init then
                    m:Init()
                end
            end
        end
    end
    --print(self)
    return self 
end
function self.GetItemData(name)
    if not self.Items then return end
    return self.Items[name]
end
local ItemType = {
    maxCount = 64
}
function ItemType.__index(s,x)
    local y = self.GetItemType(rawget(s,'type'))
    if y and y[x] ~= nil then
        return y[x]
    end
    return rawget(ItemType,x)
end
function ItemType:IsA(type)
    return self.type and ((type(self.type) == 'table' and table.find(self.type,type)) or self.type == type )
end 
function self.CreateItemType(data)
    return setmetatable(data,ItemType)
end
function self.GetItemType(name)
    if not self.ItemTypes then return end
    return self.ItemTypes[name]
end
function self.CreateComponent(data,Parent,subtable)
    local t = self.GetComponent(Parent)
    if subtable and t[subtable] then t= t[subtable] end 
    if not rawget(t,'__index') then
        t.__index = t
    end
    return setmetatable(data,t)
end
function self.GetComponent(name)
    if not self.Components then return end
    return self.Components[name]
end
function self.GetBehavior(name)
    if not self.Behaviors then return end
    return self.Behaviors[name]
end
function self.GetEntity(Name)
    if not self.Entities then return end 
    return self.Entities[Name]
end
function self.GetItem(name)
    if not self.Items then return end
    return self.Items[name]
end
function self.GetBCFD(Name,C)--GetBlockComponetsFromData
    return self.Blocks[Name] and self.Blocks[Name][C or "components"]
end
function self.GetBlockHb(Name)
    return self.BlockHitboxes[Name]
end
function self.GetBlock(Name)
    return self.Blocks[Name]
end
function self.Getfunction(name)
    return self.Functions and  self.Functions[name]
end
function self.GetWorldGeneration(path)
    local gen = self.WorldGeneration or {}
    return gen[path]
end
function self.GetBiome(path)
    local gen = self.Biomes or {}
    return gen[path]
end
return self