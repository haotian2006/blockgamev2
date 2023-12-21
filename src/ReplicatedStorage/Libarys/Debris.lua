local Debris = {}
Debris.__index = Debris
local Folders = {}

function Debris:add(name,value)
    self[1][name] = {value,time()}
end


function Debris:get(name)
    local a = self[1][name]
    return if a then a[1] else nil
end

function Debris:update()
    local max = self[2]
    for i,v in self[1] do
        if time()-v[2] > max then
            self[1][v] = nil
        end
    end
end

function Debris.createFolder(Name,maxTime)
    if Folders[Name] then
        return Folders[Name]
    end
    local object = setmetatable({{},maxTime}, Debris)
    Folders[Name] = object
    local flag = false
    object[3] = game:GetService("RunService").Heartbeat:Connect(function(dt)
        flag = not flag
        if flag then object:update() end 
    end)
    return object
end
function Debris.getFolder(Name)
  return Folders[Name]
end
function Debris.destroyFolder(Name)
    if not Folders[Name] then return end 
    (Folders[Name][3]::RBXScriptConnection):Disconnect()
    Folders[Name] = nil
end
  

return Debris