local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local Collisions = require(game.ReplicatedStorage.CollisionHandler)
local CUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local MathUtils = require(game.ReplicatedStorage.Libs.MathFunctions)
local GameSetting = require(game.ReplicatedStorage.GameSettings)
local Data = require(game.ReplicatedStorage.Data)
local Chx,ChY = GameSetting.getChunkSize()
local Entity 
local EntityHolder = require(script.Parent.EntityHolder)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Utils = {}

function Utils.Init(entity)
    Entity = entity
    return Utils
end

local vector3 = Vector3.new

function Utils.getDataFromResource(self,string)
    local entityData = ResourceHandler.getEntity(self.Type)
    if not entityData.components then
        return entityData[string] 
    end
    if #self.__componets > 0 and entityData.components_groups then
        for i,v in self.__componets do
           local group = entityData.components_groups[v.Name]
           if group and group[string] then
             return group[string]
           end
        end
    end
    return entityData.components[string]
end

function Utils.setLocalData(self,key,value)
    self.__localData.Storage = self.__localData.Storage or {}
    self.__localData.Storage [key] = value
end
function Utils.getLocalData(self,key,value)
    self.__localData.Storage = self.__localData.Storage or {}
    return  self.__localData.Storage[key]
 end

function Utils.isOwner(self,player)
    if (not player or player.UserId =="NAN") and not self.__ownership then
        return true 
    end
    local pass =  self.__ownership == (player and player.UserId)
    if pass and self.__ownership then 
        self.__localData["Owner"] = player
    end
    return pass
end

function Utils.getOwner(self)
    if not self.__ownership then
         return 
    end
    local p =self.__localData["Owner"]
    if p and p.UserId == self.__ownership then
        return p
    end
    local plr = game.Players:GetPlayerByUserId(self.__ownership)
    self.__localData["Owner"] = plr
    return plr
end

function Utils.ownerExists(self)
    Utils.getOwner(self)
    return  self.__localData["Owner"] and true or false
end

function Utils.getEyePosition(self)
    return self.Position + vector3(0,Entity.getAndCache(self,"EyeLevel") or 0,0)/2
end

function Utils.getPlayersNearEntity(self,radius)
    --//change to search in nearby chunks 
    return game.Players:GetPlayers()
end

function Utils.getEntitiesNear(self,radius,RoundToNearestChunk)
    local position = self.Position
    local centerX = (position.X // 8)
    local centerZ = (position.Z // 8)

    local divided = radius/8
    local minX = centerX - math.ceil(divided)
    local maxX = centerX + math.ceil(divided)
    local minZ = centerZ - math.ceil(divided)
    local maxZ = centerZ + math.ceil(divided)
    local entities = {}
    
    for x = minX, maxX do
        for z = minZ, maxZ do
            local coords = vector3(x,0,z)
            local chunk = Data.getChunkFrom(coords)
            if not chunk then continue end 
            for i,v in chunk.Entities do
                if v == self then continue end 
                if RoundToNearestChunk or Utils.getMagnitudeBetween(self,v) < radius then
                    table.insert(entities,v)
                end
            end
        end
    end


    -- for i,v in EntityHolder.getAllEntities() do
    --     if v == self then continue end 
    --     if Utils.getMagnitudeBetween(self,v) < radius then
    --         table.insert(entities,v)
    --     end
    -- end
    return entities
end


local MaxY = math.rad(80)
function Utils.calculateLookAt(self,bRot,hRot)
    local rotation = bRot or self.Rotation or 0
    local headRotation = hRot or self.HeadRotation or Vector2.zero
    local xRot = math.rad(rotation + headRotation.X)
    local yRot = math.rad(headRotation.Y)
    yRot = math.clamp(yRot, -MaxY, MaxY)
    local directionX = math.cos(yRot) * math.sin(xRot)
    local directionY = math.sin(yRot)
    local directionZ = math.cos(yRot) * math.cos(xRot)

    return vector3(directionX,directionY,directionZ).Unit 
end



function Utils.getChunk(self)
    local Position = self.Position
    local cx = math.floor((Position.X+0.5)/Chx)
	local cz = math.floor((Position.Z+0.5)/Chx)
    return vector3(cx,0,cz)
end

function Utils.getMagnitudeBetween(entity,entity2)
    return (entity.Position-entity2.Position).magnitude
end

function Utils.createItemEntity(Item,count,lifetime)
    count = count or 1
    local Item_ = Entity.new("c:Item")
    Item_.ItemId = Item[1]
    Item_.ItemVariant = Item[2]
    Item_.ItemCount =count
    Entity.setTemp(Item_,"AliveTime",time()+(lifetime or .1))
    return Item_
end

function Utils.dropItem(self,item,count,velocity)
    local pos = Utils.getEyePosition(self)
    local cx,cz = ConversionUtils.getChunk(pos.X, pos.Y, pos.Z)
    local mag = 29
    if type(velocity) == "number" then
        mag = velocity
        velocity = nil
    end
    velocity = velocity or Utils.calculateLookAt(self)*mag
    local Item = Utils.createItemEntity(item, count, 1)
    Entity.applyVelocity(Item,velocity)
    -- Entity.setPosition(Item,Utils.getEyePosition(self))
    Item.Position = pos
    EntityHolder.addEntity(Item)
end
--//Turning
local DEAFULT_TURN = Vector2.new(180,180)
function Utils.setRotation(self,target)
    self.__localData.Rotation = MathUtils.normalizeAngle2(target)
end

function Utils.rotateHeadTo(self,pitch,yaw)
    local maxRotation:Vector2 = Entity.getAndCache(self,"MaxNeckRotation") or DEAFULT_TURN
    -- local AutoRotate:boolean = Entity.getAndCache(self,"AutoRotate") or false
    local Rotation = self.__localData.Rotation or self.Rotation
    local target = vector3(pitch,yaw)
    local rrx = MathUtils.normalizeAngle2(target.X-  Rotation)
    local rx,ry = rrx,target.Y
    local maxX,maxY =  maxRotation.X , maxRotation.Y
    local offset 
    if rx > maxX then
        offset = rx-maxX
        rx = maxX
    elseif rx<-maxX then
        offset = rx+maxX
        rx = -maxX
    else
        rx = rrx
    end
    if ry > maxY then
        ry =maxY
    elseif ry<-maxY then
        ry = -maxY
    else
        ry = target.Y
    end
    if offset then
        local newRotation = Rotation + offset
        if  newRotation < -180 then
            newRotation += 360
        elseif newRotation > 180 then
            newRotation -= 360
        end
        self.__localData.Rotation = newRotation
    end
    local new = vector3(rx,ry)
    self.__localData.HeadRotation = new
    -- local lookat = Utils.calculateLookAt(self,self.Rotation,self.HeadRotation)
    -- part.Position = (self.Position+vector3(lookat.X,0,lookat.Z)*4)*3
    return new,offset
end

function Utils.lookAt(self,target:Vector3)
    if typeof(target) ~= "Vector3" then
        target = Utils.getEyePosition(target)
    end
    local dif = (target-Utils.getEyePosition(self)).Unit
    local pitch,yaw = MathUtils.GetP_YawFromVector3(dif)
    Utils.rotateHeadTo(self,pitch,yaw)
end

function Utils.followMovement(self,movedir:Vector2)
    local HeadRot = self.__localData.HeadRotation or self.HeadRotation
    local maxRotation:Vector2 = Entity.getAndCache(self,"MaxNeckRotation") or DEAFULT_TURN
    local Rotation = self.__localData.Rotation or self.Rotation
    local CurrentHeadRotationX = Rotation + HeadRot.X
    local targetRotation = math.deg(math.atan2(movedir.X,movedir.Y))--90
    targetRotation = targetRotation == targetRotation and targetRotation or Rotation
    local lookat = Utils.calculateLookAt(self)
    lookat = Vector2.new(lookat.X,lookat.Z)*4
    local dot = lookat:Dot(movedir.Unit)

    if dot <-1 then

        targetRotation = targetRotation+180
    end
    local rx = MathUtils.normalizeAngle2(CurrentHeadRotationX- targetRotation)
    local maxX,maxY =  maxRotation.X , maxRotation.Y
    local offset 
    local orr = rx
    if rx > maxX then
        offset = rx-maxX-1
        rx = maxX
    elseif rx<-maxX then
        offset = rx+maxX+1
        rx = -maxX
    end
    self.__localData.HeadRotation = Vector2.new(rx,HeadRot.Y)
    if offset then
        local R = targetRotation + offset
        if  R< -180 then
            R +=360
        elseif R> 180 then
            R-=360
        end
        self.__localData.Rotation= R
      return  
    end
    self.__localData.Rotation = targetRotation--MathUtils.normalizeAngle2(targetRotation - offset)
end



return table.freeze(Utils) 