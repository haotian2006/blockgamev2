--// This module was made to bypass roblox's warning with trying to call task.desync in a module not under the actor
local Tasks = {}

local id = 1

local LIMIT = 2^32-1
local function GetId()
    id += 1
    if Tasks[id] ~= nil then 
        return GetId()
    elseif id >= LIMIT then
        id = 0
        return GetId()
    end
    return id 
end


script.Parent:BindToMessageParallel("RunParallel", function(ID)
    local data = Tasks[ID]
    Tasks[ID] = nil
    local packed = {data[1],data[2](unpack(data[3]))}
    task.synchronize()
    local error ,msg = coroutine.resume(unpack(packed))
    if not error then
        warn(msg)
    end
end)

script.Parent:BindToMessage("Run", function(ID)
    task.synchronize()
    local data = Tasks[ID]
    Tasks[ID] = nil
    local packed = {data[1],data[2](unpack(data[3]))}
    local error ,msg = coroutine.resume(unpack(packed))
    if not error then
        print(msg)
    end
end)

local Runner = {}

function Runner.Run (x,...)
    local ID = GetId()
    Tasks[ID] = {coroutine.running(),x,{...}}
    script.Parent:SendMessage("Run",ID)
    return coroutine.yield() 
end

function Runner.RunParallel (x,...)
    local ID = GetId()
    Tasks[ID] = {coroutine.running(),x,{...}}
    script.Parent:SendMessage("RunParallel",ID)
    return coroutine.yield() 
end

return Runner
