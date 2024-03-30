local family

local function parseString(str,container)
    local part,t = str:match("([^%.]*)%.?(.*)")
    return part,t
end

local function parse(name,data)
    local parsed = {
        family = nil,
        components = {},
        component_groups = {},
    }

    local family 
    if data.family then
        family = family[data.family]
        parsed.family = family
    end

    for i,v in family do 
        parsed.components[i] = parseString(v)
    end

    for i,v in data.components or {} do 
        parsed.components[i] = parseString(v)
    end
  
   for key,groupInfo in data.component_groups or {} do 
        local t = {}
        parsed.component_groups[key] = t
        for i,v in groupInfo do
            t[i] = parseString(v)
        end
    end

    return parsed
end

return function (toParse,Family_)
    family = Family_
    for name,info in toParse do
        local parsed = parse(name,info)
        toParse[name] = parsed
    end
end

