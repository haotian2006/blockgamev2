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

function Debris:getSize()
    local count = 0
    for i,v in self[1] do
        count +=1
    end
    return count
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

function Debris.createFolder(Name,maxTime,Destroy)
    if Folders[Name] then
        return Folders[Name]
    end
    local object = setmetatable({{},maxTime,Name,nil}, Debris)
    local storage = object[1]
    local function remove(name)
        local object =  storage[name] 
        if Destroy then
            Destroy(object[1])
        end
        storage[name] = nil
    end
    object[4] = remove
    Folders[Name] = object
    return object
end
function Debris.getFolder(Name)
  return Folders[Name]
end
function Debris.destroyFolder(Name)
    if not Folders[1][Name] then return end 
    for i,v in Folders[1][Name] do
        task.cancel(v)
    end
    Folders[Name] = nil
end
  

return Debris