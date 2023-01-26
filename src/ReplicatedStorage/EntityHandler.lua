local entity = {}
entity.__index = entity
local https = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local genuuid = function()  return https:GenerateGUID(false) end 
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local maths = require(game.ReplicatedStorage.QuickFunctions.MathFunctions)
local datahandler = require(game.ReplicatedStorage.DataHandler)
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local movers = require(game.ReplicatedStorage.EntityMovers)
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
    behaviors = true,
}
entity.NotClearedNames = {
    --Move = true
}
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
    self.NotSaved.NoClear = {}
    return self
end
function entity:UpdateEntity(newdata)
    for i,v in self do
        if i == "Entity" or i == "Tweens" then continue end 
        self[i] = newdata[i] 
    end
    for i,v in newdata do
        self[i] = v 
    end
end
entity.KeepSame = {"Position","NotSaved","Velocity",'HitBox',"EyeLevel","Crouching"}
function entity:UpdateEntityClient(newdata)
    for i,v in newdata do
        if table.find(entity.KeepSame,i) then continue end 
        self[i] = v 
    end
end
function entity:UpdateModelPosition()
    local ParentModel = self.Entity
    if not ParentModel then return end 
    local model = ParentModel:FindFirstChild("EntityModel")
    ParentModel.PrimaryPart.Size = Vector3.new(self.HitBox.X,self.HitBox.Y,self.HitBox.X)*3
    local MiddleOffset = ParentModel.PrimaryPart.Size.Y-(ParentModel.PrimaryPart.Size.Y/2+model.PrimaryPart.Size.Y/2)
    local pos =ParentModel.PrimaryPart.Position 
    model.PrimaryPart.CFrame = CFrame.new(pos.X,pos.Y-MiddleOffset,pos.Z)
    local weld = ParentModel.PrimaryPart:FindFirstChild("EntityModelWeld")
    weld.C0 = CFrame.new(0,-MiddleOffset,0)
    local eyeweld = ParentModel:FindFirstChild("Eye"):FindFirstChild("EyeWeld")
    local offset = self.EyeLevel
    if not eyeweld then return end 
    eyeweld.C0 = offset and CFrame.new( Vector3.new(0,offset/2,0)*3) or CFrame.new()
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
function entity:GetQf()
    return qf
end
function entity:GetData()
    return datahandler
end
function entity:AddVelocity(Name,velocity:Vector3)
    if not self.NotSaved.ClearVelocity or self.NotSaved.NoClear[Name] then
        self.Velocity[Name] = self.Velocity[Name] or Vector3.new()
        self.Velocity[Name] = velocity
    else
        self.NotSaved.Velocity = self.NotSaved.Velocity or {}
        self.NotSaved.Velocity[Name] =  self.NotSaved.Velocity[Name] or Vector3.new()
        self.NotSaved.Velocity[Name] = velocity
    end
    return self
end

function entity:AddNoClear(Name)
    self.NotSaved.NoClear = self.NotSaved.NoClear or {}
    self.NotSaved.NoClear[Name] = true
end
function entity:RemoveNoClear(Name)
    self.NotSaved.NoClear = self.NotSaved.NoClear or {}
    self.NotSaved.NoClear[Name] = nil
end
function entity:DoBehaviors(dt)
    --wip
end
function entity:ClearVelocity()
    for i,v in self.Velocity do
        if not entity.NotClearedNames[i] and not self.NotSaved.NoClear[i] then
            self.Velocity[i] = nil
        end
    end
    self.NotSaved.ClearVelocity = false
    for i,v in self.NotSaved.Velocity or {} do
        self.Velocity[i] = v
        self.NotSaved.Velocity[i] = nil
    end
end
function entity:UpdatePosition(dt)
    local velocity = self:GetVelocity()
    self.NotSaved.ClearVelocity = true
    if not self.ClientControll or  ( RunService:IsClient() and self.ClientControll and self.ClientControll == tostring(game.Players.LocalPlayer.UserId) ) then 
        local p2 = interpolate(self.Position,self.Position+velocity,dt) 
        velocity = (p2-self.Position)
        local newp = CollisionHandler.entityvsterrain(self,velocity)
        local dir = newp - self.Position
        local length = 0
        if velocity.Y <= 0 and self.Crouching and self.NotSaved.LastG then
            local o = maths.newPoint(self.Position.X,self.Position.Z)
            local endp = maths.newPoint((self.Position+velocity).X,(self.Position+velocity).Z)
            local realp = maths.newPoint(newp.X,newp.Z)
            local xsidesame,ysidesame = qf.RoundTo(realp.x) == qf.RoundTo(endp.x),qf.RoundTo(realp.y) == qf.RoundTo(endp.y)
            local clonede = self:CloneProperties()
            o,realp =  o:Vector2(),realp:Vector2()
            local current = o
            local hit = false
            local last 
            if xsidesame and ysidesame then
                    local v1 = (realp-current).Unit/10
                    v1 = v1 ~= v1 and Vector2.zero or v1
                    local function checkandadd(noadd,c)
                        c = c or current
                        if hit and not noadd then return end 
                        clonede.Position = Vector3.new(c.X,clonede.Position.Y,c.Y)
                        local a = CollisionHandler.IsGrounded(clonede)
                        if noadd then return a end 
                        if not a then  hit = true return end 
                        last = current
                        current +=v1
                        length += 1/10
                    end
                    checkandadd()
                    while length <= (o-realp).Magnitude and not hit do
                        checkandadd()
                    end
                    current = realp
                    checkandadd()
                    if hit and last then
                        local lx,lz = last.X,last.Y
                        local a = checkandadd(true,Vector2.new(last.X,current.Y))
                        local b = checkandadd(true,Vector2.new(current.X,last.Y))
                        if  a and a == b then
                            print("None")
                        elseif a then
                            lz = current.Y
                        elseif b then
                            lx = current.X
                        end
                        newp = Vector3.new(lx,newp.Y,lz)
                    end
            elseif xsidesame then
                local dc = maths.newLine(realp,maths.newPoint(o.x,realp.y))
                local midpoint = dc:CalculatePointOfInt(maths.newLine(o,endp))
                if midpoint then
                    midpoint = midpoint:Vector2()
                    local v1 = (midpoint - o).Unit/10
                    v1 = v1 ~= v1 and Vector2.zero or v1
                    local function checkandadd()
                        if hit then return end 
                        clonede.Position = Vector3.new(current.X,clonede.Position.Y,current.Y)
                        local a = CollisionHandler.IsGrounded(clonede)
                        if not a then  hit = true return end 
                        last = current
                        current +=v1
                        length +=1/10
                    end
                    checkandadd()
                    while length <= (midpoint - o).Magnitude and not hit do
                        checkandadd()
                    end
                    current = midpoint
                    checkandadd()
                    v1 = (realp-current).Unit/10
                    v1 = v1 ~= v1 and Vector2.zero or v1
                    checkandadd()
                    length = 0
                    while length <= (realp - o).Magnitude and not hit do
                        checkandadd()
                    end
                    current = realp
                    checkandadd()
                    if hit and last then
                        newp = Vector3.new(last.X,newp.Y,newp.Z)
                    end
                end
            elseif ysidesame then
                local dc = maths.newLine(realp,maths.newPoint(realp.x,o.y))
                local midpoint = dc:CalculatePointOfInt(maths.newLine(o,endp))
                if midpoint then
                    midpoint = midpoint:Vector2()
                    local v1 = (midpoint - o).Unit/10
                    v1 = v1 ~= v1 and Vector2.zero or v1
                    local function checkandadd()
                        if hit then return end 
                        clonede.Position = Vector3.new(current.X,clonede.Position.Y,current.Y)
                        local a = CollisionHandler.IsGrounded(clonede)
                        if not a then  hit = true return end 
                        last = current
                        current +=v1
                        length +=1/10
                    end
                    checkandadd()
                    while length <= (midpoint - o).Magnitude and not hit do
                        checkandadd()
                    end
                    current = midpoint
                    checkandadd()
                    v1 = (realp-current).Unit/10
                    v1 = v1 ~= v1 and Vector2.zero or v1
                    checkandadd()
                    length = 0
                    while length <= (realp - o).Magnitude and not hit do
                        checkandadd()
                    end
                    current = realp
                    checkandadd()
                    if hit and last then
                        newp = Vector3.new(newp.X,newp.Y,last.Y)
                    end
                end
            else 
            end 
        end
        self.Position = newp--interpolate(self.Position,newp,dt) 
    end
    self.Data.Grounded = CollisionHandler.IsGrounded(self)
    if  self.NotSaved["LastG"] and not self.Data.Grounded and not self.NotSaved.Jumping then
        self.NotSaved["ExtraJump"] = DateTime.now().UnixTimestampMillis/1000
    end
    self.NotSaved.LastG = self.Data.Grounded
end
function entity:CloneProperties(x)
        local copy = {}
        for k, v in pairs(x or self) do
          if type(v) == "table" then
            v = entity:CloneProperties(v)
          end
          copy[k] = v
        end
        return copy
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
    if RunService:IsServer() or (RunService:IsClient() and self.ClientControll and self.ClientControll == tostring(game.Players.LocalPlayer.UserId)) then else return end 
    self:UpdateBodyVelocity(dt)
    self:Gravity(dt)
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
    local new = CFrame.new()*CFrame.new(self.Position,Position).Rotation
    local rx,ry,rz = new:ToOrientation()
    if rx ~= rx or ry~=ry or rz~= rz then return end
    data.MainWeld = new
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
function entity:KnockBack(force,time)
    self.NotSaved.Tick = 0
    movers.Curve.new(self,force,time)
end
function entity:MoveTo(x,y,z)
    local new = require(game.ReplicatedStorage.EntityMovers).MoveTo.new(self,x,y,z,true)
    new:Init()
    -- local goal = Vector3.new(x,y,z)
    -- local currentnumber = self.NotSaved["Moving"] and self.NotSaved["Moving"]+1  or 0
    -- self.NotSaved["Moving"] = currentnumber 
    -- local pos = self.Position
    -- self.Velocity = self.Velocity or {}
    -- self.Velocity.Move  = self.Velocity.Move  or {}
	-- local timestart = os.clock()
    -- local speed = (self.Speed or .1) 
	-- local velocity = (goal-pos).Unit*speed
	-- velocity = Vector3.new(velocity.X,0,velocity.Z)
	-- self.Velocity.Move = velocity
	-- local magnit = (goal-pos).Magnitude
    -- local timetotake = magnit/speed
    -- self:TurnTo(Vector3.new(x,y,z))
    -- repeat
    --     pos = self.Position
    --     task.wait()
    -- until (goal-pos).Magnitude <= 0.5 or self.NotSaved["Moving"] ~= currentnumber or  os.clock()-timestart >= timetotake+7
    -- if  os.clock()-timestart >= timetotake+7  then
    --    -- warn(self.Id,"has Yeilded")
    -- end
    -- if  self.NotSaved["Moving"] == currentnumber then
    -- self.Velocity.Move = nil
    -- self.NotSaved["Moving"] = nil
    -- end
    -- return (self.NotSaved["Moving"] == currentnumber ) and "Done" or "Stopped"
end
function entity:AddBodyVelocity(name,velocity)
    if velocity.Magnitude == 0 then return end 
    self.BodyVelocity = self.BodyVelocity or {}
    self.BodyVelocity[name] = velocity
    self.NotSaved["BodyVelocity"] = self.NotSaved["BodyVelocity"] or {}
    self.NotSaved["BodyVelocity"][name] = 0
end
function entity:UpdateBodyVelocity(dt)
    self.NotSaved["BodyVelocity"] = self.NotSaved["BodyVelocity"] or {}
    local one = dt*60
    for i,v in self.BodyVelocity or {} do
        if self.NotSaved["BodyVelocity"][i] >=2 then
            local sx,sy,sz = math.sign(v.X),math.sign(v.Y),math.sign(v.Z)
            local x,y,z = math.abs(v.X),math.abs(v.Y),math.abs(v.Z)
           --  if self.Data.Grounded  then
                -- x,y,z = 0,0,0
           --  else
                x -= .01*one
                y = 0
                z -= .01*one
           -- end
            x,y,z = math.max(x,0)*sx,math.max(y,0)*sy,math.max(z,0)*sz
            self.BodyVelocity[i] = Vector3.new(x,y,z)
        else
            self.NotSaved["BodyVelocity"][i] +=1
        end
        if self.BodyVelocity[i] and self.BodyVelocity[i].Magnitude == 0 then
            self.BodyVelocity[i] = nil
            self.NotSaved["BodyVelocity"][i] = nil
        end
        self.Velocity[i] = self.BodyVelocity[i]
    end
end
function entity:Gravity(dt)
    local entity = self
    local cx,cz = entity:GetQf().GetChunkfromReal(entity.Position.X,entity.Position.Y,entity.Position.Z,true)
    if not entity:GetData().GetChunk(cx,cz) or not entity["DoGravity"]  then return end 
    entity.Data.FallTicks = entity.Data.FallTicks or 0
    local max = entity.FallRate or 150
    local fallrate =(((0.99^entity.Data.FallTicks)-1)*max)/2
    entity.NotSaved.Tick = entity.NotSaved.Tick or 0 
    entity.NotSaved.Tick += dt
    if entity.Data.Grounded  or entity.NotSaved.NoFall   then -- or not entity.CanFall
        entity.Velocity.Fall = Vector3.new(0,0,0) 
        entity.Data.IsFalling = false
        entity.Data.FallTicks = 0
    elseif not entity.Data.Grounded  then
      --  if entity.NotSaved.Tick + dt >= 1/20 then
            entity.Data.FallTicks += dt*20
            entity.NotSaved.Tick = 0 
       -- end
        entity.Velocity.Fall = Vector3.new(0,fallrate,0) 
    end
end
function entity:Jump()
    if  self.NotSaved.Jumping or self["CanNotJump"] then return end
    local e 
    local jumpedamount =0 
    local jumpheight = (self.JumpHeight+.5 or 0) --1.25
    local muti = 4.5
    e = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        local jump = jumpheight*muti
        local datacondition = DateTime.now().UnixTimestampMillis/1000-(self.NotSaved["ExtraJump"] or 0) <=0.08
        if (self.Data.Grounded or datacondition)  and not self.NotSaved.Jumping then
            if datacondition then  self.NotSaved["ExtraJump"] = 0  end
            if jumpedamount == 0 then
                jumpedamount += jumpheight*(deltaTime)*muti
            end 
           end
        if jumpedamount > 0 and jumpedamount <=jumpheight  then
         jumpedamount += jumpheight*(deltaTime)*muti
         jump = jumpheight*muti
         self.NotSaved.Jumping = true
         self.NotSaved.Tick = 0
         else
            self.NotSaved.Jumping = false
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
    datahandler.RemoveEntity(self.Id)
    self:RemoveFromChunk()
    setmetatable(self,nil) self = nil
end
return entity