local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local IS_CLIENT = RunService:IsClient()
local LOCAL_PLAYER = game.Players.LocalPlayer
local Animator = require(script.Animator)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local Utils = require(script.Utils)
local Entity = {}
Utils.Init(Entity) 
Entity.__index = Entity
Entity.GRAVITY = 32--9.81
Entity.Speed = 0
function Entity.new(type:string)
    local info = BehaviorHandler.GetEntity(type)
    if not info then return warn(`Entity '{type}' does not exist`) end 
    local self = {}
    self.Type = type 
    self.__main = info.components or {}
    self.__velocity = {}
    self.__components = {}
    self.__changed = {}
    self.__animations = {}
    self.__playingAnimations = {}
    self.__states = {}
 --   self.__ownership = nil
    self.__cachedData = {}
  --  self.__model = nil
    self.__localData = {}
    self.Position = Vector3.zero
    self.Grounded = true
    self.Chunk = Vector2.zero
    self.Rotation = 0 
    self.HeadRotation = Vector2.zero
    return self
end
function Entity.addComponent(self,component,index)
    table.clear(self.__cachedData )
    local entityData =  BehaviorHandler.GetEntity(self.Type)
    local componentData = entityData.component_groups[component]
    if not componentData then warn(`component {component} is not a member or {self.Type}`) end 
    componentData.Name = component
    Entity.removeComponent(self,component)
    table.insert(self.__components,index or 1,componentData)
end
function Entity.removeComponent(self,name)
    table.clear(self.__cachedData )
    for i,v in self.__components do
        if v.Name == name then
            table.remove(self.__components,i)
        end
    end
end
--//Get/seters
function Entity.clearCache(self)
    table.clear(self.__cachedData)
end
function Entity.getAndCache(self,string)
    if self[string] then
        return self[string] 
    end
    if not self.__cachedData[string] then
        self.__cachedData[string] = Entity.get(self,string) 
    end
    return self.__cachedData[string]
end
function Entity.get(self,string) 
    if self[string] then
        return self[string]
    end
    for i,v in self.__components do
        if v[string] then 
            return v[string]
        end
    end
    if self.__main[string] then 
        return self.__main[string]
    end
    return Entity[string]
end
function Entity:set(key,value)
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
    self.moveDir = Direaction
end
function Entity.getMoveDireaction(self,Direaction)
 return self.moveDir
end
function Entity.jump(self,JumpPower)
    if not self.Grounded then return end 
    local bodyVelocity = Entity.getVelocity(self,"Physics") or Vector3.zero
    local JumpPower = JumpPower or Entity.get(self,"jumpPower")
    Entity.setVelocity(self,"Physics",bodyVelocity + Vector3.new(0,JumpPower,0))
    self.Grounded = false
end
--4.9

--//OwnerShip
function Entity.isOwner(self,player:Player)
    return self.__ownership == player.UserId
end
function Entity.getOwner(self)
    return self.__ownership ~= nil and game.Players:GetPlayerByUserId(self.__ownership)
end
--//StateHandler 
function Entity.setState(self,state,value)
    self.__states[state] = value
end
function Entity.getState(self,state)
    return self.__states[state]
end
--//Updates
function Entity.updatePosition(self,dt)
    if Entity.isOwner(self,LOCAL_PLAYER) then 
        local velocity = Entity.getTotalVelocity(self)
       -- self:UpdateIdleAni()
        local p2 = self.Position+velocity*dt--self.Position:Lerp(self.Position+velocity,dt) 
        --local e = velocity
        velocity = (p2-self.Position)
        local newPosition,normal,blockdata,shouldJump = Utils.entityVsTerrain(self,velocity)
        local direationVector = newPosition - self.Position
        if Vector3.new(direationVector.X,0,direationVector.Z):FuzzyEq(Vector3.zero,0.01) then
            if  self.__localData.LastUpdate and (os.clock()- self.__localData.LastUpdate)>.2 or RunService:IsClient()  then
                -- self:StopAnimation("Walk")
                -- self:SetState('Moving',false)
            end
        else
            -- self:PlayAnimation("Walk")
            -- self.__localData.LastUpdate = os.clock()
            -- self:SetState('Moving',true)
        end
        self.Position = newPosition--interpolate(self.Position,newp,dt) 
        return direationVector,normal,shouldJump
    end
end
function Entity.updateGrounded(self,dt,shouldJump)
    local isGrounded,b = Utils.isGrounded(self)
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
    local FramesInAir = self.FramesInAir or 1
    if not self.Grounded then
        local Gravity = Entity.getAndCache(self,"GRAVITY")
        yValue = bodyVelocity.Y + (-Gravity)*dt
        self.FramesInAir = FramesInAir +1
    else
        FramesInAir = 0 
    end
    Entity.setVelocity(self,"Physics",Vector3.new(bodyVelocity.X,yValue,bodyVelocity.Z))
end
function Entity.updateFriction(self,dt,normal)
    local bodyVelocity = Entity.getVelocity(self,"Physics") or Vector3.zero
    local newX = bodyVelocity.X
    local newZ = bodyVelocity.Z
    local dir = self.moveDir or Vector3.zero
    if  dt >= 1/20 or (dir.Magnitude >.1 and Vector2.new(bodyVelocity.X,bodyVelocity.Z).Magnitude<=.01) then
        local Speed = 4.3/2--Entity.getAndCache(self,"Speed") or 0 
        local s = .6--.6
        local accelerationX = Speed*(.6/s)^3 * dir.X
        local accelerationZ = Speed*(.6/s)^3 * dir.Z
        
         newX = newX * s *.91 + accelerationX
         newZ = newZ* s *.91 + accelerationZ
         if  math.floor(Vector2.new(newX,newZ).Magnitude*100)/100 ~= 0 then
        -- print( math.floor(Vector2.new(newX,newZ).Magnitude*100)/100)
         end
         self.__localData.tick = 0
    end
    if normal.X ~= 0 then newX = 0 end
    if normal.Z ~= 0 then newZ = 0 end
    Entity.setVelocity(self,"Physics",Vector3.new(newX,bodyVelocity.Y,newZ))
end
function Entity.update(self,dt,fixedDt)
    if Entity.isOwner(self,LOCAL_PLAYER) then
        local direationVector,normal,shouldJump = Entity.updatePosition(self,dt)
        Entity.updateGrounded(self,dt)
        Entity.updateGravity(self,dt)
        Entity.updateFriction(self,fixedDt,normal)
    end
    if IS_CLIENT then
        
    end
end
--//Animaton
function Entity.playAnimation(self,animation)
    if self.__dead then return end 
    local owner = Entity.getOwner(self)
    if not IS_CLIENT then
        --//SendToUpdateTable
    elseif owner == LOCAL_PLAYER then
        Animator.play(self,animation)
            --//SendToUpdateTable
    else
        Animator.play(self,animation)
    end
end
function Entity:destroy()
    self.__destroyed = true
end
return Entity