local entity = {}
local Debris = game:GetService("Debris")
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
local settings = require(game.ReplicatedStorage.GameSettings)
local ItemHandler = require(game.ReplicatedStorage.ItemHandler)
local changeproperty = bridge.CreateBridge("ChangeEntityProperty")
local playani = bridge.CreateBridge("PlayAnimation")
local isClient = RunService:IsClient()
local EntityAttribute = require(game.ReplicatedStorage.Libarys.EntityAttribute)
local ts = game:GetService("TweenService")
local Ray = require(game.ReplicatedStorage.Ray)
local proxy = require(game.ReplicatedStorage.Libarys.ProxyTable)
entity.Position = Vector3.new()
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
    if rawget(self,"__P") and rawget(self,"__P")[key] then
        return self.__P[key]
    end
    local data,path = entity.IndexFromComponets(self,key)
    if data then
        return data,path
    end
    return entity[key]
end
entity.__newindex= function(self,key,v)
    if self.__P[key] ~= v then
        rawget(self,"__Update")[key] = true
   end
    self.__P[key] = v
end
entity.__iter = function(self)
    return next,self.__P
end
function entity:rawGet(key)
    return rawget(self,"__P") and rawget(self,"__P")[key]
end
function entity:IndexFromComponets(key:any,ignore:{}|nil) : (any,boolean|string)
    local comp = entity.rawGet(self,"Componets")
    if key == "Type" then return entity.rawGet(self,"Type") end 
    local entitybeh = behhandler.GetEntity(self.Type)
    if type(comp) == "table" and entitybeh and entitybeh.component_groups  then
        for i,v in comp do
            if table.find(ignore or {},v) then continue end 
            if entitybeh.component_groups[v] and entitybeh.component_groups[v][key] ~= nil then
                return entitybeh.component_groups[v][key],v
            end
        end
    end
    if entitybeh and entitybeh.components and entitybeh.components[key] ~= nil then
        return entitybeh.components[key],true
    end
end
function entity:GetAllData(SPECIAL:boolean) : {}
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
    local real = {}
    real.__P = self
    real.__Update = {}
    setmetatable(real,entity)
    self.Id = data.Id and tostring(data.Id) or genuuid()
    self.Position = data.Position or Vector3.new()
    self.Type = data.Type or warn("Failed To Create Entity | No Entity Type Giving for:",self.Id,data) 
    if not data then return end 
    if not data.Type then real:Destroy() return end 
    self.Velocity = proxy.new(self.Velocity or {})
    self.Data = proxy.new(self.Data or {},true)
    self.NotSaved = proxy.new({},true)
    self.Componets = proxy.new(self.Componets or {})
    self.PlayingAnimations = proxy.new(self.PlayingAnimations or {})
    self.NotSaved["behaviors"] =  {}
    self.NotSaved.NoClear = {}
    self.Container = proxy.new(self.Container or {},true)
    self.CurrentStates = proxy.new(self.CurrentStates or {})
    real.__Last ={}
    return real
end
function entity:ClearUpdated()
    table.clear(self.__Update)
    for i,v in self.__P do
        if type(v) == "table" and v.ClearUpdated  then 
            v:ClearUpdated()
        end
        
    end
end
function entity:IsUpdated(key)
    if type(self[key]) == "table" then
        return self[key].__Update
    else
        return self.__Update[key]
    end
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
function entity:GetServerChanges()
    local ServerOnlyChanges = {Position = true,Headdir = true,Bodydir = true,PlayingAnimations = true,CurrentSlot = true,ViewMode = true,Ingui = true,CurrentStates = true,Crouching = true}
    for i,v in self.AllowedClientChanges or {} do
        ServerOnlyChanges[i] = v
    end
    return ServerOnlyChanges
end

-- properties to keep same when updating entitys from the server (All Entities except lp)
local clientdata = {'Entity','Tweens','ClientAnim','LoadedAnis','ViewMode','DidDeath'}
function entity:UpdateEntity(newdata)
    newdata = newdata or {}
    local checked = {}
    if newdata.Container then
        for i,v in newdata.Container do
            if type(newdata[i]) == "table" then
                if newdata[i].__type == 'EntityAttribute'then
                    if self.Container[i] then
                        self.Container[i]:Update( v.Data)
                    else
                        self.Container[i] = EntityAttribute.create( v)
                    end
                end
            else
                self.Container[i] = newdata[i] 
            end
        end
    end
    for i,v in newdata do
        if checked[i] then continue end 
        if type(v) == "table"  then
            if v.__type == 'EntityAttribute' then
                self[i] = EntityAttribute.create(v)
            else
                if not self[i] or type(self[i]) ~= "table" then
                    self[i] = v
                    continue
                end
                for i2,v in v do
                    if v == "__NULL__" then
                        self[i][i2] = nil
                    else
                        self[i][i2] = v
                    end
                end
            end
        else
            self[i] = v ~= "__NULL__" and v or nil
        end
    end
end
function entity:UpdateHandSlot(slot:number)
    self.CurrentSlot = slot 
end
-- properties to keep same when updating entitys from the server (local player)
entity.KeepSame = {"Position",'NotSaved',"Velocity",'Hitbox',"EyeLevel","Crouching","PlayingAnimations","Speed","CurrentSlot",'ViewMode','Ingui','CurrentStates','ClientIndex'}
function entity:UpdateEntityClient(newdata)
    newdata = newdata or {}
  --  print(newdata.HoldingItem and newdata.HoldingItem[1])
    if newdata.Container then
        for i,v in newdata.Container do
            if type(v) == "table" and v.__type == 'EntityAttribute' then
                if self.Container[i] then
                    self.Container.__P[i]:Update(v.Data)
                else
                    self.Container.__P[i] = EntityAttribute.create( v)
                end
            else
                self.Container[i] = v
            end
        end
    end
    for i,v in newdata do
        if i == 'Container' then continue end 
        if table.find(entity.KeepSame,i) then continue end 
        if type(v) == "table" then
            if v.__type == 'EntityAttribute'  then
                if self[i] and self[i].EntityAttributes then
                    self[i]:Update(v.Data)
                else
                    self.__P[i] = EntityAttribute.create(v)
                end
            else
                if not self[i] or type(self[i]) ~= "table" then
                    self[i] = v
                    continue
                end
                for i2,v in v do
                    if v == "__NULL__" then
                        self[i][i2] = nil
                    else
                        self[i][i2] = v
                    end
                end
            end
        else
            self[i] = v ~= "__NULL__" and v or nil
        end
    end      
end
local function CreateTexture(texture,face)
    local new
    if texture:IsA("Decal") or texture:IsA("Texture") or type(texture) == "string" then
        new = Instance.new("Decal")
        new.Texture = type(texture) == "string" and texture or texture.Texture
        new.Face = face
    elseif texture:IsA("SurfaceGui") then
        new = texture:Clone()
        new.Face = face 
    end

        return new
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
        local function  createPlaceHolder()
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
            return item
        end
        local function createitem()
            local sides = {Right = true,Left = true,Top = true,Bottom = true,Back = true,Front =true}
            local name = self:GetQf().DecompressItemData(Item[1],'T')
            local itemdata = resourcehandler.GetItem(name) 
            if itemdata  then
                local stuff = {}
                local texture = itemdata.Texture
                local mesh = type(itemdata.Mesh ) == "table" and itemdata.Mesh.Mesh or itemdata.Mesh 
                if not mesh then return end 
                mesh = mesh:Clone()
                if type(itemdata.Mesh ) == "table" then
                    for i,v in itemdata.Mesh do
                        if i == "Mesh" then continue end 
                        mesh[i] = v
                    end
                end
                if texture then
                    if type(texture) == "table" then
                        for i,v in texture do
                                table.insert(stuff,CreateTexture(v,i))
                        end
                    elseif type(texture) == "userdata" then
                        for v in sides do
                            table.insert(stuff,CreateTexture(texture,v))
                        end
                    end
                end
                for i,v in stuff do
                    v.Parent = mesh
                end
                mesh.Parent = attachment
                mesh.Name = Item[1]
                local handle = mesh:FindFirstChild("Handle",true) or mesh 
                local weld = mesh:FindFirstChild("HandleAttach",true) or Instance.new("Motor6D")
                weld.Name = "HandleAttach"
                weld.Part0 = attachment.Parent
                weld.Part1 = mesh
                weld.C0 = attachment.CFrame
                weld.C1 = handle.CFrame
                weld.Parent = mesh
                return mesh,1
            end
        end
        local item,a = createitem() or createPlaceHolder()
        for i,v in item.Parent:GetDescendants() do
            if v:IsA("BasePart") then
                v.Anchored = false 
                if self.ViewMode == "First" then v.LocalTransparencyModifier = 1 end 
            elseif v:IsA("Decal") or v:IsA("Texture") then
                if self.ViewMode == "First" then v.Transparency = 1 end 
            end
        end
    else
        attachment:ClearAllChildren()
    end
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
function entity:IsGrounded(IsTouchingCeil)
    return CollisionHandler.IsGrounded(self,IsTouchingCeil) 
end
function entity:IsSuffocating()
    return CollisionHandler.GetBlocksInBounds(self:GetEyePosition(),Vector3.new(self.Hitbox.X,.001,self.Hitbox.X)) 
end
function entity:GetItemFromSlot(slot:number)
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
function entity:GetSelf()
    return entity
end
function entity:CanCrouch(): boolean
    local itm = ItemHandler.GetItemData(type(self.HoldingItem)=="table" and self.HoldingItem[1] or "") 
    return self.CrouchLower and (not itm or (itm and itm.CanCrouch ~= false)) and not self.CannotCrouch
end
function entity:Crouch(letgo:boolean)
    if self.Crouching == not letgo then return end 
    local dcby = self.CrouchLower or 0
    letgo = not letgo
    self.Crouching = letgo
    if not letgo then dcby *= -1 end 
    if RunService:IsServer() or true then
        self.Hitbox = Vector2.new(self.Hitbox.X, self.Hitbox.Y-dcby)
        self.EyeLevel = self.EyeLevel - dcby
        self.Position = self.Position +Vector3.new(0,-dcby/2,0)
    end
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
function entity:GetEyePosition(): Vector3
    local eye = (self.EyeLevel or 0)/2
    return self.Position + Vector3.new(0,eye,0)
end
function entity:GetFeetPosition(): Vector3
    local ysize = (self.Hitbox.Y or 0)/2
    return self.Position - Vector3.new(0,ysize,0)
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

function entity:AddToNoClear(Name)
    self.NotSaved.NoClear = self.NotSaved.NoClear or {}
    self.NotSaved.NoClear[Name] = true
end
function entity:RemoveFromNoClear(Name)
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
function entity:SetNetworkOwner(player:Player)
    self.ClientControl = player and tostring(player.UserId) or nil
end
function entity:SetBodyRotationDir(dir)
    self.Bodydir = dir
end
function entity:SetHeadRotationDir(dir)
    self.Headdir =  dir
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
        if (v:IsA("BasePart") ) and v.Name ~= "Middle" then
            v.LocalTransparencyModifier = value
        elseif v:IsA('GuiObject') or v:IsA("Decal") or v:IsA("Texture") or v:IsA("SelectionBox") then
            v.Transparency = value 
        end
    end
end
function entity:UpdateModelPosition()-- Updates the Eye positions etc 
    if not isClient then warn("Client Only Function") return end 
    local ParentModel = self.Entity
    if not ParentModel then return end 
    local model = ParentModel:FindFirstChild("EntityModel")
    if  model then 
    ParentModel.PrimaryPart.Size = Vector3.new(self.Hitbox.X,self.Hitbox.Y,self.Hitbox.X)*3
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
    local JUMP
    local velocity = self:GetVelocity()
    self.NotSaved.ClearVelocity = true
    if RunService:IsServer() then
    end
    if not self.ClientControl or  ( RunService:IsClient() and self.ClientControl and self.ClientControl == tostring(game.Players.LocalPlayer.UserId) ) then 
        self:UpdateIdleAni()
        local p2 = interpolate(self.Position,self.Position+velocity,dt) 
        -- if RunService:IsClient()then
        --     local p = Instance.new("Part",workspace.HighLightStuff)
        --     p.Size = Vector3.new(1,1,1)
        --     game:GetService("Debris"):AddItem(p,3)
        --     p.Anchored = true
        --     p.Position = p2*3
        -- end
        local e = velocity
        velocity = (p2-self.Position)
        local newp,_,_
        newp,_,_,JUMP = CollisionHandler.entityvsterrain(self,velocity)
        local newp2 = newp
        local velocity2 = (newp-self.Position)
        local dir = newp - self.Position
        local length = 0
        if velocity.Y <= 0 and self.Crouching and self.NotSaved.LastG then
            local o = maths.newPoint(self.Position.X,self.Position.Z)
            local endp = maths.newPoint((self.Position+velocity).X,(self.Position+velocity).Z)
            local realp = maths.newPoint(newp.X,newp.Z)
            local xsidesame,ysidesame = qf.RoundTo(realp.x) == qf.RoundTo(endp.x),qf.RoundTo(realp.y) == qf.RoundTo(endp.y)
            local clonede = {Hitbox = self.Hitbox}--self:CloneProperties()
            o,realp =  o:ToVector2(),realp:ToVector2()
            local current = o
            local hit = false
            local last 
            local randombool = false
            if xsidesame and ysidesame then
                local v1 = (realp-current).Unit/20
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
                    length += 1/20
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
                    midpoint = midpoint:ToVector2()
                    local v1 = (midpoint - o).Unit/20
                    v1 = v1 ~= v1 and Vector2.zero or v1
                    local function checkandadd()
                        if hit then return end 
                        clonede.Position = Vector3.new(current.X,self.Position.Y,current.Y)
                        local a = CollisionHandler.IsGrounded(clonede)
                        if not a then  hit = true return end 
                        last = current
                        current +=v1
                        length +=1/20
                    end
                    checkandadd()
                    while length <= (midpoint - o).Magnitude and not hit do
                        checkandadd()
                    end
                    current = midpoint
                    checkandadd()
                    v1 = (realp-current).Unit/20
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
                    midpoint = midpoint:ToVector2()
                    local v1 = (midpoint - o).Unit/20
                    v1 = v1 ~= v1 and Vector2.zero or v1
                    local function checkandadd()
                        if hit then return end 
                        clonede.Position = Vector3.new(current.X,self.Position.Y,current.Y)--+Vector3.new(velocity.X,0,velocity.Z).Unit/10
                        local a = CollisionHandler.IsGrounded(clonede)
                        if not a then  hit = true return end 
                        last = current
                        current +=v1
                        length +=1/20
                    end
                    checkandadd()
                    while length <= (midpoint - o).Magnitude and not hit do
                        checkandadd()
                    end
                    current = midpoint
                    checkandadd()
                    v1 = (realp-current).Unit/20
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
                randombool = true
            end 
            if not randombool and not(newp-newp2):FuzzyEq(Vector3.zero,.001) then
                clonede.Position = self.Position
                clonede.Hitbox += Vector2.new(.01,0)
             newp = CollisionHandler.entityvsterrain(clonede,(newp-self.Position))
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
    local hit,b = CollisionHandler.IsGrounded(self)
   -- if isClient then print( b) end
    self.Data.Grounded = hit
    self:SetState("OnGround",self.Data.Grounded)
    if  self.NotSaved["LastG"] and not self.Data.Grounded and not self.NotSaved.Jumping then
        self.NotSaved["ExtraJump"] = DateTime.now().UnixTimestampMillis/1000
    end
    self.NotSaved.LastG = self.Data.Grounded
    if JUMP then
        self:Jump()
    end
end
function entity:UpdateBodyVelocity(dt)
    for i,v in self.BodyVelocity or {} do
        self.Velocity[i] = self.BodyVelocity[i]
    end
end
function entity:UpdateRotationClient()
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
    local BodyLookingPoint = self.Bodydir and self.Position + self.Bodydir or Vector3.zero
    local HeadLookingPoint = self.Headdir and self.Position + self.Headdir or Vector3.zero
    local lap = (HeadLookingPoint or self.Position+mainjoint.C0.LookVector)*gs.GridSize
    local bdp = (BodyLookingPoint or self.Position+mainjoint.C0.LookVector)*gs.GridSize
    local Bodydir = (bdp-self.Position*gs.GridSize).Unit
    Bodydir = Vector3.new(Bodydir.X,0,Bodydir.Z)*2
    Bodydir = (Bodydir == Bodydir and Bodydir.Magnitude ~= 0) and Bodydir or mainjoint.C0.LookVector
    local lookAtdir = (lap -Model.Eye.Position).Unit
    lookAtdir = (lookAtdir == lookAtdir and lookAtdir.Magnitude ~= 0) and lookAtdir or mainneck.C0.LookVector
    if self.Name == "Npc1" then
        lp.Position = mainjoint.Part0.Position+Bodydir*4
    end
    local _, ay,_ = maths.worldCFrameToC0ObjectSpace(mainjoint,CFrame.new(mainjoint.C0.Position,mainjoint.C0.Position+Vector3.new(Bodydir.X,0,Bodydir.Z))):ToOrientation()
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
       local mx, my, mz = maths.worldCFrameToC0ObjectSpace(mainjoint,CFrame.new(mainjoint.C0.Position,mainjoint.C0.Position+Bodydir)):ToOrientation()
       local bcf = CFrame.fromOrientation(mx,my,mz)
         cf = CFrame.new(mainjoint.C0.Position)*bcf*CFrame.fromOrientation(0,math.rad(tuse),0)
         mainjoint.C0 = cf
    else
        if flagA then Bodydir = -Bodydir end 
        local mx, my, mz = maths.worldCFrameToC0ObjectSpace(mainjoint,CFrame.new(mainjoint.C0.Position,mainjoint.C0.Position+Bodydir)):ToOrientation()
         cf = CFrame.new(mainjoint.C0.Position)*CFrame.fromOrientation(mx,my,mz)
        mainjoint.C0 = cf
    end
  -- local upordown = math.sign(lookAtdir.Unit:Dot(Vector3.new(0,1,0)))
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
    local current = self.Bodydir
    timetotake = timetotake or 0
    if not current or true then 
    self:SetBodyRotationDir((Position-self.Position))
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
        self.Bodydir = (Vector3.new(newp.X,current.Y,newp.Y)-self.Position).Unit
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
    self:SetHeadRotationDir((Position-self:GetEyePosition()))
end
function entity:KnockBack(force,time)
    self.NotSaved.Tick = 0
    --self:ApplyVelocity(force)
    movers.Curve.new(self,force,time,nil,nil,false)
end
function entity:MoveTo(x,y,z)
    local new = require(game.ReplicatedStorage.EntityMovers).MoveTo.new(self,x,y,z,true)
    new:Init()
    return new
end
function entity:GetClientController()
    if self.ClientControl then
        for i,v in game.Players:GetPlayers() do
            if v.UserId == tonumber(self.ClientControl) then
                return v,RunService:IsClient()
            end
        end
    end
    return nil,RunService:IsClient()
end
function entity:SetPosition(position)
    local plr,client = self:GetClientController()
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
    local plr,client = self:GetClientController()
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
    local plr,client = self:GetClientController()
    if plr and not client then
        changeproperty:Fire(plr,self.Id,{"PlayingAnimations",Name},false)
    elseif client and plr == game.Players.LocalPlayer then
        self.PlayingAnimations[Name] = false
    else
        self.PlayingAnimations[Name] = false
    end
end
function entity:ApplyVelocity(v:Vector3) 
    local y = if v.Y ~= 0 then 0.125*(v.Y) + 0.375 else 0 
    self:SetBodyVelocity("Gravity",Vector3.new(0,y,0) )
    self.Data.Gravity = y
    self.Data.Grounded = false
    self:SetBodyVelocity("DVelocity",Vector3.new(v.X,0,v.Z) )
end
function entity:UpdateVelocity(dt) 
    local v = self:GetBodyVelocity("DVelocity") or Vector3.zero
    local x,z = v.X,v.Z
    local xs = math.sign(x)
    local zs = math.sign(z)
    x,z = math.abs(x),math.abs(z)
    local decraseRate = self.DragRate or .008
    local change = false
    local tick = self.Data.DragTicks or 1
    if x>0 then
        x -=  decraseRate*tick*(60* dt)
        x= math.max(x,0)
        x*= xs
        change = true
    else
        x = 0
    end
    if z > 0 then
        z -=  decraseRate*tick*(60* dt)
        z = math.max(z,0)
        z *=zs
        change = true
    else 
        z = 0
    end
    if change then  self.Data.DragTicks += dt*20 else  self.Data.DragTicks = 0 end 
    self:SetBodyVelocity("DVelocity",Vector3.new(x,0,z) )
end
function entity:SetBodyVelocity(name,velocity)
    self.BodyVelocity = self.BodyVelocity or {}
    self.BodyVelocity[name] = velocity
end
function entity:GetBodyVelocity(name)
    self.BodyVelocity= self.BodyVelocity or {}
    return self.BodyVelocity[name] 
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
        if fallrate == 0 and self.CanSnapDown then
            local info = Ray.newInfo()
            info.IgnoreEntities = true
            info.RaySize = Vector3.new(.02,.02,.02)
            info.Increaseby = 0.05
            info.BreakOnFirstHit = true
            local ray = Ray.Cast(self.Position-Vector3.new(0,self.Hitbox.Y/2,0),-Vector3.new(0,(self.MinTpHeight or .5)+.1,0),info)
            if ray and ray.Objects[1]  then
                local hit = ray.Objects[1]
               
                if (hit.PointOfInt -ray.Origin).Magnitude <= (self.MinTpHeight or .5)+0.001  then
                    self.Position = Vector3.new(self.Position.X,hit.PointOfInt.Y+self.Hitbox.Y/2+.02,self.Position.Z)
                end
            end
        end
        fallrate -= 0.08/3*(60* dt)
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
function entity:Jump(override)
    if  self.NotSaved.Jumping or self["CanNotJump"] or CollisionHandler.IsGrounded(self,true)  then return end
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
    if (RunService:IsServer() and not self.ClientControl) or (RunService:IsClient() and self.ClientControl == tostring(game.Players.LocalPlayer.UserId)) then else return end 
    if self:GetState('Dead') then
        -- local a = self.Velocity["Gravity"]
        -- self.Velocity = {}
        -- self.Velocity['Gravity'] = a 
    end
    self:UpdatePosition(dt)
    self:UpdateVelocity(dt)
    self:Gravity(dt)
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
                if not self:GetState('Dead') and self.Health > 0 and dmg >=1 then 
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
    if not isClient or self.Health >0 then return end 
    self:SetState('Dead',true) 
    local model = self.Entity
    if not model then return end 
    if self.Id == tostring(game.Players.LocalPlayer.UserId) and not game.Players.LocalPlayer.PlayerGui:FindFirstChild("DeathScreen") then
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
        ts:Create(weld,TweenInfo.new(.5),{C0 = weld.C0*CFrame.new(-model.Hitbox.Size.Y/2,-model.Hitbox.Size.Y/2,0)*CFrame.Angles(0,0,math.rad(90))}):Play()
    elseif deathani then
        deathani:Play()
        task.wait(deathani.Length * 0.99)
        deathani:AdjustSpeed(0)
    end
    self.PlayingAnimations:Clear()
    anihandler.UpdateEntity(self)
end
local lvm = 127
local X_BITS = 0b0000_0001_1111_1100
local Z_BITS = 0b1111_1110_0000_0000
local function combine(x,y)
    local xs = x < 0 and 0 or 1
    local ys = y < 0 and 0 or 1
    return bit32.band(bit32.lshift(math.abs(x), 2), X_BITS)+ bit32.band(bit32.lshift(math.abs(y), 9), Z_BITS)+ bit32.band(bit32.lshift(ys, 1), 0b10)+xs
end
local function decombine(i)
    local xs=   bit32.extract(i, 0, 1) == 1 and 1 or -1
    local ys =  bit32.extract(i, 1, 1) == 1 and 1 or -1
    return bit32.extract(i, 2, 7)*xs,bit32.extract(i, 9, 7)*ys
end
local function getENCODEDlv(d)
    local mag = d.Magnitude
    local unit = d.Unit
    local x,y,z = unit.X,unit.Y,unit.Z
    x = math.floor(x*lvm)
    y =math.floor(y*lvm)
    z = math.floor(z*lvm)
    local s1 = combine(x,y)
    local s2 = combine(z,math.clamp(mag,-lvm,lvm))
    return Vector2int16.new(s1,s2)
end
local function getDECODEDlv(d)
    local x,y = decombine(d.X)
    local z,m = decombine(d.Y)
    return Vector3.new(x,y,z)/lvm*m
end
function entity:ENCODE(Changed) 
    local posvector
    local chunkvector 
    local hdlv 
    local bdlv 
    local c = false
    if Changed.Chunk then
        c = true
        chunkvector = self.Chunk
        Changed.Chunk = nil
    end
    if Changed.Position then
        c = true
        local p = Changed.Position
        local cx = math.floor(( math.floor(p.X))/settings.ChunkSize.X)
        local cz = math.floor(( math.floor(p.Z))/settings.ChunkSize.X)
        local lx,ly,lz = p.X%settings.ChunkSize.X,p.Y,p.Z%settings.ChunkSize.X
        local c= Vector2.new(cx,cz)
        if self.Type == "Npc" then
           -- warn(c,Vector3.new(lx,ly,lz),p)
        end
        lx= math.floor(lx*4050)
        ly = math.floor(math.clamp(ly,-300,300)*100+0.5)
        lz= math.floor(lz*4050)
        posvector = Vector3int16.new(lx,ly,lz)
        if self.Chunk ~= c or true then
            chunkvector = c

            Changed.Chunk = nil
        end
        Changed.Position = nil
    end
    if Changed.Headdir then
        c = true
        if self.Type == "Npc" then 
          --  print( Changed.Headdir)
         end
        hdlv =  getENCODEDlv(Changed.Headdir)
        Changed.Headdir = nil
    end
    if Changed.Bodydir then
        c = true
        bdlv = getENCODEDlv(Changed.Bodydir)
        Changed.Bodydir = nil
    end
    return c,{posvector or false,chunkvector or false,hdlv or false,bdlv or false}
end
function entity:DECODE(data)
    local new = {}
    local posvector
    local chunkvector 
    local hdlv 
    local bdlv 
    local aaa = false
    if data[2] then
        chunkvector = data[2]
       if RunService:IsClient() and data[5] == 2 then
       -- print(chunkvector)
        aaa = true
       end
    end
    if data[1] then
        --local ly,lx,lz= data[1].Y,decombine(data[1].X)
        local Lposvector = Vector3.new(data[1].X/4050,data[1].Y/100,data[1].Z/4050)
        local chunk = chunkvector or self.Chunk
        posvector = qf.convertchgridtoreal(chunk.X,chunk.Y,Lposvector.X,Lposvector.Y,Lposvector.Z,true)
        if aaa then
           -- print(posvector,Lposvector)
        end
    end
    if data[3] then
        hdlv = getDECODEDlv(data[3])
        if self.Type == "Npc" then 
          --  print( hdlv)
         end
    end
    if data[4] then
        bdlv =getDECODEDlv(data[4])
    end
    return {Position = posvector,Chunk = chunkvector,Headdir = hdlv, Bodydir = bdlv}
end 
function entity:Destroy()
    datahandler.RemoveEntity(self.Id)
    if self.Entity then
        self.Entity:Destroy()
        self.Entity = nil
    end
    for i,v in entity do
        if type(v) == "table" then
            if type(v["Destroy"]) == "function" then
                v["Destroy"](v)
            end
        end
    end
    self:RemoveFromChunk()
    self:SetState("Dead",true) 
    self.Destroyed = true
end

return entity