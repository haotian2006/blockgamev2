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
function Controls:GetInputEvent(name)
    if not self.Events[name] then self.Events = Instance.new("BindableEvent") end 
    return self.Events[name]
end
function Controls:IsDown(key)
    return self.Down[key] 
end
function Controls:Clear()
    table.clear(self.Down)
end
function Controls:Destroy()
    for i,v in self.Events do
        v:Destroy()
    end
    setmetatable(self)
end
return Controls