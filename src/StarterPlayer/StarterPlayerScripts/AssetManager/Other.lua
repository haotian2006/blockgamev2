local Other = {}

local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local AllData = ResourceHandler.getAllData()

local Order = {"EntityModels","Entities"}

local parser = {}

local function getModel(name)
    return type(name) == "string" and AllData.EntityModels[name] or name
end

local function UnpackModel(cont,model)
    if typeof(model) == "Instance" then
        cont.Model = model
        return 
    end
    cont.Model = nil
    for i,v in model or {} do
        if cont[i] then continue end 
        cont[i] = v
    end
end

function parser.EntityModels(name,data)
    data.Model = data.Model or AllData.Model["Player"]
    data.Animations = data.Animations or {}
    for i,v in data.Animations  do
        if type(v) ~= "string" then continue end 
        data.Animations[i] = AllData.Animations[v]
    end
end

function parser.Entities(name,data)
    local parsed = {
         Default = {
             Model = "Player"
         },
         Variants = data.Variants or {}
    }
 
    if not data.Default then
         parsed.Default = table.clone(data)
    end
    UnpackModel(parsed.Default,getModel(parsed.Default.Model))
    for i,v in parsed.Variants do
        UnpackModel(v,getModel(v.Model))
    end
    return parsed
 end

function Other.init()
    for _,v in Order do
        local Data = AllData[v]
        local f = parser[v]
        for name,value in Data do
            if name == "ISFOLDER" then continue end 
            Data[name] =  f(name,value) or value
        end
    end
    print(AllData)
end

return Other