local self = {}
local BehaviorPacks = game.ReplicatedStorage.BehaviorPacks or Instance.new("Folder",game.ReplicatedStorage)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ResourcePacks = require(ReplicatedStorage.ResourceHandler) 
local qf = require(game.ReplicatedStorage.QuickFunctions)
BehaviorPacks.Name = "BehaviorPacks"
self.LoadOrder = {
    'LoadOrder','Components','ItemTypes' 
}
function self.AddInstanceChildren(Object,AssetObj)
    local Folder = AssetObj
    for i,stuff in Object:GetChildren() do
        if stuff:IsA("Folder") then
            Folder[stuff.Name] = Folder[stuff.Name] or {}
            self.AddInstanceChildren(stuff,Folder[stuff.Name])
        elseif stuff:IsA("ModuleScript") then
            Folder[stuff.Name] = require(stuff)
            self.AddInstanceChildren(stuff,Folder[stuff.Name])
        else
            Folder[stuff.Name] = stuff
        end
    end
end
function self.LoadPack(PackName:string,loadComponet)
    local pack = BehaviorPacks:FindFirstChild(PackName)
    if pack then
        local function x(v)
            if v:IsA("Folder") then
                self[v.Name] = self[v.Name] or {}
                 self.AddInstanceChildren(v, self[v.Name])
            elseif v:IsA("ModuleScript") and v.Name ~= "Info" then
                self[v.Name] = self[v.Name] or {}
                for i,data in require(v)do
                    self[v.Name][i] = data
                end
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
function self:Init()
    for i,name in self.LoadOrder do
        for i,v in BehaviorPacks:GetChildren()do
            self.LoadPack(v.Name,name)
        end
    end
    for i,v in BehaviorPacks:GetChildren()do
        self.LoadPack(v.Name)
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
    if y and y[x] then
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
function self.CreateComponent(data,table,subtable)
    local t = self.GetComponent(table)
    if subtable and t[subtable] then t= t[subtable] end 
    if not rawget(t,'__index') then
        t.__index = function(self,x)
            return t[x]
        end
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
function self.GetHbFromBlock(Name)
    local b = self.GetBlock(Name)
    if b and b.components and b.components.Hitbox then 
        return type(b.components.Hitbox) == "string" and self.GetBlockHb(b.components.Hitbox) or b.components.Hitbox
    end
end
function self.Getfunction(name)
    return self.Functions and  self.Functions[name]
end
return self