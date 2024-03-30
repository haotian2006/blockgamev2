local Family

local function getValue(x)
    return if x == "NIL" then nil else x 
end

local function getFamily(families)
    if type(families) == "string" then
        local family = table.clone(Family[families])
        local events = family.events
        local methods = family.methods
        family.events = nil
        family.methods = nil
        return family,events,methods
    end
    local Combined = {}
    local CombinedMethods = {}
    local CombinedEvents = {}
    for _,v in families do
        local data = Family[v]
        for key,value in data do
            if key == "events" then
                for eventName,event in value do
                    CombinedEvents[eventName] = getValue(event)
                end
                continue
            elseif key == "methods" then
                for methodName,method in value do
                    CombinedMethods[methodName] = getValue(method)
                end
                continue
            end
            Combined[key] = getValue(value)
        end
    end
    return Combined,CombinedEvents,CombinedMethods
end

local function parse(name,data)
    local parsed = {
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
    local family,familyEvents,fMethods = {},{},{}
    if data.family then
        family,familyEvents,fMethods = getFamily(data.family)
    end

    for i,v in family do 
        if default[i] then continue end
        default[i] = v
    end

    for i,v in familyEvents do
        if events[i] then continue end
        events[i] = v
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

