local MoveTo = {}
MoveTo.__index = MoveTo
local runservice = game:GetService("RunService")
function MoveTo.new(entity,x,y,z,NoInit)
    local self = setmetatable({},MoveTo)
    self.entity = entity
    self.compleated = Instance.new("BindableEvent")
    self.Goal = Vector3.new(x,y,z)
    if not NoInit then
        task.spawn(MoveTo.Init,self)
    end
    return self
end
function MoveTo:Init()
    local goal = self.Goal
    local currentnumber = self.entity.NotSaved["Moving"] and self.entity.NotSaved["Moving"]+1  or 0
    self.entity.NotSaved["Moving"] = currentnumber 
    self.Position = self.entity.Position
    self.entity.Velocity = self.entity.Velocity or {}
    self.entity.Velocity.Move  = self.entity.Velocity.Move  or {}
	local timestart = os.clock()
    local speed = (self.entity.Speed or .1) 
	local velocity = (goal-self.Position).Unit*speed
	velocity = Vector3.new(velocity.X,0,velocity.Z)
	local magnit = (goal-self.Position).Magnitude
    local timetotake = magnit/speed
    self.entity:TurnTo(Vector3.new(goal.X,goal.Y,goal.Z))
    local event 
    local thread = coroutine.running()
    event = runservice.Heartbeat:Connect(function(deltaTime)
        self.entity:AddVelocity("Move",velocity)
        self.Position = self.entity.Position
       -- print(self.entity.NotSaved["Moving"],currentnumber)
        if ((goal-self.Position).Magnitude <= 0.5 or self.entity.NotSaved["Moving"] ~= currentnumber or  os.clock()-timestart >= timetotake+7 or self["Stoped"]) then
            event:Disconnect()
            coroutine.resume(thread)
        end
    end)
    coroutine.yield(thread)
    if  os.clock()-timestart >= timetotake+7  then
       -- warn(self.Id,"has Yeilded")
    end
    if  self.entity.NotSaved["Moving"] == currentnumber then
        self.entity.Velocity.Move = nil
        self.entity.NotSaved["Moving"] = nil
    end
    self.compleated:Fire(((goal-self.Position).Magnitude <= 0.5) and "Done" or "Stopped")
    return ((goal-self.Position).Magnitude <= 0.5) and "Done" or "Stopped"
end
function MoveTo:Stop()
    self.Stoped = true
end
function MoveTo:Destroy()
    self.Stoped = true
    self.compleated:Destroy()
    setmetatable(self,nil)
end
return MoveTo