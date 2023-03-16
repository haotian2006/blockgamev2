local debug = {}
debug.__index = debug
function debug.new(Name)
    local f = {}
    setmetatable(f,debug)
    f.Items = {}
    f.StartTime = DateTime.now().UnixTimestampMillis
    debug[Name] = debug[Name] or {}
    table.insert(debug[Name],f)
    f.index = #debug[Name]
    f.Parent = debug[Name] 
    return f
end
function debug:gettime()
    print("-----------------")
    for i,v in pairs(self.Items)do
        print(i.."|"..v.."ms")
    end
end
function debug:update(index:string)
    local timea = DateTime.now().UnixTimestampMillis- self.StartTime
   self.Items[index] = not self.Items[index] and timea or self.Items[index] + timea
   self.StartTime = DateTime.now().UnixTimestampMillis
end
function debug.PrintAverageTime(Name)
    if debug[Name] and debug[Name][1] then
        debug[Name][1]:GetAverageTime()
    end
end
function  debug:GetAverageTime()
    local total = {}
    local ammount = {}
    for i,v in self.Parent do
        for index,times in v.Items do
            total[index] = total[index] or 0
            total[index] += times
            ammount[index] = ammount[index] or 0
            ammount[index] +=1
        end
    end
    print("-----------------")
    for i,v in total do
        local avergae = v/ammount[i]
        print(i.."|"..avergae.."ms")
    end
end

return debug