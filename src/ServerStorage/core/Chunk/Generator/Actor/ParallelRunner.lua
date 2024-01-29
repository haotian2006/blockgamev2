local Tasks = {}

local id = 1

local Overflow = 2^32-1
local function GetId()
    id += 1
    if Tasks[id] ~= nil then 
        return GetId()
    elseif id >= Overflow then
        id = 0
        return GetId()
    end
    return id 
end

script.Parent:BindToMessageParallel("Run", function(ID)
    local data = Tasks[ID]
    Tasks[ID] = nil
    coroutine.resume(data[1],data[2](unpack(data[3])))
    task.desynchronize()
end)

return function(x,...)
    local ID = GetId()
    Tasks[ID] = {coroutine.running(),x,{...}}
    script.Parent:SendMessage("Run",ID)
    return coroutine.yield()
end
