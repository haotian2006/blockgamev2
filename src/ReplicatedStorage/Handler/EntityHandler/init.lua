local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local IS_CLIENT = RunService:IsClient()
local IS_SERVER = not IS_CLIENT
local LOCAL_PLAYER = game.Players.LocalPlayer or {UserId = "NAN"}


local Signal = require(game.ReplicatedStorage.Libs.Signal)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local Chunk = require(game.ReplicatedStorage.Chunk)
local MathUtils = require(game.ReplicatedStorage.Libs.MathFunctions)
local Animator = require(script.Animator)
local Holder = require(script.EntityHolder)
local Utils = require(script.Utils)
local CollisionHandler = require(script.EntityCollisionHandler)
local EntityTaskReplicator = require(script.EntityReplicator.EntityTaskReplicator)
local Container = require(game.ReplicatedStorage.Handler.Container)
local EntityContainerManager = require(script.EntityContainerManager)
local Data = require(game.ReplicatedStorage.Data)
local ItemHandler = require(game.ReplicatedStorage.Handler.Item)
local FieldType = require(script.EntityFieldTypes)
local CommonTypes = require(game.ReplicatedStorage.Core.CommonTypes)
local Runner = require(game.ReplicatedStorage.Runner)
local ClientUtils = require(script.ClientUtils)
local ServerContainer 


local DamagedFolder 
local NormalFolder = workspace:FindFirstChild("Entities")

if IS_CLIENT then
    local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
    DamagedFolder = Instance.new("Model",workspace)
    DamagedFolder.Name = "Entities_Damaged"
    task.spawn(function()
        ResourceHandler.wait()
        local DamageHighlighter = ResourceHandler.getAsset("DamageHighlight")
        if DamageHighlighter then
            DamageHighlighter:Clone().Parent = DamagedFolder
        end
    end)
else
    ServerContainer = require(game.ServerStorage:WaitForChild("core").ServerContainer)
end

local OwnersExists = Utils.ownerExists

local slerp = MathUtils.slerpAngle 

local Entity = {}
EntityTaskReplicator.Init(Entity)
Utils.Init(Entity) 
CollisionHandler.Init(Entity)
Holder.init(Entity)

Entity.FieldTypes = FieldType
Entity.Container = EntityContainerManager
Entity.Animator = Animator
Entity.Utils = Utils


Entity.onDeath = function(x,y) end  -- Werid roblox type error

--DEFAULTS
Entity.Gravity = 32--9.81
Entity.Speed = 0
Entity.RotationSpeedMultiplier = 12--6*2

--CONSTANDS
local DEFAULT_DEATH_TIME = 10
local NILVALUE = {"__NILVALUE__"}
local DEFAULTS = {"__DEFAULTS__"}

local UpdateCallbacks = {
    Position = function(self)
        Entity.updateChunk(self)
    end,
    Health = function(self,changed)
        local last = Entity.get(self, "Health")
        if IS_CLIENT then
            local model = self.model
            if (changed < last) and model then
                local lastThread = Entity.getTemp(self, "damageThread")
                if lastThread and coroutine.status(lastThread) == "running" then
                    task.cancel(lastThread)
                end
                model.Parent = DamagedFolder
                local t = task.delay(.3, function()
                    if model.Parent ~= DamagedFolder then return end 
                    model.Parent = NormalFolder
                end)

                Entity.setTemp(self, "damageThread",t)
            end
        end
        if (changed or 1) <= 0 then
            Entity.onDeath(self)
        end
    end,
    died = function(self,value)
        if value then
            Entity.onDeath(self)
        end
    end
}

function Entity.new(type:string,ID,from)
    ID = ID and tostring(ID)
    local info = BehaviorHandler.getEntity(type)
    if not info then return warn(`Entity '{type}' does not exist`) end 
    local self = {}
    self.Type = type 
    self.Guid = ID or HttpService:GenerateGUID(false)
    self.__main = info.components or {}
    self.__velocity = {}
    self.__components = {}
    self.__changed = {}
    self.__animations = {}
    self.__cachedData = {}
    self.__localData = {}
    
    self.__IsEntity = true
    self.Holding = ""
    self.Position = Vector3.zero
    self.Grounded = true
    self.Rotation = 0 
    self.HeadRotation = Vector2.zero
    if not from then 
        Entity.initialize(self)
        return self 
    end 
    
    for i,v in from do
        self[i] = v
    end
    Entity.initialize(self)
    return self
end

function Entity.fromData(data)
    return  Entity.new(data.Type,data.Guid,data)
end

function Entity.initialize(self)

    for i,component in self.__components do
        table.clear(self.__cachedData )
        local entityData =  BehaviorHandler.getEntity(self.Type)
        local componentData = entityData.component_groups[component]
        if not componentData then 
            warn(`component {component} is not a member of {self.Type}`)
            table.remove( self.__components,i)
            return
        else
            componentData.Name = component 
        end 

        self.__components[i] = componentData
    end

    if IS_SERVER then
        self.__containerUpdate = function()
            Entity.setSlot(self, self["Slot"])
        end
        EntityContainerManager.init(self)
    else
        self.__loadedAnimations = {}
    end
    Entity.updateChunk(self)
    local health = Entity.get(self, "Health")
    

    if (health or 1) <= 0 or self.died then
        Entity.onDeath(self)
    end
end


function Entity.addComponent(self,component,index)
    table.clear(self.__cachedData )
    local entityData =  BehaviorHandler.getEntity(self.Type)
    local componentData = entityData.component_groups[component]
    if not componentData then 
        warn(`component {component} is not a member of {self.Type}`) 
        return
    end 
    componentData.Name = component
    Entity.removeComponent(self,component)
    table.insert(self.__components,index or 1,componentData)
    self.__changed["__components"] = true
    if IS_SERVER then
        EntityContainerManager.changedComponents(self)
    end
end

function Entity.hasComponent(self,component)
    for i,v in self.__components do
        if v.Name == component then
            return i
        end
    end
    return 
end

function Entity.removeComponent(self,name)
    for i,v in self.__components do
        if v.Name == name then
            table.clear(self.__cachedData )
            table.remove(self.__components,i)
            self.__changed["__components"] = true
        end
    end
    if IS_SERVER then
        EntityContainerManager.changedComponents(self)
    end
end
--//Get/setters
function Entity.hold(self,Item)
    local lastHold = self.__localData["Holding"]
    if ItemHandler.equals(lastHold,Item) then return end 
    local Holding = self.Holding
    if Entity.isOwner(self,LOCAL_PLAYER) then
        ItemHandler.onDequip(Holding,self)
    end

    Entity.set(self, "Holding", Item or "")

    if Entity.isOwner(self,LOCAL_PLAYER) then
        ItemHandler.onEquip(Item,self)
    end
    self.__localData["Holding"] = Item
end

function Entity.getHolding(self)
    local holding = self.Holding 
    return if holding == "" then nil else holding
end

function Entity.setSlot(self,slot)
    slot = slot or ""
    self.Slot = slot
    local container, index = slot:match("^(.-)%.([^%.]+)$")
    if not container then
        Entity.hold(self,"")
        return
    end

    local containerToLook = EntityContainerManager.getContainer(self,container)
    if not containerToLook then
        Entity.hold(self,"")
        return
    end
    local Item = Container.get(containerToLook, tonumber(index)) or {}
    Entity.hold(self,Item[1] or "")
end

function Entity.getSlot(self)
    local slot =  self.Slot or ""

    local container, index = slot:match("^(.-)%.([^%.]+)$")
    local idx = tonumber(index)
    if not container then
        return "",idx,container
    end

    local containerToLook = EntityContainerManager.getContainer(self,container)
    if not containerToLook then
        return "",idx
    end
 
    local Item = Container.get(containerToLook, idx) or {}
    Entity.hold(self,Item[1] or "")
    return Item,idx,containerToLook
end

function Entity.getTemp(self,key)
    return self.__localData[key]
end

function Entity.setTemp(self,key,value)
    self.__localData[key] = value
end

function Entity.getCache(self)
    return self.__cachedData
end

function Entity.clearCache(self)
    table.clear(self.__cachedData)
end

function Entity.getMethod(self:CommonTypes.Entity,method,cannotBeBase)
    local info = BehaviorHandler.getEntity(self.Type)
    if not info or not info.methods then return end 
    return info.methods[method] or (not cannotBeBase and Entity[method])
end

function Entity.getAndCache(self,string)
    if self[string] ~= nil then
        return self[string] 
    end
    local cached = self.__cachedData[string]
    if not cached then
        local data,isDefault = Entity.get(self,string) 
        if data == "NIL" then
            data = NILVALUE
        end
        self.__cachedData[string] = isDefault and DEFAULTS or data
        return data
    elseif cached == DEFAULTS then
        return Entity[string]
    elseif cached == NILVALUE then
        return 
    end
    return cached
end

function Entity.get(self,string) 
    if self[string] ~= nil then
        return self[string]
    end
    if #self.__components > 0 then
        for i,v in self.__components do
            if v[string] ~= nil then 
                return v[string]
            end
        end
    end
    if self.__main[string] ~= nil then 
        return self.__main[string]
    end
    return Entity[string],true
end

function Entity.set(self,key,value)
    if self[key] == value then
       return false
    end
    self.__changed[key] = IS_SERVER and true or nil
    local callBacks = UpdateCallbacks[key]
    if callBacks then
        callBacks(self,value)
    end
    local Signals = self.__signals 
    if Signals and Signals[key] then
        local last = Entity.get(self, key)
        Signals[key]:Fire(value,last)
    end
    self[key] = value
    return true
end

function Entity.getPropertyChanged(self,property):CommonTypes.ProtectedEvent<any,any>
    local Signals = self.__signals or {}
    self.__signals = Signals
    if Signals[property] then
        return Signals[property].Event
    end
    local s = Signal.protected()
    Signals[property] = s
    return s.Event
end
do

local function convertToV3(vector)
    if typeof(vector) == "Vector2" then
            return Vector3.new(vector.X,vector.Y,vector.X)
    end
    return vector
end

function Entity.getHitbox(self)
    local HString = "Hitbox"
    if self[HString] then
        return convertToV3(self[HString])
    end
    local Cahced = self.__cachedData[HString]
    if Cahced then
        if typeof(Cahced) == "Vector2" then
            local v3 = Vector3.new(Cahced.X,Cahced.Y,Cahced.X)
            self.__cachedData[HString] = v3
            return v3
        end
        return Cahced
    end

    local HitBox = Entity.get(self,HString)
    HitBox = convertToV3(HitBox)
    self.__cachedData[HString] = HitBox
    return HitBox
end
    

function Entity.rawSet(self,key,value)
    self[key] = value
end

function Entity.getTotalVelocity(self):Vector3
    local x,y,z = 0,0,0
    for i,v in self.__velocity do
        if typeof(v) == "Vector3" and v == v then
            x+= v.X
            y+= v.Y
            z+= v.Z 
        end
    end
    if x == 0 then
      --  x = -0.00000001
    end
    if z == 0 then
       -- z = -0.00000001
    end
    return Vector3.new(x,y,z)
end

local MAX_MAG = 1000
local MAX_VECTOR = Vector3.one*MAX_MAG
local MIN_VECTOR = Vector3.one*-MAX_MAG
function Entity.setVelocity(self,name,vector:Vector3?)
    if vector == Vector3.zero or vector ~= vector then
        vector = nil
    end
    if vector and vector.Magnitude> MAX_MAG then
        vector = vector:Max(MIN_VECTOR):Min(MAX_VECTOR)
    end
    if IS_SERVER and OwnersExists(self) then
        EntityTaskReplicator.doTask(self, "SetVelocity",true,name,vector)
        return
   end
    self.__velocity[name] = vector
end

function Entity.getVelocity(self,name)
    return self.__velocity[name]
end

function Entity.applyVelocity(self,velocity)

    if IS_SERVER and OwnersExists(self) then
        
         EntityTaskReplicator.doTask(self, "applyVelocity",true,velocity)
         return
    end
    local current = Entity.getVelocity(self,"Physics") or Vector3.zero
    Entity.setVelocity(self,"Physics",current+velocity)
end

function Entity.setPosition(self,pos)
    Entity.set(self, "Position", pos)
end

function Entity.setMoveDirection(self,Direction)
    if Direction ~= Direction then
        Direction = Vector3.zero
    end
    Utils.followMovement(self,Vector2.new(Direction.X,Direction.Z).Unit)
    self.moveDir = Direction
end

function Entity.setDespawnTime(self,time)
    self.DespawnTime = time
end

function Entity.disableDespawnTimer(self,time)
    self.DespawnTime = -9999999
end

function Entity.getMoveDirection(self,Direction)
 return self.moveDir
end
end
--@Override
function Entity.getSpeed(self,isBase)
    if not isBase then
        local method = Entity.getMethod(self,"getSpeed",true)
        if method then 
            return method(self)
        end 
    end
    return Entity.get(self,"Speed")
end

function Entity.takeDamage(self,damage,isBase)
    if not isBase then
        local method = Entity.getMethod(self,"takeDamage",true)
        if method then 
            return method(self,damage)
        end 
    end
    local Health = Entity.get(self, "Health")
    if Health then 
        Entity.set(self, "Health", Health-(damage or 0))
    end 
    return true
end

--4.9


--//OwnerShip
Entity.ownerExists = OwnersExists
Entity.isOwner = Utils.isOwner
Entity.getOwner = Utils.getOwner

function Entity.setOwner(self,player:Player | nil)
     self.__ownership = player and player.UserId
     self.__changed["__ownership"] = true
     self.__localData["Owner"] = nil 
end
--//StateHandler (Might disable this)
function Entity.setState(self,state,value)
    self.__states[state] = value
end

function Entity.getState(self,state)
    return self.__states[state] 
end

--//Other
function Entity.jump(self,JumpPower)
    if not self.Grounded or  CollisionHandler.isGrounded(self,true) or self.__localData.Jumped  then return end
    self.__localData.Jumped = true 
    local bodyVelocity = Entity.getVelocity(self,"Physics") or Vector3.zero
    JumpPower = JumpPower or Entity.get(self,"JumpPower") or 0
    Entity.setVelocity(self,"Physics",bodyVelocity + Vector3.new(0,JumpPower,0))
    self.Grounded = false
end

function Entity.isType(entity,type)
    return entity.Type == type 
end

function Entity.isDead(self)
    if not self then return true end 
    return self.died or self.__destroyed or false
end

function Entity.canCrouch(self,unCrouch)
    if unCrouch and CollisionHandler.isGrounded(self,true) or self.died then
        return false
   end
   --More checks later
   return true 
end

function Entity.crouch(self,isDown,fromClient)
    if self.died then return end 
    local CrouchHeight = Entity.get(self,"CrouchLower")
    if not CrouchHeight then return end 
    self.Crouching = self.Crouching or false
    if isDown~=nil and self.Crouching == isDown then return end 
    self.Crouching = not self.Crouching
    local currentHitBox = Entity.getHitbox(self)
    local EyeLevel = Entity.get(self,"EyeLevel")
    if self.Crouching then
        self.Hitbox = Vector2.new(currentHitBox.X, currentHitBox.Y-CrouchHeight)
        self.EyeLevel = EyeLevel-CrouchHeight
        if not  fromClient then 
            Entity.set(self,"Position",self.Position+Vector3.new(0,-CrouchHeight/2,0))
        end
        Animator.playLocal(self,"Crouch",true)
    else
        self.Hitbox = Vector2.new(currentHitBox.X, currentHitBox.Y+CrouchHeight)
        self.EyeLevel = EyeLevel+CrouchHeight
        if not fromClient then 
            Entity.set(self,"Position",self.Position+Vector3.new(0,CrouchHeight/2,0))
        end
        Animator.stopLocal(self,"Crouch",nil)
    end
    if not fromClient or IS_SERVER then
        EntityTaskReplicator.doTask(self,"Crouch",not fromClient and IS_SERVER,self.Crouching,true)
    end
end

--//Updates
function Entity.updateChunk(self)
    local chunk = Utils.getChunk(self)
    if chunk ~= self.Chunk or not self.__isPart then
        if self.Chunk ~= nil then
            local OldChunk = Data.getChunkFrom(self.Chunk)
            if OldChunk then
                self.__isPart = nil
                Chunk.removeEntity(OldChunk, self)
            end
        end
        if IS_SERVER and not self.__NetworkId then 
            self.Chunk = chunk
            return 
        end 
        local newChunk =  Data.getChunkFrom(chunk)
        if newChunk then
            self.__isPart = true
            Chunk.addEntity(newChunk, self)
        end
        self.Chunk = chunk
    end
end

function Entity.updateTurning(self,dt)
    if self.died then return end 
    local targetHead = self.__localData.HeadRotation
    local targetBody = self.__localData.Rotation
    local head,body = self.HeadRotation,self.Rotation
    local multi = Entity.getAndCache(self,"RotationSpeedMultiplier")
    dt*=multi
    if dt>1 then dt = 1 end 
    if targetBody then 
        local reached 
        self.Rotation,reached = slerp(body,targetBody,dt)   
        if reached then  
            self.__localData.Rotation= nil 
        end 

    end
    if targetHead then
        if IS_CLIENT and false  then
            local dR = (targetBody or self.Rotation )-self.Rotation
            self.HeadRotation = Vector2.new(targetHead.X+dR,targetHead.Y)
            self.__localData.HeadRotation = nil
        else
            local x,_x =  slerp(head.X,targetHead.X,dt)
            local y,_y =slerp(head.Y,targetHead.Y,dt)

            self.HeadRotation = Vector2.new(x,y)
            if _x and _y then
                self.__localData.HeadRotation = nil
            end
        end
    end

end

function Entity.updatePosition(self,dt)
    if Entity.isOwner(self,LOCAL_PLAYER) then 
        local velocity = Entity.getTotalVelocity(self)
        if velocity == Vector3.zero and not Animator.isPlaying(self,"Walk")  then 
            return Vector3.zero,Vector3.zero,false
        end
       -- self:UpdateIdleAni()
        local p2 = self.Position+velocity*dt--self.Position:Lerp(self.Position+velocity,dt) 
        --local e = velocity
        velocity = (p2-self.Position)
        local newPosition,normal,blockdata,shouldJump = CollisionHandler.entityVsTerrain(self,velocity)
        if self.Crouching and velocity.Y == 0 then
            local newP,n = CollisionHandler.stayOnEdge(self,newPosition)
            newPosition = newP
            normal = n or normal
        end 
        local directionVector = newPosition - self.Position
        if Vector3.new(directionVector.X,0,directionVector.Z):FuzzyEq(Vector3.zero,0.001) then
            if  self.__localData.LastUpdate and (os.clock()- self.__localData.LastUpdate)>.018  then
               if Animator.isPlaying(self,"Walk") then
                Animator.stop(self,"Walk",.1)
               end
            end
        elseif not self.died then 
            local speed = (newPosition*Vector3.new(1,0,1) - self.Position*Vector3.new(1,0,1)).Magnitude/dt/(Entity.getAndCache(self,"Speed"))
            if not Animator.isPlaying(self,"Walk") then
                Animator.play(self,"Walk",true)
            end
            if speed >=0.05 then
                Animator.adjustSpeed(self,"Walk",speed)
            end
            -- self:PlayAnimation("Walk")
          self.__localData.LastUpdate = os.clock()
            -- self:SetState('Moving',true)
        end
        self.Position = newPosition--interpolate(self.Position,newp,dt) 
        return directionVector,normal,shouldJump
    end
    return
end

function Entity.updateGrounded(self,dt,shouldJump)
    local isGrounded,b = CollisionHandler.isGrounded(self)
    self.Grounded = isGrounded
end

function Entity.updateDespawn(self,dt)
    local t = self.DespawnTime
    if not t then
        t = Entity.get(self, "DespawnTime") or -9999999
    end
    if t == -1 or t == -9999999 then
        self.DespawnTime= t
        return
    end
    t-=dt
    self.DespawnTime= t
    if t <= 0 then
        Entity.destroy(self)
    end
end

function Entity.updateGravity(self,dt)
    local bodyVelocity = Entity.getVelocity(self,"Physics") or Vector3.zero
    local yValue = 0
    local FramesInAir = self.FramesInAir or 0
    if not self.Grounded and (not CollisionHandler.isGrounded(self,true) or FramesInAir == 0) then
        local Gravity = Entity.get(self,"Gravity")
        yValue = bodyVelocity.Y + (-Gravity)*dt
        FramesInAir = FramesInAir +1
    else 
        if FramesInAir == 0 then
            return
        end
        FramesInAir = 0 
    end
    self.FramesInAir  = FramesInAir
    Entity.setVelocity(self,"Physics",Vector3.new(bodyVelocity.X,yValue,bodyVelocity.Z))
    self.__localData.Jumped = nil
end

function Entity.updateMovement(self,dt,normal)
    local bodyVelocity = Entity.getVelocity(self,"Physics") or Vector3.zero
    local newX = bodyVelocity.X
    local newZ = bodyVelocity.Z
    local dir = self.moveDir or Vector3.zero
    local total = (self.__localData.DT or 0) + dt
    if  total >= 1/20 or (dir.Magnitude >.1 and Vector2.new(bodyVelocity.X,bodyVelocity.Z).Magnitude<=.01) then
        local Speed = Entity.getSpeed(self)--4.3/2--Entity.getAndCache(self,"Speed") or 0 
        local s = .6
        local accelerationX = Speed*(.6/s)^3 * dir.X/1
        local accelerationZ = Speed*(.6/s)^3 * dir.Z/1
        
         newX = newX * s *.91 + accelerationX
         newZ = newZ* s *.91 + accelerationZ
         total = 0
    end
    self.__localData.DT = total
    if normal.X ~= 0 then newX = 0 end
    if normal.Z ~= 0 then newZ = 0 end
    Entity.setVelocity(self,"Physics",Vector3.new(newX,bodyVelocity.Y,newZ))
end

function Entity.checkInVoid(self)
    local pos = self.Position 
    if pos.Y <= -50 then
        Entity.onDeath(self,true)
    end
end

local DEBUGSERVER = false
local function Server_visualizer(self)
    local model = self.model
    local hb =  Entity.getHitbox(self)
    if not model then
        model = Instance.new("Part")
        model.Anchored = true 
        model.Parent = workspace
        model.Transparency = .6
        model.Color = Color3.new(1.000000, 0.560784, 0.560784)
        model.Name = self.Guid
        Entity.set(self, "model",model)
    end
    model.Size = hb*3
    model.Position = self.Position*3
end

function Entity.update(self,dt)
    if self.__destroyed then return end 
    if Entity.isOwner(self,LOCAL_PLAYER) then
        debug.profilebegin("update")
        Entity.updateGrounded(self,dt)
        Entity.updateDespawn(self,dt)
        local direationVector,normal,shouldJump = Entity.updatePosition(self,dt)
        Entity.updateChunk(self)
        Entity.updateGravity(self,dt)
        Entity.updateTurning(self,dt)
        Entity.updateMovement(self,dt,normal)
        if shouldJump then
            Entity.jump(self)
        end
        debug.profileend()
    else
        Entity.updateChunk(self)
    end
    if IS_SERVER then
        Entity.checkInVoid(self)
    end 
    if DEBUGSERVER and IS_SERVER then
        Runner.run(Server_visualizer,self) 
    end
end 

function Entity.onDeath(self:CommonTypes.Entity,Special:boolean?)
    self.died = true
    if self.__localData.dead then return end 
    self.__localData.dead = true
    Entity.setMoveDirection(self,Vector3.zero) 
    if IS_SERVER then
        self.died = false
        Entity.set(self,"died",true)
        ServerContainer.PushBackFor(self)
        local DeathDespawn = Entity.get(self, "DeathDespawn")
        Entity.setOwner(self,nil)
        if DeathDespawn ~= false  then 
            self.DespawnTime = DeathDespawn or DEFAULT_DEATH_TIME
        end 
        local Random = Random.new()
        for _,container in self.__containers or {} do
            if Special then
                Container.clear(container)
                continue
            end
            local items = Container.getAllItems(container)
            for i,v in items do
                local item = Utils.createItemEntity(v[1], v[2], nil)

                Entity.applyVelocity(item,Random:NextUnitVector()*Random:NextNumber(1,10))
                -- Entity.setPosition(Item,Utils.getEyePosition(self))
                item.Position = Utils.getEyePosition(self)
                Holder.addEntity(item)
            end
            
            Container.clear(container)
        end
    else
        local model_:Model = ClientUtils.getModel(self)
        task.delay(model_ and 0 or 1, function()
            self.died = false
            Entity.set(self,"died",true)
            local OnDeath:AnimationTrack = Animator.getOrLoad(self,"Death")
            local model:Model = ClientUtils.getModel(self)
            if not model then return end 
            if OnDeath then
                OnDeath:Play()
                OnDeath.Stopped:Once(function()
                    OnDeath:Play(0, 1, 0) 
                    OnDeath.TimePosition = OnDeath.Length -.0001
                end)
            else
                local weld:Weld = self.__cachedData["MainWeld"] 
                local hitBox = Entity.getHitbox(self)
                if weld and hitBox then
                    TweenService:Create(weld,TweenInfo.new(.5),{C0 = weld.C0*CFrame.new(-hitBox.Y*3/2,-hitBox.Y*3/2,0)*CFrame.Angles(0,0,math.rad(90))}):Play()
                end
            end
            local modelData = ClientUtils.get(self,"Model")
            if type(modelData) == "table" and modelData.OnDeath then
                modelData.OnDeath(self)
            end
        end)
    end

end

function Entity.destroy(self)
    if self.model then
        spawn(function() -- this exists out of parallel
            self.model:Destroy()
        end)
    end
    self.__destroyed = true
    Holder.removeEntity(self.Guid)

    local OldChunk = Data.getChunkFrom(self.Chunk)

    EntityContainerManager.OnDeath(self)
    if OldChunk then
        Chunk.removeEntity(OldChunk, self)
    end
    for i,v in self.__signals or {} do
        v:DisconnectAll() 
    end
    self.__signals = nil
    Entity.hold(self,"")
end
return Entity