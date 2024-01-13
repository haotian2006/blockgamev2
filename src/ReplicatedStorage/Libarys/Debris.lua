local Debris = {}
Debris.__index = Debris
local Folders = {}

function Debris:add(name,value)
    self[1][name] = {value,time()}
    if self[4][name] then 
        task.cancel(self[4][name])
    end
    self[4][name] = task.delay(self[2], self[5],name)
end


function Debris:get(name)
    local a = self[1][name]
    if self[4][name] then 
        task.cancel(self[4][name])
        self[4][name] = task.delay(self[2], self[5],name)
    end
    return if a then a[1] else nil
end

function Debris:update()
    local max = self[2]
    local t = time()
    for i,v in self[1] do
        if t-v[2] > max then
            self[1][v] = nil
        end
    end
end

function Debris.createFolder(Name,maxTime)
    if Folders[Name] then
        return Folders[Name]
    end
    local object = setmetatable({{},maxTime,Name,{}}, Debris)
    local function remove(name)
        object[1][name] = nil
        object[4][name] = nil
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