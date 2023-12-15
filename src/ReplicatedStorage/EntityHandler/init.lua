local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local IS_CLIENT = RunService:IsClient()
local IS_SERVER = not IS_CLIENT
local LOCAL_PLAYER = game.Players.LocalPlayer or {UserId = "NAN"}
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local Chunk = require(game.ReplicatedStorage.Chunk)
local MathUtils = require(game.ReplicatedStorage.Libarys.MathFunctions)
local Animator = require(script.Animator)
local Utils = require(script.Utils)
local CollisionHandler = require(script.EntityCollisionHandler)
local EntityTaskReplicator = require(script.EntityReplicator.EntityTaskReplicator)
local Data = require(game.ReplicatedStorage.Data)
 
local Entity = {}
EntityTaskReplicator.Init(Entity)
Utils.Init(Entity) 
CollisionHandler.Init(Entity)
Entity.Animator = Animator
Entity.Utils = Utils
Entity.Gravity = 32--9.81
Entity.Speed = 0
Entity.RotationSpeedMultiplier = 6*2
local slerpAngle = MathUtils.slerpAngle 
local NILVALUE = '↓←⊞🌟'
local DEAFULTS = "⊞↓←🌟"
function Entity.new(type:string,ID)
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
    self.Position = Vector3.zero
    self.Grounded = true
    self.Rotation = 0 
    self.HeadRotation = Vector2.zero
    return self
end
function Entity.addComponent(self,component,index)
    table.clear(self.__cachedData )
    local entityData =  BehaviorHandler.getEntity(self.Type)
    local componentData = entityData.component_groups[component]
    if not componentData then warn(`component {component} is not a member or {self.Type}`) end 
    componentData.Name = component
    Entity.removeComponent(self,component)
    table.insert(self.__components,index or 1,componentData)
end
function Entity.hasComponet(self,componet)
    for i,v in self.__components do
        if v.Name == componet then
            return i
        end
    end
end
function Entity.removeComponent(self,name)
    for i,v in self.__components do
        if v.Name == name then
            table.clear(self.__cachedData )
            table.remove(self.__components,i)
            self.__changed["__components"] = true
        end
    end
end
--//Get/seters
function Entity.getCache(self)
    return self.__cachedData
end
function Entity.clearCache(self)
    table.clear(self.__cachedData)
end
function Entity.getAndCache(self,string)
    if self[string] ~= nil then
        return self[string] 
    end
    local cached = self.__cachedData[string]
    if not cached then
        local data,_ = Entity.get(self,string) 
        if data == "NIL" then
            data = NILVALUE
        end
        self.__cachedData[string] = _ and DEAFULTS or data
        return data
    elseif cached == DEAFULTS then
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
    for i,v in self.__components do
        if v[string] ~= nil then 
            return v[string]
        end
    end
    if self.__main[string] ~= nil then 
        return self.__main[string]
    end
    return Entity[string],true
end
function Entity.set(self,key,value)
    if self[key] ~= value then
        self.__changed[key] = IS_SERVER and true or nil
    end
    self[key] = value
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
        x = -0.00000001
    end
    if z == 0 then
        z = -0.00000001
    end
    return Vector3.new(x,y,z)
end
function Entity.setVelocity(self,name,vector)
    if vector == Vector3.zero then
        vector = nil
    end
    self.__velocity[name] = vector
end
function Entity.getVelocity(self,name)
    return self.__velocity[name]
end
function Entity.setMoveDireaction(self,Direaction)
    Utils.followMovement(self,Vector2.new(Direaction.X,Direaction.Z).Unit)
    self.moveDir = Direaction
end
function Entity.getMoveDireaction(self,Direaction)
 return self.moveDir
end
--//Overridable
function Entity.getSpeed(self)
    return Entity.getAndCache(self,"Speed")
end

--4.9


--//OwnerShip
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
    if not self.Grounded or  CollisionHandler.isGrounded(self,true) then return end 
    local bodyVelocity = Entity.getVelocity(self,"Physics") or Vector3.zero
    local JumpPower = JumpPower or Entity.get(self,"jumpPower")
    Entity.setVelocity(self,"Physics",bodyVelocity + Vector3.new(0,JumpPower,0))
    self.Grounded = false
end
function Entity.isDead(self)
    if not self then return true end 
    return self.__dead or false 
end
function Entity.canCrouch(self,unCrouch)
    if unCrouch and CollisionHandler.isGrounded(self,true) then
        return false
   end
   return true 
end
function Entity.crouch(self,isDown,fromClient)
    local CrouchHeight = Entity.get(self,"CrouchLower")
    if not CrouchHeight then return end 
    self.Crouching = self.Crouching or false
    if isDown~=nil and self.Crouching == isDown then return end 
    self.Crouching = not self.Crouching
    local currentHitBox = Entity.get(self,"Hitbox")
    local EyeLevel = Entity.get(self,"EyeLevel")
    if self.Crouching then
        -- Entity.set(self,"Hitbox", Vector2.new(currentHitBox.X, currentHitBox.Y-CrouchHeight))
        -- Entity.set(self,"EyeLevel", EyeLevel-CrouchHeight)
        self.Hitbox = Vector2.new(currentHitBox.X, currentHitBox.Y-CrouchHeight)
        self.EyeLevel = EyeLevel-CrouchHeight
        if not  fromClient then 
            Entity.set(self,"Position",self.Position+Vector3.new(0,-CrouchHeight/2,0))
        end
        Animator.playLocal(self,"Crouch",nil,nil,nil)
    else
        -- Entity.set(self,"Hitbox", Vector2.new(currentHitBox.X, currentHitBox.Y+CrouchHeight))
        -- Entity.set(self,"EyeLevel", EyeLevel+CrouchHeight)
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
    local chunk = Vector2.new(Utils.getChunk(self))
    if chunk ~= self.Chunk then
        if self.Chunk ~= nil then
            local OldChunk = Data.getChunk(self.Chunk.X,self.Chunk.Y)
            if OldChunk then
                Chunk.removeEntity(OldChunk, self)
            end
        end
        self.Chunk = chunk
        local newChunk =  Data.getChunk( chunk.X,chunk.Y)
        if newChunk then
            Chunk.addEntity(newChunk, self)
        end
    end
end
function Entity.updateTurning(self,dt)
    local targetHead = self.__localData.HeadRotation
    local targetBody = self.__localData.Rotation
    local head,body = self.HeadRotation,self.Rotation
    local multi = Entity.getAndCache(self,"RotationSpeedMultiplier")
    dt*=multi
    if dt>1 then dt = 1 end 
    if targetBody then 
        local reached 
        self.Rotation,reached = slerpAngle(body,targetBody,dt)   
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
            local x,_x =  slerpAngle(head.X,targetHead.X,dt)
            local y,_y =slerpAngle(head.Y,targetHead.Y,dt)

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
        local direationVector = newPosition - self.Position
        if Vector3.new(direationVector.X,0,direationVector.Z):FuzzyEq(Vector3.zero,0.001) then
            if  self.__localData.LastUpdate and (os.clock()- self.__localData.LastUpdate)>.018  then
               if Animator.isPlaying(self,"Walk") then
                Animator.stop(self,"Walk",.1)
               end
                -- self:SetState('Moving',false)
            end
        else
            local speed = (newPosition*Vector3.new(1,0,1) - self.Position*Vector3.new(1,0,1)).Magnitude/dt/(Entity.getAndCache(self,"Speed"))
            if not Animator.isPlaying(self,"Walk") then
                Animator.play(self,"Walk")
            end
            if speed >=0.05 then
                Animator.adjustSpeed(self,"Walk",speed)
            end
            -- self:PlayAnimation("Walk")
          self.__localData.LastUpdate = os.clock()
            -- self:SetState('Moving',true)
        end
        self.Position = newPosition--interpolate(self.Position,newp,dt) 
        return direationVector,normal,shouldJump
    end
end
function Entity.updateGrounded(self,dt,shouldJump)
    local isGrounded,b = CollisionHandler.isGrounded(self)
    self.Grounded = isGrounded
    --[[
    self:SetState("Grounded",self.Data.Grounded)
    if  self.NotSaved["LastG"] and not self.Data.Grounded and not self.NotSaved.Jumping then
        self.NotSaved["ExtraJump"] = DateTime.now().UnixTimestampMillis/1000
    end
    self.NotSaved.LastG = self.Data.Grounded
    if shouldJump then
        self:Jump()
    end
    ]]
end
local start = os.clock()
local a = true
function Entity.updateGravity(self,dt)
    local bodyVelocity = Entity.getVelocity(self,"Physics") or Vector3.zero
    local yValue = 0
    local FramesInAir = self.FramesInAir or 0
    if not self.Grounded and (not CollisionHandler.isGrounded(self,true) or FramesInAir == 0) then
        local Gravity = Entity.getAndCache(self,"Gravity")
        yValue = bodyVelocity.Y + (-Gravity)*dt
        FramesInAir = FramesInAir +1
    else
        FramesInAir = 0 
    end
    self.FramesInAir  = FramesInAir
    Entity.setVelocity(self,"Physics",Vector3.new(bodyVelocity.X,yValue,bodyVelocity.Z))
end
function Entity.updateMovement(self,dt,normal)
    local bodyVelocity = Entity.getVelocity(self,"Physics") or Vector3.zero
    local newX = bodyVelocity.X
    local newZ = bodyVelocity.Z
    local dir = self.moveDir or Vector3.zero

    if  dt >= 1/20 or (dir.Magnitude >.1 and Vector2.new(bodyVelocity.X,bodyVelocity.Z).Magnitude<=.01) then
        local Speed = Entity.getAndCache(self,"getSpeed")(self)--4.3/2--Entity.getAndCache(self,"Speed") or 0 
        local s = .6
        local accelerationX = Speed*(.6/s)^3 * dir.X/1
        local accelerationZ = Speed*(.6/s)^3 * dir.Z/1
        
         newX = newX * s *.91 + accelerationX
         newZ = newZ* s *.91 + accelerationZ
    end
    if normal.X ~= 0 then newX = 0 end
    if normal.Z ~= 0 then newZ = 0 end
    Entity.setVelocity(self,"Physics",Vector3.new(newX,bodyVelocity.Y,newZ))
end
function Entity.update(self,dt,fixedDt)
    if Entity.isOwner(self,LOCAL_PLAYER) then
        local direationVector,normal,shouldJump = Entity.updatePosition(self,dt)
        Entity.updateChunk(self)
        Entity.updateGrounded(self,dt)
        Entity.updateGravity(self,dt)
        Entity.updateTurning(self,dt)
        Entity.updateMovement(self,fixedDt,normal)
    end
    if IS_CLIENT then
        
    end
end 

function Entity.destroy(self)
    self.__destroyed = true
end
return Entity