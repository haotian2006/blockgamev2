local Debris = {}
Debris.__index = Debris

local Folders = {}

--//WARNING: AVOID USING NUMBERED KEYS OR INDEXS 1 2 3

function Debris:add(name,value)
    local sub = table.create(3)
    sub[1] = value
    sub[2] = task.delay(self[1], self[3],name)
    self[name] = sub
end

function Debris:remove(name)
    local object = self[name]
    if not object then return end 
    local t = object[2]
    if t then
        task.cancel(t)
    end
    object[3] = false 
    self[3](name)
end

function Debris:getSize()
    local count = -3
    for i,v in self do
        count +=1
    end
    return count
end

function Debris:get(name)
    local a = self[name]
    if not a then return  end 
    a[3] = true
    return a[1]
end

function Debris.getOrCreateFolder(Name,maxTime,Destroy)
    if Folders[Name] then
        return Folders[Name]
    end
    local object = setmetatable({maxTime,Name}, Debris)
    local function remove(name)
        local obj = object[name]
        if not obj then return end 
        if obj[3] then
            obj[2] = task.delay(maxTime,remove,name)
            obj[3] = false
            return
        end
        if Destroy then 
            Destroy(obj[1])
        end
        object[name] = nil
    end
    object[3] = remove
    Folders[Name] = object
    return object
end

function Debris.getFolder(Name)
  return Folders[Name]
end

function Debris.destroyFolder(Name)
    if not Folders[Name] then return end 
    for i,v in Folders[Name] do
        if type(i) == "number" then continue end 
        Debris.remove(Folders[Name] ,i)
    end
    table.clear( Folders[Name])
    Folders[Name] = nil
end
  
return Debris