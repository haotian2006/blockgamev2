local RunService = game:GetService("RunService")
local Keybind = {}
local Deafult = require(script.DeafultKeys)
local CurrentState = "Keyboard"
local Modified = {
    Keyboard = {},
    Touch = {},
    Controller = {}
}
local Cache = {}
local function getkeyfrominput(input)
    if input.KeyCode.Name ~= "Unknown" then
        return input.KeyCode.Name:lower(),true
    elseif input.UserInputType.Name ~= "Unknown" then
        return input.UserInputType.Name:lower(),false
    end
    return nil,nil
end
Keybind.getKeyFromInput = getkeyfrominput
function Keybind.setCurrentState(name)
    if CurrentState == name then
        return CurrentState
    end
    CurrentState = name
    table.clear(Cache)
    return name
end
function Keybind.getCurrentState()
    return  CurrentState 
end
function  Keybind.getActionsFromKey(key:EnumItem|string)
    if typeof(key) == "Instance" then
        key = getkeyfrominput(key)
    end
    if Cache[key] then return Cache[key] end 
    local DeafultToLookIn = Deafult[CurrentState]
    local NormaltoLookIn = Modified[CurrentState]
    local keys = {}
    for i,v in DeafultToLookIn do
        local found = false
        local keydata = v[1]
        if typeof(keydata) == "table" then
            local k1,k2 = keydata[1],keydata[2]
            found = k1 == key or k2 == key
        else
            found = keydata == key
        end
        if found then
            keys[i] = v
        end
    end
    for i,v in NormaltoLookIn do
        local found = false
        local keydata = v[1]
        if typeof(keydata) == "table" then
            local k1,k2 = keydata[1],keydata[2]
            found = k1 == key or k2 == key
        else
            found = keydata == key
        end
        if found then
            keys[i] = v
        else
            keys[i] = nil
        end
    end
    local actions = {}
    local function f(a,i)
        if  actions[a] then
            table.insert(actions[a],i)
        else
            actions[a] = {i}
        end
    end
    for i,v in keys do
        if type(v) == "table" then
            for _,a in v do
               f(a,i)
            end
        else
            f(v,i)
        end
    end
    table.freeze(actions)
    Cache[key] = actions
    return actions
end
return table.freeze(Keybind)