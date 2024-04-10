local Family

local function getValue(x)
    return if x == "NIL" then nil else x 
end

local function combineSet(set,other)
    for i,v in other do
        set[i] = true
    end
end


local function getFamily(families)
    if type(families) == "string" then
        local family = table.clone(Family[families])
        local events = family.events
        local methods = family.methods
        family.events = nil
        family.methods = nil
        return family,events,methods ,family.__Family
    end
    local Combined = {}
    local CombinedMethods = {}
    local CombinedEvents = {}
    local AllFamily = {}
    for _,v in families do
        local data = Family[v]
        combineSet(AllFamily, v.__Family)
        for key,value in data do
            if key == "Alias" then continue end 
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
            if Combined[key] or key == "__Family" then continue end 
            Combined[key] = getValue(value)
        end
    end
    table.freeze(AllFamily)
    return Combined,CombinedEvents,CombinedMethods,AllFamily
end

local empty = {}
table.freeze(empty)

local function parse(name,data)
    local parsed = {
        __Family = empty,
        family = data.family,
        default = data.default or {},
        events = data.events or {},
        methods = data.methods or {}
    }
    local default = data.default
    local events = parsed.events
    local methods = parsed.methods
    if not default then
        default = parsed.default
        data.events = nil
        data.methods = nil
        for i,v in data do
            default[i] = v
        end
    end
    local family,familyEvents,fMethods,allFamily = {},{},{},{}
    if data.family then
        family,familyEvents,fMethods,allFamily = getFamily(data.family)
    end
    parsed.__Family = allFamily
    for i,v in family or {} do 
        if i == "Alias" then continue end 
        if default[i] then continue end
        default[i] = v
    end

    for i,v in familyEvents or {} do
        if events[i] then continue end
        events[i] = v
    end

    for i,v in fMethods or {} do
        if methods[i] then continue end
        methods[i] = v
    end
   
    local variants = data.variants or {}
    for variant,vData in next,variants do 
        for Attribute,value in default do
            if vData[Attribute] then continue end 
            vData[Attribute] = value
        end
        parsed[variant] = vData
    end
    return parsed
end

return function (toParse,Family_)
    Family = Family_
    for name,info in toParse do
        local parsed = parse(name,info)
        toParse[name] = parsed
    end
end

