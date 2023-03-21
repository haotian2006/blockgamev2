local Curve = {}
Curve.__index = Curve
local bezier = require(game.ReplicatedStorage.Libarys.Bezier)
local ch = require(game.ReplicatedStorage.CollisonHandler)
local runservice = game:GetService("RunService")
function Curve.new(entity,Direaction,TimeToTake,CustomName,NoInit,UserBezierInstead)
    local self = setmetatable({},Curve)
    self.entity = entity
    self.Name = CustomName or "Curve"
    self.completed = Instance.new("BindableEvent")
    self.Direaction = Direaction or error("Direaction Not Given")
    self.TimeToTake = TimeToTake or 1
    self.UBI = UserBezierInstead
    if not NoInit then
        task.spawn(Curve.Init,self)
    end
    return self
end
function Curve:Gravityversion()
    local currentnumber = self.entity.NotSaved["Curve"] and self.entity.NotSaved["Curve"]+1  or 0
    self.entity.NotSaved["Curve"] = currentnumber 
    local xzrate = Vector3.new(self.Direaction.X,0,self.Direaction.Z).Magnitude/self.TimeToTake
    local xzdir= Vector3.new(self.Direaction.X,0,self.Direaction.Z).Unit*xzrate
    local yrate = self.Direaction.Y/2
    local yammount = 0
    local xzdistance = 0 
    local event 
    local start = os.clock()
    local thread = coroutine.running()
    self.entity:SetBodyVelocity("Gravity",Vector3.new(0,yrate*20,0) )
    self.entity.Data.Gravity = yrate
    self.entity.Data.Grounded = false
    event = runservice.Heartbeat:Connect(function(deltaTime)
        local velocity = xzdir
        if yammount >= self.Direaction.Y then
           -- print(yrate,yammount)
          --  self.entity.NotSaved.NoFall = false
        else
            -- self.entity:SetBodyVelocity("Gravity",Vector3.zero)
            -- self.entity.Data.Gravity =0 
            -- velocity = Vector3.new(xzdir.X,yrate,xzdir.Z)
            -- yammount += yrate*deltaTime 
        end
        if not self.entity.Destroyed then
            xzdistance += xzrate*deltaTime
            self.entity:AddVelocity("Curve",velocity)
            self.Position = self.entity.Position
        end
        if ( self.entity.NotSaved["Curve"] ~= currentnumber or  xzdistance >= Vector3.new(self.Direaction.X,0,self.Direaction.Z).Magnitude or self["Stopped"]) or self.entity.Destroyed or ch.IsGrounded(self.entity,true) then
            event:Disconnect()
            coroutine.resume(thread)
        end
    end)
    coroutine.yield(thread)
   -- print(os.clock()-start,self.TimeToTake)
    if  self.entity and self.entity.NotSaved["Curve"] == currentnumber then
        self.entity.NotSaved.NoFall = nil
        self.entity.NotSaved["Curve"] = nil
    end
    self.completed:Fire( "Done" )
    return "Done"
end
function Curve:Bezier()
    local start = self.entity.Position
    local endpos = self.entity.Position + Vector3.new(self.Direaction.X,0,self.Direaction.Y)
    local currentnumber = self.entity.NotSaved["Curve"] and self.entity.NotSaved["Curve"]+1  or 0
    self.entity.NotSaved["Curve"] = currentnumber 

    local b = bezier.new()
    if  self.entity and self.entity.NotSaved["Curve"] == currentnumber then
        self.entity.NotSaved.NoFall = nil
        self.entity.NotSaved["Curve"] = nil
    end
    self.completed:Fire( "Done" )
    return "Done"
end
function Curve:Init()
    return self:Gravityversion()
end
function Curve:Stop()
    self.Stopped = true
end
function Curve:Destroy()
    self.Stopped = true
    self.completed:Destroy()
    setmetatable(self,nil)
end
return Curve