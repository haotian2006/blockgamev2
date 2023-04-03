local entity = {}
local https = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local genuuid = function()  return https:GenerateGUID(false) end 
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local maths = require(game.ReplicatedStorage.Libarys.MathFunctions)
local datahandler = require(game.ReplicatedStorage.DataHandler)
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local movers = require(game.ReplicatedStorage.EntityMovers)
local gs = require(game.ReplicatedStorage.GameSettings)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local anihandler = require(game.ReplicatedStorage.AnimationController)
local changeproperty = bridge.CreateBridge("ChangeEntityProperty")
local playani = bridge.CreateBridge("PlayAnimation")
local isClient = RunService:IsClient()
local EntityAttribute = require(game.ReplicatedStorage.Libarys.EntityAttribute)
local ts = game:GetService("TweenService")
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
entity.__index = function(self,key)
    local data,path = entity.IndexFromComponets(self,key)
    if data then
        return data,path
    end
    return entity[key]
end
function entity:IndexFromComponets(key,ignore)
    local comp = rawget(self,'Componets')
    local entitybeh = behhandler.GetEntity(self.Type)
    if type(comp) == "table" and entitybeh and entitybeh.component_groups  then
        for i,v in comp do
            if table.find(ignore or {},v) then continue end 
            if entitybeh.component_groups[v] and entitybeh.component_groups[v][key] then
                return entitybeh.component_groups[v][key],v
            end
        end
    end
    if entitybeh and entitybeh.components and entitybeh.components[key] then
        return entitybeh.components[key],true
    end
end
function entity:GetAllData(SPECIAL)
    local comp = self.Componets
    local entitybeh = behhandler.GetEntity(self.Type)
    local data = {}
    if SPECIAL then
        for key:string,value in qf.deepCopy(self) do
            if (key:split('.'))[1] == SPECIAL or not SPECIAL then
                data[key] = qf.deepCopy(self[key])
            end
        end
    else
        data = qf.deepCopy(self)
    end
    if entitybeh and entitybeh.components then
        for key:string,value in entitybeh.components do
            if (key:split('.'))[1] == SPECIAL or not SPECIAL then
                data[key] = qf.deepCopy(self[key])
            end
        end
    end
    if type(comp) == "table" and entitybeh and entitybeh.component_groups  then
        for i = #comp ,1,-1 do
            local v = comp[i]
            if entitybeh.component_groups[v] and entitybeh.component_groups[v] then
                for key,value in entitybeh.component_groups[v] do
                    if not SPECIAL or (key:split('.'))[1] == SPECIAL then
                        data[key] = qf.deepCopy(self[key])
                    end
                end
            end
        end
    end
    return data 
end
entity.SpecialNames = {
    Data = true,
    Type = true,
    Velocity = true,
    NotSaved = true,
    behaviors = true,
    CurrentSlot = true,
}
entity.NotClearedNames = {
    --Move = true
}
function entity.new(data)
    local self = data or {}
    setmetatable(self,entity)
    self.Id = data.Id and tostring(data.Id) or genuuid()
    self.Position = data.Position or Vector3.new()
    self.Type = data.Type or warn("Failed To Create Entity | No Entity Type Giving for:",self.Id) 
    if not data.Type then self:Destroy() return end 
    self.Velocity = self.Velocity or {}
    self.Data = data.Data or {}
    self.NotSaved = {}
    self.PlayingAnimations = data.PlayingAnimations or {}
    self.NotSaved["behaviors"] =  {}
    self.NotSaved.NoClear = {}
    return self
end
function entity:UpdateChunk() -- adds it self to a chunk or remove from one
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
function entity:UpdateIdleAni()-- plays idle ani
    local entitydata = resourcehandler.GetEntity(self.Type)
    if not entitydata or not entitydata.Animations or not entitydata.Animations["Idle"] then return end 
    local holdingitem = self:GetItemFromSlot(self.CurrentSlot or 1)
    holdingitem = type(holdingitem) == "table" and holdingitem[1] or ""
    if entitydata.Animations["HoldingItemIdle"] then
        if holdingitem == "" then
            self:PlayAnimation("Idle")
            self:StopAnimation("HoldingItemIdle")
        else
            self:PlayAnimation("HoldingItemIdle")
            self:StopAnimation("Idle")
        end
    else
        self:PlayAnimation("Idle")
    end
end
-- properties to keep same when updating entitys from the server (All Entities except lp)
local clientdata = {'Entity','Tweens','ClientAnim','LoadedAnis','VeiwMode','DidDeath'}
function entity:UpdateEntity(newdata)
    local checked = {}
    for i,v in self do
        checked[i] = true
        if table.find(clientdata,i) then continue end 
        if type(newdata[i]) == "table" and newdata[i].Type == 'EntityAttribute' then
            self[i](newdata[i].Data)
        else
            self[i] = newdata[i] 
        end
    end
    for i,v in newdata do
        if checked[i] then continue end 
        if type(v) == "table" and v.Type == 'EntityAttribute' then
            self[i] = EntityAttribute.create(v)
        else
            self[i] = v 
        end
    end
end
function entity:UpdateHandSlot(slot)
    self.CurrentSlot = slot 
end
-- properties to keep same when updating entitys from the server (local player)
entity.KeepSame = {"Position",'NotSaved',"Velocity",'HitBox',"EyeLevel","Crouching","PlayingAnimations","Speed","CurrentSlot",'VeiwMode','CurrentStates','Ingui','CurrentStates'}
function entity:UpdateEntityClient(newdata)
    for i,v in newdata do
        if table.find(entity.KeepSame,i) then continue end 
        if type(v) == "table" and v.Type == 'EntityAttribute' then
            if self[i] and self[i].EntityAttributes then
                self[i](v.Data)
            else
                self[i] = EntityAttribute.create(v)
            end
        else
            self[i] = v
        end
    end
end
function entity:VisuliseHandItem()
    if not isClient then warn("Client Only Function") return end 
    local Item = self.HoldingItem or {}
    local entity = self.Entity
    if not entity then return nil end 
    local attachment = entity:FindFirstChild("RightAttach",true)
    if not attachment or attachment:FindFirstChild(Item[1] or "") then return nil end 
    if Item[1] and Item ~= '' then
        attachment:ClearAllChildren()
        local item = Instance.new("Part")
        item.Size = Vector3.new(1,.1,1)
        item.Parent = attachment
        item.Name = Item[1]
        item.Material = Enum.Material.SmoothPlastic
        local surfacegui = Instance.new("SurfaceGui",item)
        surfacegui.Face = Enum.NormalId.Top
        local txt = Instance.new('TextLabel',surfacegui)
        txt.Size = UDim2.new(1,0,1,0)
        txt.TextScaled = true
        txt.Text = Item[1]
        local a = surfacegui:Clone()
        a.Parent = item
        a.Face = Enum.NormalId.Bottom
        a.TextLabel.Rotation = 180
        local weld = item:FindFirstChild("HandleAttach") or Instance.new("Motor6D")
        weld.Name = "HandleAttach"
        weld.Part0 = attachment.Parent
        weld.Part1 = item
        weld.C0 = attachment.CFrame*CFrame.new(0,0,-0.5)*CFrame.Angles(0,math.rad(-90),0)
        weld.Parent = item
        if self.VeiwMode == "First" then item.LocalTransparencyModifier = 1 end 
    else
        attachment:ClearAllChildren()
    end
end
function entity:UpdateModelPosition()-- Updates the Eye positions etc 
    if not isClient then warn("Client Only Function") return end 
    local ParentModel = self.Entity
    if not ParentModel then return end 
    local model = ParentModel:FindFirstChild("EntityModel")
    if  model then 
    ParentModel.PrimaryPart.Size = Vector3.new(self.HitBox.X,self.HitBox.Y,self.HitBox.X)*3
    local MiddleOffset = ParentModel.PrimaryPart.Size.Y-(ParentModel.PrimaryPart.Size.Y/2+model.PrimaryPart.Size.Y/2)
    local pos =ParentModel.PrimaryPart.Position 
    model.PrimaryPart.CFrame = CFrame.new(pos.X,pos.Y-MiddleOffset,pos.Z)
    local weld = ParentModel.PrimaryPart:FindFirstChild("EntityModelWeld")
    weld.C0 = CFrame.new(0,-MiddleOffset,0)
    end
    local eyeweld = ParentModel:FindFirstChild("Eye"):FindFirstChild("EyeWeld")
    local offset = self.EyeLevel
    if not eyeweld then return end 
    eyeweld.C0 = offset and CFrame.new( Vector3.new(0,offset/2,0)*3) or CFrame.new()
end
function entity:UpdatePosition(dt)
    local velocity = self:GetVelocity()
    self.NotSaved.ClearVelocity = true
    if not self.ClientControll or  ( RunService:IsClient() and self.ClientControll and self.ClientControll == tostring(game.Players.LocalPlayer.UserId) ) then 
        self:UpdateIdleAni()
        local p2 = interpolate(self.Position,self.Position+velocity,dt) 
        local e = velocity
        velocity = (p2-self.Position)
        local newp = CollisionHandler.entityvsterrain(self,velocity)
        local velocity2 = (newp-self.Position)
        local dir = newp - self.Position
        local length = 0
        if velocity.Y <= 0 and self.Crouching and self.NotSaved.LastG then
            local o = maths.newPoint(self.Position.X,self.Position.Z)
            local endp = maths.newPoint((self.Position+velocity).X,(self.Position+velocity).Z)
            local realp = maths.newPoint(newp.X,newp.Z)
            local xsidesame,ysidesame = qf.RoundTo(realp.x) == qf.RoundTo(endp.x),qf.RoundTo(realp.y) == qf.RoundTo(endp.y)
            local clonede = {HitBox = self.HitBox}--self:CloneProperties()
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
                    clonede.Position = Vector3.new(c.X,self.Position.Y,c.Y)
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
                        --print("None")
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
                        clonede.Position = Vector3.new(current.X,self.Position.Y,current.Y)
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
                        clonede.Position = Vector3.new(current.X,self.Position.Y,current.Y)
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
        if RunService:IsServer() then
         --   print(velocity.Magnitude,velocity2.Magnitude)
        end
        if qf.EditVector3(( newp - self.Position),"y",0):FuzzyEq(Vector3.zero,0.01) then
            if  self.NotSaved.LastUpdate and (os.clock()- self.NotSaved.LastUpdate)>.2 or RunService:IsClient()  then
                self:StopAnimation("Walk")
                self:SetState('Moving',false)
            end
        else
            self:PlayAnimation("Walk")
            self.NotSaved.LastUpdate = os.clock()
            self:SetState('Moving',true)
        end
        self.Position = newp--interpolate(self.Position,newp,dt) 
    end
    self.Data.Grounded = CollisionHandler.IsGrounded(self)
    self:SetState("OnGround",self.Data.Grounded)
    if  self.NotSaved["LastG"] and not self.Data.Grounded and not self.NotSaved.Jumping then
        self.NotSaved["ExtraJump"] = DateTime.now().UnixTimestampMillis/1000
    end
    self.NotSaved.LastG = self.Data.Grounded

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
function entity:GetItemFromSlot(slot)
    if self.inventory then
        return self.inventory[slot]
    end
    return ""
end
function entity:GetQf()-- returns quick functions module 
    return qf
end
function entity:GetData()
    return datahandler
end
function entity:Crouch(letgo:boolean)
    local dcby = self.CrouchLower or 0
    letgo = not letgo
    self.Crouching = letgo
    if not letgo then dcby *= -1 end 
    self.Position += Vector3.new(0,-dcby/2,0)
    self.HitBox = Vector2.new(self.HitBox.X, self.HitBox.Y-dcby)
    self.EyeLevel = self.EyeLevel - dcby
    if letgo then
        self:PlayAnimation("Crouch")
        self:SetState('Crouching',true)
    else
        self:StopAnimation("Crouch")
        self:SetState('Crouching',false)
    end
end
function entity:GetPropertyWithMulti(name)
    local muti = self[name] or 0
    for i,v in self.StateInfo or {} do
        if self.CurrentStates[i] then
            muti *= v[name] or 1
        end
    end
    return muti
end
function entity:GPWM(name)
    return self:GetPropertyWithMulti(name)
end
function entity:GetEyePosition()
    local eye = self.EyeLevel/2
    return self.Position + Vector3.new(0,eye,0)
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
function entity:SetNetworkOwner(player)
    self.ClientControll = player and tostring(player.UserId) or nil
end
function entity:SetBodyRotationFromDir(dir)
    self.bodydir = dir
end
function entity:SetHeadRotationFromDir(dir)
    self.headdir =  dir
end
local lp = Instance.new("Part")
lp.Size = Vector3.one
lp.Anchored = true
lp.Name = "AJAJAJAJA"
function entity:SetModelTransparency(value)
    if not isClient then warn("Client Only Function") return end 
    local model = self.Entity
    if RunService:IsServer() or not model then return end
    for i,v in model:GetDescendants() do
        if v:IsA("BasePart") and v.Name ~= "Middle" then
            v.LocalTransparencyModifier = value
        elseif v:IsA('GuiObject') then
            v.Transparency = value 
        elseif v:IsA("SelectionBox") then
            v.Transparency = value
        end
    end
end
function entity:UpdateRotationClient(debugmode)
    if self:GetState('Dead') then return end 
    if not isClient then warn("Client Only Function") return end 
    local Model = self.Entity
    if not resourcehandler.GetEntity(self.Type) then return end 
    local neck = resourcehandler.GetEntity(self.Type).Necks or {}
    local orimodel = resourcehandler.GetEntityModelFromData(self)
    local lastr = self.NotSaved.RotationFollow 
    if not Model or not next(neck) or not orimodel then return end
    local mainjoint = Model:FindFirstChild("MainWeld",true)
    local mainneck = Model:FindFirstChild("Neck",true)
    local neckjoints = {}
    if not mainjoint or not mainneck or not neck["Neck"]  then return end
    self.BodyLookingPoint = self.bodydir and self.Position + self.bodydir or self.BodyLookingPoint 
    self.HeadLookingPoint = self.headdir and self.Position + self.headdir or self.HeadLookingPoint 
    local lap = (self.HeadLookingPoint or self.Position+mainjoint.C0.LookVector)*gs.GridSize
    local bdp = (self.BodyLookingPoint or self.Position+mainjoint.C0.LookVector)*gs.GridSize
    local bodydir = (bdp-self.Position*gs.GridSize).Unit
    bodydir = Vector3.new(bodydir.X,0,bodydir.Z)*2
    bodydir = (bodydir == bodydir and bodydir.Magnitude ~= 0) and bodydir or mainjoint.C0.LookVector
    local lookAtdir = (lap -Model.Eye.Position).Unit
    lookAtdir = (lookAtdir == lookAtdir and lookAtdir.Magnitude ~= 0) and lookAtdir or mainneck.C0.LookVector
    if self.Name == "Npc1" then
        lp.Position = mainjoint.Part0.Position+bodydir*4
    end
    local _, ay,_ = maths.worldCFrameToC0ObjectSpace(mainjoint,CFrame.new(mainjoint.C0.Position,mainjoint.C0.Position+Vector3.new(bodydir.X,0,bodydir.Z))):ToOrientation()
    local hx,hy,hz = (CFrame.new(mainneck.C0.Position,mainneck.C0.Position +Vector3.new(lookAtdir.X,0,lookAtdir.Z))):ToOrientation()
    local agl = (maths.NegativeToPos(math.deg(hy))-maths.NegativeToPos(math.deg(ay)))+360
    agl %= 360
    local shouldrotateb,yy = false
    for i,v in neck do
        local v = Model:FindFirstChild(i,true)
        if v then
            neckjoints[v] = orimodel:FindFirstChild(i,true) 
        end
    end
    local mainneckangles = type(neck["Neck"][1]) == "table" and neck["Neck"][1] or neck["Neck"]
    if not maths.angle_between(agl,mainneckangles[1],mainneckangles[2]) then shouldrotateb = true end 
    local cf
    local flagA = maths.angle_between(agl,maths.ReflectAngleAcrossY(mainneckangles[2]),maths.ReflectAngleAcrossY(mainneckangles[1]))
    
    if shouldrotateb  and neck["Neck"] and not flagA   then
       local tuse = maths.GetClosestNumber(agl,mainneckangles)
       if math.abs(tuse - agl) > 2 then
        local agla = 90-mainneckangles[1]
        tuse = agla*-math.sign(agl-180)
       elseif tuse ==mainneckangles[1] then
        tuse = 10    
       else
        tuse = -10
       end
       local mx, my, mz = maths.worldCFrameToC0ObjectSpace(mainjoint,CFrame.new(mainjoint.C0.Position,mainjoint.C0.Position+bodydir)):ToOrientation()
       local bcf = CFrame.fromOrientation(mx,my,mz)
         cf = CFrame.new(mainjoint.C0.Position)*bcf*CFrame.fromOrientation(0,math.rad(tuse),0)
         mainjoint.C0 = cf
    else
        if flagA then bodydir = -bodydir end 
        local mx, my, mz = maths.worldCFrameToC0ObjectSpace(mainjoint,CFrame.new(mainjoint.C0.Position,mainjoint.C0.Position+bodydir)):ToOrientation()
         cf = CFrame.new(mainjoint.C0.Position)*CFrame.fromOrientation(mx,my,mz)
        mainjoint.C0 = cf
    end
   local upordown = math.sign(lookAtdir.Unit:Dot(Vector3.new(0,1,0)))
    for v,i in neckjoints do
        local maxleftright = type(neck[v.Name][1]) == "table" and neck[v.Name][1] or neck[v.Name]
        local maxupdown = type(neck[v.Name][1]) == "table" and neck[v.Name][2] 
        local xx, yy, zz = (maths.worldCFrameToC0ObjectSpace(v,CFrame.new(v.C0.Position,v.C0.Position+lookAtdir))*i.C0.Rotation:Inverse()):ToOrientation()
        local agly = (maths.NegativeToPos(math.deg(yy))+180)+360
        agly %= 360
        local aglx = (maths.NegativeToPos(math.deg(xx))+180)+360
        aglx %= 360
        if maxupdown and not maths.angle_between(aglx,maxupdown[1],maxupdown[2]) then
            xx =   math.rad(maths.GetClosestNumber(aglx,maxupdown)) 
        end
        if maxleftright and not maths.angle_between(agly,maxleftright[1],maxleftright[2]) and  v.Name ~= "Neck" then
            yy = math.rad(maths.GetClosestNumber(agly,maxleftright))
        end
        v.C0 = CFrame.new(v.C0.Position)*CFrame.fromOrientation(xx,yy,zz)*i.C0.Rotation:Inverse()
    end
end
function entity:TurnTo(Position,timetotake)
    local current = self.bodydir
    timetotake = timetotake or 0
    if not current or true then 
    self.BodyLookingPoint = Position
    task.wait(.1)
    if self.BodyLookingPoint ~= Position then return end 
    self.BodyLookingPoint = nil
    else
        --lp.Position = current*3
        current = self.Position + current
        local body = Vector2.new(self.Position.X,self.Position.Z)
        local t1,t3 = Vector2.new(current.X,current.Z),Vector2.new(Position.X,Position.Z)
        local rad = (t3-body).Magnitude
       -- print(t1,body)
        t1 = body + (t1-body).Unit*rad
       -- if t1 ~= t1 then t1 = Vector2.zero  end 
        local t1angle = -(math.deg(math.atan2(t1.Y-body.Y, t1.X-body.X))-90)
        local t3angle = -(math.deg(math.atan2(t3.Y-body.Y, t3.X-body.X))-90)
        local distance = math.abs(maths.AngleDifference(t1angle,t3angle))
        local speed = distance/timetotake
        local ctime = 0
        local currentdist = 0
        local hb
        local thread =coroutine.running()
        local newp = maths.GetXYfromangle(t3angle,rad,body)
        self.bodydir = (Vector3.new(newp.X,current.Y,newp.Y)-self.Position).Unit
       -- print(Vector3.new(newp.X,current.Y,newp.Z),"aaa")
        -- hb = RunService.Heartbeat:Connect(function(deltaTime)
        --     ctime += deltaTime
        --     currentdist += speed
        --     local y = maths.lerp_angle(t1angle,t3angle,math.clamp(ctime,0,.9))
        --     local newp = maths.GetXYfromangle(y,distance,body)
        --     self.BodyLookingPoint = Vector3.new(newp.X,self.BodyLookingPoint.Y,self.BodyLookingPoint.Z)
        --     if currentdist >= distance or ctime >= timetotake then coroutine.resume(thread) hb:Disconnect() end
        -- end)
        -- coroutine.yield()
    end
end
function entity:LookAt(Position,timetotake)
    timetotake = timetotake or 0
    self.HeadLookingPoint = Position
end
function entity:KnockBack(force,time)
    self.NotSaved.Tick = 0
    movers.Curve.new(self,force,time,nil,nil,false)
end
function entity:MoveTo(x,y,z)
    local new = require(game.ReplicatedStorage.EntityMovers).MoveTo.new(self,x,y,z,true)
    new:Init()
end
function entity:IsClientControl()
    if self.ClientControll then
        for i,v in game.Players:GetPlayers() do
            if v.UserId == tonumber(self.ClientControll) then
                return v,RunService:IsClient()
            end
        end
    end
    return nil,RunService:IsClient()
end
function entity:SetPosition(position)
    local plr,client = self:IsClientControl()
    if plr and not client then
        changeproperty:Fire(plr,self.Id,"Position",position)
    elseif client and plr == game.Players.LocalPlayer then
        self.Position = position
    else
        self.Position = position
    end
end
function  entity:LoadAnimation(Name)
    if not isClient then warn("Client Only Method") return end 
    return anihandler.LoadAnimation(self,Name)
end
function entity:PlayAnimation(Name,PlayOnce)
    if self:GetState('Dead') then return end 
    local plr,client = self:IsClientControl()
    if PlayOnce then 
        if not client then
            playani:FireAll(self.Id,Name)
        elseif client and plr == game.Players.LocalPlayer then
            playani:Fire(self.Id,Name)
            anihandler.PlayAnimationOnce(self,Name)
        else
            anihandler.PlayAnimationOnce(self,Name)
        end
    else
        if plr and not client then
            changeproperty:Fire(plr,self.Id,{"PlayingAnimations",Name},true)
        elseif client and plr == game.Players.LocalPlayer then
            self.PlayingAnimations[Name] = true
        else
            self.PlayingAnimations[Name] = true
        end
    end
end
function entity:StopAnimation(Name)
    local plr,client = self:IsClientControl()
    if plr and not client then
        changeproperty:Fire(plr,self.Id,{"PlayingAnimations",Name},false)
    elseif client and plr == game.Players.LocalPlayer then
        self.PlayingAnimations[Name] = false
    else
        self.PlayingAnimations[Name] = false
    end
end
function entity:SetBodyVelocity(name,velocity)
    self.BodyVelocity = self.BodyVelocity or {}
    self.BodyVelocity[name] = velocity
end
function entity:GetBodyVelocity(name)
    self.BodyVelocity= self.BodyVelocity or {}
    return self.BodyVelocity[name] 
end
function entity:UpdateBodyVelocity(dt)
    for i,v in self.BodyVelocity or {} do
        self.Velocity[i] = self.BodyVelocity[i]
    end
end
function entity:Gravity(dt)
    local entity = self
    local cx,cz = entity:GetQf().GetChunkfromReal(entity.Position.X,entity.Position.Y,entity.Position.Z,true)
    if not entity:GetData().GetChunk(cx,cz) or not entity["DoGravity"]  then return end 
    entity.Data.FallTicks = entity.Data.FallTicks or 0
    local max = entity.FallRate or 150
    local fallrate =  entity.Data.Gravity and entity.Data.Gravity or 0
    if math.floor(entity.Data.FallTicks or 0 ) > (entity.Data.LastFallTicks or 0) and false  then
        fallrate -= 0.08
        fallrate *= 0.9800000190734863
        entity.Data.LastFallTicks = math.floor(entity.Data.FallTicks)
    end
    if entity.Data.Grounded  or entity.NotSaved.NoFall or  entity.NotSaved.Jumping or (CollisionHandler.IsGrounded(self,true) and fallrate >0)  then -- or not entity.CanFall
        self:SetBodyVelocity("Gravity",Vector3.zero )
        entity.Data.IsFalling = false
        entity.Data.FallTicks = 0
        entity.Data.LastFallTicks = 0
        entity.Data.Gravity = 0
    elseif not entity.Data.Grounded  then
        if math.sign(fallrate) == -1 then 
            entity.Data.FallTicks += dt*20
        end
        fallrate -= 0.08/3
       -- fallrate *= 0.9800000190734863
        entity.Data.LastFallTicks = math.floor(entity.Data.FallTicks)
        self:SetBodyVelocity("Gravity",Vector3.new(0,fallrate*20,0) )
        entity.Data.Gravity = fallrate
    end
end
--[[
function entity:Gravity(dt)
    local entity = self
    local cx,cz = entity:GetQf().GetChunkfromReal(entity.Position.X,entity.Position.Y,entity.Position.Z,true)
    if not entity:GetData().GetChunk(cx,cz) or not entity["DoGravity"]  then return end 
    entity.Data.FallTicks = entity.Data.FallTicks or 0
    local max = entity.FallRate or 150
    --local fallrate =(((0.99^entity.Data.FallTicks)-1)*max)/2
    local fallrate = (392/5)*((98/100)^math.floor(entity.Data.FallTicks) - 1)
    if entity.Data.Grounded  or entity.NotSaved.NoFall or  entity.NotSaved.Jumping  then -- or not entity.CanFall
        self:SetBodyVelocity("Falling",Vector3.new(0,0,0) )
        entity.Data.IsFalling = false
        entity.Data.FallTicks = 0
    elseif not entity.Data.Grounded  then
            entity.Data.FallTicks += dt*20
        entity.Velocity.Fall = Vector3.new(0,fallrate,0) 
    end
end
]]
function entity:Jump()
    if  self.NotSaved.Jumping or self["CanNotJump"]  then return end
    local datacondition = DateTime.now().UnixTimestampMillis/1000-(self.NotSaved["ExtraJump"] or 0) <=0.08
    if not self.Data.Grounded and not datacondition  then return end 
    if datacondition then  self.NotSaved["ExtraJump"] = 0  end
    local e 
    local jumpedamount =0 
    local jumpheight = (self.JumpHeight or 0) --1.25
    local muti = 1
    local velocity = 0.42
    local start = os.clock()
    local tickspast = 0
    self:SetBodyVelocity("Gravity",Vector3.new(0,velocity*20,0) )
    self.Data.Gravity = velocity
    self.Data.Grounded = false
    if true then return end 
    e = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        tickspast += deltaTime*20
        local jump = velocity*muti
        local datacondition = DateTime.now().UnixTimestampMillis/1000-(self.NotSaved["ExtraJump"] or 0) <=0.08
        if (self.Data.Grounded or datacondition)  and not self.NotSaved.Jumping then
            if datacondition then  self.NotSaved["ExtraJump"] = 0  end
            if jumpedamount == 0 then
                jumpedamount += velocity*20*(deltaTime)*muti
            end 
           end
           
        if jumpedamount > 0 and jumpedamount <=jumpheight and not CollisionHandler.IsGrounded(self,true) then-- and (not self.Data.Grounded or jumpedamount<=jumpheight/10)
            if tickspast >= 1 then
                tickspast = 0
                velocity -=0.08
                velocity*=0.98
            end
         jumpedamount += velocity*(deltaTime)*20
         jump = velocity*20
         self.NotSaved.Jumping = true
         else
           -- print(CollisionHandler.IsGrounded(self,true))
            self.NotSaved.Jumping = false
             jump = 0
             jumpedamount = 0
             self.Velocity.Jump = Vector3.new()
             e:Disconnect()
           --  print(os.clock()-start)
        end
        local touse = jump--fps.Value>62 and (jump/deltaTime)/60 or jump
        self.Velocity.Jump =Vector3.new(0,touse,0)
    end)
end
function entity:Update(dt)

    self:UpdateChunk()
    self:UpdateBodyVelocity(dt)
    if (RunService:IsServer() and not self.ClientControll) or (RunService:IsClient() and self.ClientControll == tostring(game.Players.LocalPlayer.UserId)) then else return end 
    self:Gravity(dt)
    if self:GetState('Dead') then
        -- local a = self.Velocity["Gravity"]
        -- self.Velocity = {}
        -- self.Velocity['Gravity'] = a 
    end
    self:UpdatePosition(dt)
    if self:GetState('Dead') then self:OnDeath() return end 
    self.NotSaved = self.NotSaved or {}
    self.NotSaved.DeltaTime = dt
    self:DoBehaviors(dt)
end
function entity:OnHarmed(dmg)
    if not isClient then warn("Client Only Method") return end 
    local model = self.Entity
    if model then   
        model.Parent = workspace.DamagedEntities
        local g = workspace.DamagedEntities:FindFirstChildWhichIsA("Highlight") or resourcehandler.GetAsset("DamageHighlight")
        if g then
            g.Parent = workspace.DamagedEntities
            g.Name = 'DamageHighlight'
            g.Adornee = nil
            g.Adornee = workspace.DamagedEntities
        end
        if not self:GetState('Dead') and self.Health > 0 then 
            task.delay(.35,function()
                if not self:GetState('Dead') and self.Health > 0 then 
                    model.Parent = workspace.Entities
                else
                    self:OnDeath()
                end
            end)
        else
            self:OnDeath()
        end
    end
end
function entity:SetState(state,value)
    self.CurrentStates = self.CurrentStates or {}
    self.CurrentStates[state] = value
end
function entity:GetState(name)
    return self.CurrentStates and self.CurrentStates[name]
end
function entity:GetStateData(state,target)
    if target then
        return self.CurrentStatesInfo[state] and self.CurrentStatesInfo[state][target]
    end
    return self.CurrentStatesInfo[state]
end
function entity:OnDeath()
    if not isClient then return end 
    self:SetState('Dead',true) 
    local model = self.Entity
    if not model then return end 
    if self:IsClientControl() == game.Players.LocalPlayer and not game.Players.LocalPlayer.PlayerGui:FindFirstChild("DeathScreen") then
        game.ReplicatedStorage.Events.OnDeath:Fire()
    end
    if self.DidDeath then return end 
    self.DidDeath = true
    model.Parent = workspace.DamagedEntities
    local g = workspace.DamagedEntities:FindFirstChildWhichIsA("Highlight") or resourcehandler.GetAsset("DamageHighlight")
    if g then
        g.Parent = workspace.DamagedEntities g.Name = 'DamageHighlight'
        g.Adornee = nil g.Adornee = workspace.DamagedEntities end
    local weld = model:FindFirstChild('MainWeld',true)
    local entitydata = resourcehandler.GetEntityFromData(self)
    local deathani = self:LoadAnimation("Death")
    if weld and not deathani then
        ts:Create(weld,TweenInfo.new(.5),{C0 = weld.C0*CFrame.new(-model.HitBox.Size.Y/2,-model.HitBox.Size.Y/2,0)*CFrame.Angles(0,0,math.rad(90))}):Play()
    elseif deathani then
        deathani:Play()
        task.wait(deathani.Length * 0.99)
        deathani:AdjustSpeed(0)
    end
    self.PlayingAnimations = {}
    anihandler.UpdateEntity(self)
end
function entity:Destroy()
    datahandler.RemoveEntity(self.Id)
    if self.Entity then
        self.Entity:Destroy()
        self.Entity = nil
    end
    self:RemoveFromChunk()
    self:SetState("Dead",true) 
    self.Destroyed = true
    setmetatable(self,nil) self = nil
end
return entity