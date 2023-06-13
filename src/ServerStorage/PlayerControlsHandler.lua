local Controls =  {}
Controls.__index = Controls

function Controls.new()
    return setmetatable({Events = {},Down = {}},Controls)
end

function Controls:KeyDown(key) 
    if self.Events[key] then
        self.Events[key]:fire(key,true)
    end
    self.Down[key] = true
end
function Controls:KeyUp(key)
    if self.Events[key] then
        self.Events[key]:fire(key,false)
    end
    self.Down[key] = nil
end
local signal = require(game.ReplicatedStorage.Libarys.Signal)
function Controls:GetInputEvent(name)
    if not self.Events[name] then self.Events = signal.new() end 
    return (self.Events[name]::signal.Signal<string,boolean>)
end
function Controls:IsDown(key)
    return self.Down[key] 
end
function Controls:Clear()
    table.clear(self.Down)
end
function Controls:Destroy()
    if self.Events then
        self.Events:DisconnectAll()
    end
    setmetatable(self)
end
return Controls