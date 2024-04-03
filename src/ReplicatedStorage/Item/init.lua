local Item = {}
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local Synchronizer = require(game.ReplicatedStorage.Synchronizer)

local Items = BehaviorHandler.getAllData().Items

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()

local ItemsIndex = {}
local ItemKeys = {}

local function update(types)
    local t = ItemsIndex 
    for i,v in types or {} do
        if t[i] then continue end 
        t[i] = v
    end
end
function Item.getTables()
    return ItemsIndex,ItemKeys
end


function Item.getNameFromIndex(idx)
    return ItemsIndex[idx]
end

function Item.getIndexFromName(Name)
    return ItemKeys[Name]
end

function Item.getName(item)
    return Item.getNameFromIndex(item[1])
end

function Item.new(Name,Id)
    if type(Name) == "string" then
        local n = Name
        Name = Item.getIndexFromName(Name)
        if not Name then
            warn(`Item Name: {n} Was Not Found`)
            return {0,Id or 0}
        end
    end
    return {Name,Id or 0}
end

function Item.getItemInfoR(self)
    local Name = Item.getName(self)
    local data = ResourceHandler.getItem(Name,self[2])
    if not data then
        return {
            Name = Name,
            DisplayName = "No Data Found",
            Id = self[2],
            Icon = "",
            AllData = {},
            Texture = "",
            Mesh = Instance.new("Part")
        }
    end
    if type(data.Texture) == 'function' then
        data.Texture = data.Texture(self)
    end
    if type(data.Icon) == 'function' then
        data.Icon = data.Icon(self)
    end
    return {
        Name = Name,
        DisplayName = data.DisplayName or string.match(Name, "%a:(%w+)"),
        Id = self[2],
        Icon = data.Icon,
        Texture = data.Texture,
        Mesh = data.Mesh,
        RenderHand = data.RenderHand,
        AllData = data
    }
end

local function CreateTexture(texture,face) 
 
    local new = Instance.new("Decal")
    new.Texture = type(texture) == "string" and texture or texture.Texture
    new.Face = face
    return new
end 

local sides = {Right = true,Left = true,Top = true,Bottom = true,Back = true,Front =true}

function Item.createItemModel(Item_)
    local itemData = Item.getItemInfoR(Item_)
    if not itemData  then return end 
    local stuff = {}
    local texture = itemData.Texture
    local mesh = itemData.Mesh 
    if not mesh then return end 
    mesh = mesh:Clone()
    if not texture then return mesh,itemData end 
    if type(texture) == "function" then
        texture = texture(Item_)
    end
    if mesh:IsA("MeshPart") and type(texture) == "string" then 
        (mesh::MeshPart).TextureID = texture
        return mesh
    end
    if type(texture) == "table" then
        for i,v in texture do
            table.insert(stuff,CreateTexture(v,i))
        end
    elseif type(texture) == "userdata" or type(texture) == "string" then
        for v in sides do
            table.insert(stuff,CreateTexture(texture,v))
        end
    end
    for i,v in stuff do
        v.Parent = mesh
    end
    return mesh,itemData
end


function Item.tostring(item)
    return `{item[1]}-{item[2] or 0}`
end

function Item.equals(x,y,Id:number?)
    if type(y) == "string" then
        y = Item.getIndexFromName(y)
    end
    local type1 = type(x)
    local type2 = type(y)
    if type1 ~= "table" then return type1 == type2  end 
    if type2 ~= "table" then
        local c1 = x[1] == y
        local c2 = if Id then x[2] == Id else true
        return c1 and c2 
    end
    local c1 = x[1] == y[1]
    local c2 = x[2] == y[2]
    return c1 and c2 
end

function Item.getDataFrom(name,id)
    local ItemData = Items[name]
    if not ItemData then 
        return 
    end 

    if not id or id == 0 then
        return  ItemData.default
    end
    return ItemData[(id and id or "1")] or ItemData.default
end


function Item.onEquip(self,entity)
    local event = Item.getEvent(self, "OnEquipped")
    if event then
        event(self,entity)
    end
end
 
function Item.onDequip(self,entity)
    local event = Item.getEvent(self, "OnDequipped")
    if event then
        event(self,entity)
    end
end
local getDataFrom = Item.getDataFrom 
function Item.getData(item)
    return getDataFrom(Item.getName(item),item[2])
end
local getData = Item.getData

function Item.get(Item,key) 
    local behData = getData(Item)
    if not behData then return end 
    return behData[key]
end

function Item.getEvent(self,event)
    local Name = Item.getName(self)
    local data = Items[Name]
    if not data then return end 
    return data.events[event]
end

function Item.getMethod(self,method,cannotBeBase)
    local Name = Item.getName(self)
    local data = Items[Name]
    if not data then return end 
    return data.methods[method] or  (not cannotBeBase and Item[method])
end

--@Override
function Item.getBreakMultiplayer(self,block,isBase)
    if not isBase then
        local method = Item.getMethod(self,"getBreakMultiplayer")
        if method then 
            return method(self)
        end 
    end
    return 1
end



function Item.getMaxCount(item)
    return ( getData(item)  or {}).MaxCount or 64 
end

local initAlready = false
function Item.Init()
    if initAlready then return end 
    initAlready = true
    local itemIndex 
    if Synchronizer.isActor() then
        itemIndex = Synchronizer.getDataActor("ItemData")
    elseif Synchronizer.isClient() then
        itemIndex = Synchronizer.getDataClient("ItemData")
    else
        local Saved = Synchronizer.getSavedData("ItemData")
        if Saved then
            itemIndex = Saved
        end
        local newAdded = false
        update(itemIndex)
        for blockName,_ in Items do
            if table.find(ItemsIndex, blockName) then continue end 
            table.insert(ItemsIndex,blockName)
            newAdded = true
        end
        if newAdded then
            Synchronizer.updateSavedData("ItemData",ItemsIndex)
        end
        Synchronizer.setData("ItemData",ItemsIndex)
    end
    update(itemIndex)
    for i,v in ItemsIndex do
        ItemKeys[v] = i
    end
    return Item
end

return Item 