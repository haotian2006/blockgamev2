local Debris = {}
Debris.__index = Debris
local Folders = {}

local ThreadDebounce = 1

function Debris:add(name,value)
    self[1][name] = value
    local threads = self[4]
    if threads[name] then 
        task.cancel(threads[name])
    end
    threads[name] = task.delay(self[2], self[5],name)
end

function Debris:remove(name)
    self[1][name] = nil
    local t = self[4][name]
    if t then
        task.cancel(t)
        self[4][name] = nil
    end
end

function Debris:get(name)
    local a = self[1][name]
    local threads = self[4]
    if threads[name] then 
        task.cancel(threads[name])
        threads[name] = task.delay(self[2], self[5],name)
    end
    return a
end

function Debris:getAll()
    return self[1]
end

function Debris.createFolder(Name,maxTime)
    if Folders[Name] then
        return Folders[Name]
    end
    local object = setmetatable({{},maxTime,Name,{},nil}, Debris)
    local storage = object[1]
    local threadStorage = object[4]
    local function remove(name)
        storage[name] = nil
        threadStorage[name] = nil
    end
    object[5] = remove
    Folders[Name] = object
    return object
end
function Debris.getFolder(Name)
  return Folders[Name]
end
function Debris.destroyFolder(Name)
    if not Folders[Name] then return end 
    for i,v in Folders[Name][4] do
        task.cancel(v)
    end
    Folders[Name] = nil
end
  

return Debris