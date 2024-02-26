local Item = {}
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)

local Items = BehaviorHandler.getAllData().Items

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()

function Item.new(Name,Id)
    return {Name,Id or 0}
end

function Item.getItemInfoR(self)
    local data = ResourceHandler.getItem(self[1],self[2])
    if not data then
        return {
            Name = self[1],
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
        Name = self[1],
        DisplayName = data.DisplayName or string.match(self[1], "%a:(%w+)"),
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
    local itemdata = Item.getItemInfoR(Item_)
    if not itemdata  then return end 
    local stuff = {}
    local texture = itemdata.Texture
    local mesh = itemdata.Mesh 
    if not mesh then return end 
    mesh = mesh:Clone()
    if not texture then return mesh,itemdata end 
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
    return mesh,itemdata
end


function Item.tostring(item)
    return `{item[1]}-{item[2] or 0}`
end

function Item.equals(x,y,Id:number?)
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
    if ItemData.__NoDefault then
        return ItemData
    end
    
    if not id or id == 0 then
        return  ItemData.Default
    end

    return ItemData[(id and id or "1")] or ItemData.Default
end

function Item.onEquip(self,entity)
    local data = Item.getData(self)
    if data and data.OnEquipped then
        data.OnEquipped(self,entity)
    end
end
 
function Item.onDequip(self,entity)
    local data = Item.getData(self)
    if data and data.OnDequipped then
        data.OnDequipped(self,entity)
    end
end
local getDataFrom = Item.getDataFrom 
function Item.getData(item)
    return getDataFrom(item[1],item[2])
end
local getData = Item.getData

function Item.get(Item,key)
    local behData = getData(Item)
    if not behData then return end 
    return behData[key]
end

function Item.getMaxCount(item)
    return ( getData(item)  or {}).MaxCount or 64 
end

return Item 