local manager = {}
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local Synchronizer = require(game.ReplicatedStorage.Synchronizer)

local AllFieldTypes = BehaviorHandler.getAllData().FieldTypes

local Core = require(game.ReplicatedStorage.Core)
local DataTypes = Core.Shared.ByteNet.Types

local FieldTypesTable = {
    Position = DataTypes.vec3,
    Rotation = DataTypes.float32,
    HeadRotation = DataTypes.vec2,
    Guid = DataTypes.string,
    Type = DataTypes.string,
    __containers = DataTypes.map(DataTypes.string, DataTypes.container),
    __components = DataTypes.array(DataTypes.string),
    __ownership = DataTypes.float64,

    --<BASIC>
    Gravity = DataTypes.float32,
    Hitbox = DataTypes.vec3,
    Speed = DataTypes.float32,

    Slot = DataTypes.string,
    
    --<C:ITEM>
    ItemId = DataTypes.uint16,
    ItemVariant = DataTypes.uint8,
    ItemCount = DataTypes.uint16,
    
}

local Types = {

}

local KeyPairs = {
    
}

local initAlready = false
local function update(types)
    local t = Types 
    for i,v in types or {} do
        if t[i] then continue end 
        t[i] = v
    end
end
function manager.Init()
    if initAlready then return end 
    initAlready = true
    local types 
    if Synchronizer.isActor() then
        types = Synchronizer.getDataActor("EntityFieldTypes")
    elseif Synchronizer.isClient() then
        types = Synchronizer.getDataClient("EntityFieldTypes")
    else
        local Saved = Synchronizer.getSavedData("EntityFieldTypes")
        if Saved then
            types = Saved
        end

        update(types)
        local newAdded = false
        for i,v in FieldTypesTable do
            AllFieldTypes[i] = v
        end
        for TypeName,Type in AllFieldTypes do
            if table.find(Types,TypeName) then continue end 
            table.insert(Types,TypeName)
            newAdded = true
        end
        if newAdded then
            Synchronizer.updateSavedData("EntityFieldTypes",Types)
        end
        Synchronizer.setData("EntityFieldTypes",Types)
    end
    update(types)
    for i,v in Types do
        KeyPairs[v] = i
    end
    for i,v in FieldTypesTable do
        if v [1] and v[2] ~= nil then
            local c = table.clone(v[1])
            c.CanNotSave = not v[2]
            FieldTypesTable[i] = c
        end
    end
    table.freeze(KeyPairs)
    table.freeze(FieldTypesTable)
    table.freeze(Types)
    return manager
end

function manager.getIndexFromField(key)
    return KeyPairs[key]
end

function manager.getKeyFromIndex(Index)
    return Types[Index]
end

function manager.getParserFromField(key)
    return FieldTypesTable[key]
end

function manager.getAllInfo() 
    return Types,KeyPairs,FieldTypesTable
end

return manager