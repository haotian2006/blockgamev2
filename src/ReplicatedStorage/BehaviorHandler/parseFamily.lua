
local allFamilies 

local function getValue(x)
    return if x == "NIL" then nil else x 
end

local function combineFamily(f1,f2)
    local Combined = f1
    local CombinedMethods = f1.methods or {}
    local CombinedEvents = f1.events or {}
    for key,value in f2 do
        if key == "RealName" then continue end 
        if key == "events" then
            for eventName,event in value do
                if CombinedEvents[eventName] then continue end 
                CombinedEvents[eventName] = getValue(event)
            end
            continue
        elseif key == "methods" then
            for methodName,method in value do
                if CombinedMethods[methodName] then continue end 
                CombinedMethods[methodName] = getValue(method)
            end
            continue
        end
        if Combined[key] then continue end 
        Combined[key] = getValue(value)
    end
end

local function setupFamily(name,visited)
    local data = allFamilies[name]
    visited = visited or {}
    if visited[name] then
        warn(`Cyclic inheritance detected for family: '{name}'`)
        return
    end
    if not data or data.__INIT then 
        return 
    end 
    local Inherited = data.Inheritance
    data.__INIT = true
    visited[name] = true
    if type(Inherited) ~= "string" then 
        return
    end
    setupFamily(Inherited,visited)
    local ParentData = allFamilies[Inherited]
    combineFamily(data,ParentData)
end



return function(families)
    allFamilies = families
    for family in allFamilies do
        setupFamily(family)
    end
end
