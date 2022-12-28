local entity = {}
entity.__index = entity
local https = game:GetService("HttpService")
local genuuid = function()  return https:GenerateGUID(false) end 
local entitydata = game.ServerStorage.Entitys
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
local behhandler = require(game.ServerStorage.BehaviorHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local datahandler = require(game.ReplicatedStorage.DataHandler)
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local function interpolate(startVector3, finishVector3, alpha)
    local function currentState(start, finish, alpha)
        return start + (finish - start)*alpha

    end
    return Vector3.new(
        currentState(startVector3.X, finishVector3.X, alpha),
        currentState(startVector3.Y, finishVector3.Y, alpha),
        currentState(startVector3.Z, finishVector3.Z, alpha)
    )
end
entity.SpecialNames = {
    Data = true,
    Type = true,
    Velocity = true,
    NotSaved = true,
}
entity.ServerOnly = {
    "ServerOnly","Data"
}
entity.NotClearedNames = {
    Move = true
}
function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = deepCopy(v)
        end
    copy[k] = v
    end
    return copy
end
function entity.new(data)
    local self = data or {}
    setmetatable(self,entity)
    self.Id = data.Id or genuuid()
    self.Position = data.Position or Vector3.new()
    self.Type = data.Type or warn("Failed To Create Entity | No Entity Type Giving for:",self.Id) 
    if not data.Type then self:Destroy() return end 
    self.Velocity = self.Velocity or {}
    self.Data = data.Data or {}
    self.NotSaved = {}
    self.NotSaved["behaviors"] =  {}
    return self
end
function entity:CheckIfBehaviorIsSame(b1,b2)
    --print(b1,b2)
    local b1d,b2d = self:GetBehaviorData(b1),self:GetBehaviorData(b2)
    if not b1d or not b2d then return end
    b1,b2 = behhandler.GetBehavior(b1),behhandler.GetBehavior(b2)
    b1,b2 = b1d['bhtype'] or b1['bhtype'] or "deafult",b2d['bhtype'] or b2['bhtype'] or "deafult2"
    b1,b2 = type(b1) == "string" and {b1} or b1,type(b2) == "string" and {b2} or b2
    for i,v1 in b1 do
        for i,v2 in b2 do
            if v2 == v1 then return true end 
        end
    end
end
function entity.Create(type,data)
    local ehand = behhandler.GetEntity(type)
    if not ehand then return nil end 
    local self = entity.new({Type = type})
    if not self then return end 
    for cname,cdata in ehand.components or {} do
        self:AddComponent(cname,cdata)
    end
    for cname,cdata in data or {} do
        self:AddComponent(cname,cdata)
    end
    return self
end
function entity:GetBehaviorData(beh)
    if self["behaviors"] then
        return self["behaviors"][beh]
    end
end
function entity:GetQf()
    return qf
end
function entity:GetData()
    return datahandler
end
function entity:BehaviorCanRun(behavior,bhdata,Stop,CanNotBeSelf)
    local bh = behhandler.GetBehavior(behavior)
    local priority =  bhdata["priority"] or bh["priority"] or 10
    local ishighest = true
    local islower = {}
    for bh1,isrunning in self.NotSaved["behaviors"] do
        if self:CheckIfBehaviorIsSame(behavior,bh1) and isrunning then
            if (bh1 == behavior and CanNotBeSelf) then
                ishighest = false
                break
            end 
            if (self.behaviors[bh1]["priority"] or 10) > priority then
                if Stop then
                    islower[bh1] = true
                end
            else
                ishighest = false
                break
            end
        end
    end
    if ishighest and Stop then
        for i,v in islower do
            self.NotSaved["behaviors"][i] = nil
        end
    end
    return ishighest
end
function entity:AddVelocity(Name,velocity:Vector3)
    self.Velocity[Name] = self.Velocity[Name] or Vector3.new()
    self.Velocity[Name] += velocity
    return self
end
function entity:AddComponent(cpname,cpdata)
    if entity.SpecialNames[cpname]  then warn("The Name: '"..cpname.."' cannot be used as a component name",self) return self end 
    local split = cpname:split(".")
    if split[1] == "behavior" then  self.behaviors = self.behaviors or {} self = self.behaviors  end 
    if self[cpname] and type(cpdata) == "table" and cpdata["AddTo"] then
        for i,v in cpdata do
            self[cpname][i] = v
        end
    else
        self[cpname] = cpdata
    end
    if split[1] == "behavior" then
        local bhdata = behhandler.GetBehavior(cpname)
        if bhdata and bhdata["RunAtStart"] then task.spawn(bhdata.func,self,cpdata) end 
    end
    return self
end
function entity:ConvertToClient()
    local new = {}
    for i,v in self do
        if type(v) ~="function" and not table.find(entity.ServerOnly,i) then
            if type(v) =="table" then
                new[i] = deepCopy(v)
            else
                new[i] = v
            end
        end
    end
    return new
end
function entity:GetVelocity():Vector3
    local x,y,z = 0,0,0
    for i,v in self.Velocity do
        if typeof(v) == "Vector3" and v == v then
            x+= v.X
            y+= v.Y
            z+= v.Z
        end
    end
    if x == 0 then
        x = -0.00000001
    end
    if z == 0 then
        z = -0.00000001
    end
    return Vector3.new(x,y,z)
end
function entity:DoBehaviors(dt)
    for i,v in self.behaviors or {} do
        local beh = behhandler.GetBehavior(i)
        if beh and not beh["RunAtStart"] and not ( beh["CNRIC"] and  self.ClientControll) then
            task.spawn(function()
                beh.func(self,v)
            end)
        end
    end
end
function entity:ClearVelocity()
    for i,v in self.Velocity do
        if not entity.NotClearedNames[i] then
            self.Velocity[i] = nil
        end
    end
end
function entity:UpdatePosition(dt)
    if not self.ClientControll then 
        local velocity = self:GetVelocity()
        local p2 = interpolate(self.Position,self.Position+velocity,dt) 
        velocity = (p2-self.Position)
        local newp = CollisionHandler.entityvsterrain(self,velocity)
        self.Position = newp--interpolate(self.Position,newp,dt) 
    end
    self.Data.Grounded = CollisionHandler.IsGrounded(self)
end
function entity:RemoveFromChunk()
    if self.Chunk and datahandler.GetChunk(self.Chunk.X,self.Chunk.Y) then
        datahandler.GetChunk(self.Chunk.X,self.Chunk.Y).Entities[self.Id] = nil
    end
end
function entity:UpdateChunk()
    local cx,cz = qf.GetChunkfromReal(self.Position.X,self.Position.Y,self.Position.Z,true)
    local chunk = datahandler.GetChunk(cx,cz)
    if self.Chunk and self.Chunk ~= Vector2.new(cx,cz) then
        self:RemoveFromChunk()
    end
    if chunk then
        chunk.Entities[self.Id] = self
    end
    self.Chunk = Vector2.new(cx,cz)
end
function entity:Update(dt)
    self:UpdateChunk()
    self.NotSaved = self.NotSaved or {}
    self.NotSaved.DeltaTime = dt
    self:DoBehaviors(dt)
    self:UpdatePosition(dt)

end
function entity:TurnTo(Position)
    self.OrientationData = self.OrientationData or {}
    local data = self.OrientationData
    data.Neck = CFrame.new()
    data.MainWeld = data.MainWeld or CFrame.new()
    Position = Vector3.new(Position.X,self.Position.Y,Position.Z)
    data.MainWeld = CFrame.new()*CFrame.new(self.Position,Position).Rotation
end
function entity:LookAt(Position)
    self:TurnTo(Position)
    --neck turning wip
    -- self.OrientationData = self.OrientationData or {}
    -- local data = self.OrientationData
    -- data.Neck = data.Neck or CFrame.new()
    -- local x,y,z = CFrame.new(self.Position,Position):ToEulerAnglesXYZ()
    -- data.Neck = CFrame.Angles(0,y,0)
end
function entity:MoveTo(x,y,z)
    local goal = Vector3.new(x,y,z)
    local currentnumber = self.NotSaved["Moving"] and self.NotSaved["Moving"]+1  or 0
    self.NotSaved["Moving"] = currentnumber 
    local pos = self.Position
    self.Velocity = self.Velocity or {}
    self.Velocity.Move  = self.Velocity.Move  or {}
	local timestart = os.clock()
    local speed = (self.Speed or .1) 
	local velocity = (goal-pos).Unit*speed
	velocity = Vector3.new(velocity.X,0,velocity.Z)
	self.Velocity.Move = velocity
	local magnit = (goal-pos).Magnitude
    local timetotake = magnit/speed
    self:TurnTo(Vector3.new(x,y,z))
    repeat
        pos = self.Position
        task.wait()
    until (goal-pos).Magnitude <= 0.5 or self.NotSaved["Moving"] ~= currentnumber or  os.clock()-timestart >= timetotake+7
    if  os.clock()-timestart >= timetotake+7  then
       -- warn(self.Id,"has Yeilded")
    end
    if  self.NotSaved["Moving"] == currentnumber then
    self.Velocity.Move = {0,0,0}
    self.NotSaved["Moving"] = nil
    end
    return (self.NotSaved["Moving"] == currentnumber ) and "Done" or "Stopped"
end
function entity:Jump()
    if  self.Data.Jumping or self["CanNotJump"] then return end
    local e 
    local jumpedamount =0 
    local jumpheight = self.JumpHeight or 0 --1.25
    local muti = 4.5
    e = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        local jump = jumpheight*muti
        if (self.Data.Grounded )  and not self.Data.Jumping then
            if jumpedamount == 0 then
                jumpedamount += jumpheight*(deltaTime)*muti
            end 
           end
        if jumpedamount > 0 and jumpedamount <=jumpheight  then
         jumpedamount += jumpheight*(deltaTime)*muti
         jump = jumpheight*muti
         self.Data.Jumping = true
         else
            self.Data.Jumping = false
             jump = 0
             jumpedamount = 0
             self.Velocity.Jump = Vector3.new()
             e:Disconnect()
        end
        local touse = jump--fps.Value>62 and (jump/deltaTime)/60 or jump
        self.Velocity.Jump =Vector3.new(0,touse,0)
    end)
end
function entity:Kill()

    self:Destroy()
end
function entity:Destroy()
    setmetatable(self,nil) self = nil
    datahandler.RemoveEntity(self.Id)
    self:RemoveFromChunk()
end
return entity