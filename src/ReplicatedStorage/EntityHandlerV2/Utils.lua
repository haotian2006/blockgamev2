local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local Collisions = require(game.ReplicatedStorage.CollisonHandler)
local DataHandler = require(game.ReplicatedStorage.DataHandler)
local CUtils = require(game.ReplicatedStorage.ConversionUtils)
local MathUtils = require(game.ReplicatedStorage.Libarys.MathFunctions)
local Entity:typeof(require(script.Parent))
local vector3 = Vector3.new
local Utils = {}
function Utils.Init(entity)
    Entity = entity
    return Utils
end
local function calculateAdjustedGoal(min,goal2,increased2)
	return goal2 +increased2*-math.sign( min - goal2)
end
function Utils.getDataFromResource(self,string)
    local entityData = ResourceHandler.Entities[self.Type]
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
function Utils.getPlayersNearEntity(self,radius)
    
end
function Utils.calculateLookAt(self,bRot,hRot)
    local rotation = bRot or self.Rotation or 0
    local headRotation = hRot or self.HeadRotation or Vector2.zero
    local xRot = math.rad(rotation + headRotation.X)
    local yRot = math.rad(headRotation.Y)
    local directionX = math.cos(yRot) * math.cos(xRot)
    local directionY = math.sin(yRot)
    local directionZ = math.cos(yRot) * math.sin(xRot)

    return vector3(directionX,directionY,directionZ).Unit 
end

--//Turning
local DEAFULT_TURN = Vector2.new(360,360)
function Utils.rotateHeadTo(self,target)
    local maxRotation:Vector2 = Entity.getAndCache(self,"MaxNeckRotation") or DEAFULT_TURN
    local AutoRotate:boolean = Entity.getAndCache(self,"AutoRotate") or false
    local rrx = MathUtils.normalizeAngle(target.X-  self.Rotation) 
    local rx,ry = MathUtils.convertCWToCCW(rrx),MathUtils.convertCWToCCW(target.Y)
    local maxX,maxY =  maxRotation.X , maxRotation.Y
--    print(rx)
--print(rx,target.X,self.Rotation)
    local offset 
    local a = rx
    if rx > maxX then
        offset = rx-maxX
        rx = maxX
    elseif rx<-maxX then
        offset = rx+maxX
        rx = 360-maxX
    else
        rx = rrx
    end
    if ry > maxY then
        ry =maxY
    elseif ry<-maxY then
        ry = 360-maxY
    else
        ry = target.Y
    end
   -- print(a,rx,offset,target.X, self.Rotation)
    if offset and AutoRotate  then
        local R = self.Rotation+ offset
        if  R< 0 then
            R +=180
        elseif R> 360 then
            R-=360
        end
        self.Rotation = R
    end
    local new = Vector2.new(rx,ry)
    self.HeadRotation = new
    return new,offset
end
function Utils.rotateBodyTo(self,target)
    
end
--//collisions 
local ZERO = -9.99999993922529e-09 
function Utils.shouldjump(entity,bp,bs)
    local pos = entity.Position
    local hitbox = Entity.get(entity,"Hitbox") 
    local feetpos = pos.Y - hitbox.y/2 
    local blockfeet = bp.Y - bs.Y/2
    local jumpneeded = bs.Y -(feetpos - blockfeet)
    local blockheight =  bp.Y + bs.Y/2
    blockheight = vector3(bp.X,blockheight,bp.Z)
    if jumpneeded > bs.Y or jumpneeded<= 0 then
        return 
    end
    local AutoJump = Entity.get(entity,"AutoJump")
    local Step = Entity.get(entity,"SmallStep")
    if (Step and ( typeof(Step) =="boolean" and .5 or Step) >= jumpneeded ) then
        return "Small",jumpneeded,blockheight
    elseif (AutoJump and ( (typeof(AutoJump) == "boolean" and 1 or AutoJump)) >= jumpneeded) then
        return "Full",jumpneeded,blockheight
    end
    return 
end
function Utils.entityVsTerrain(entity,velocity)
    local position = entity.Position
    local remainingtime = 1
    local normal =  Vector3.zero
    local normal_ = Vector3.zero
    local MinTime
    local blockdata
    local newPosition
    local Shouldjump 
    for i =1,3,1 do
        velocity = vector3(
            velocity.X * (1-math.abs(normal.X))*remainingtime,
            velocity.Y * (1-math.abs(normal.Y))*remainingtime,
            velocity.Z * (1-math.abs(normal.Z))*remainingtime
            )
        local blockdata_
        local Shouldjump_
        MinTime,normal_,blockdata_,velocity,newPosition,Shouldjump_ = Utils.entityVsTerrainLoop(entity,position,velocity)
        if Shouldjump_ then
            Shouldjump = true
        end
        if newPosition then position = newPosition end 
        blockdata = blockdata or blockdata_
        
        normal += normal_

        local placevelocity = velocity*MinTime
        position += placevelocity
        if MinTime <1 then     --epsilon 
            if velocity.X >0 and velocity.X ~= ZERO then
                position = vector3(position.X - 0.001,position.Y,position.Z)
            elseif velocity.X <0 then
                position = vector3(position.X + 0.001,position.Y,position.Z)
            end
            if velocity.Y >0 then
                position = vector3(position.X,position.Y - 0.0001,position.Z)
            elseif velocity.Y <0 then
                position = vector3(position.X,position.Y + 0.001,position.Z)
            end
            if velocity.Z >0 and velocity.Z ~= ZERO then
                position = vector3(position.X,position.Y ,position.Z- 0.001)
            elseif velocity.Z <0 then
                position = vector3(position.X,position.Y ,position.Z+ 0.001)
            end
        end
        remainingtime = 1.0-MinTime
        if remainingtime <=0 then break end
        
    end
    --[[ REMAKE
    if  entity.NotSaved and Shouldjump ==false then 
        if entity.NotSaved.NOGRAVITY then
            position += vector3(0,.01,0)
            entity.NotSaved.NoFall = true
            entity:Gravity(.1)
            task.delay(0,function()
                task.wait()
                entity.NotSaved.NoFall = false
                entity.NotSaved.NOGRAVITY = false
            end)
        end
    elseif Shouldjump then
        entity.NotSaved.NoFall = false
        entity.NotSaved.NOGRAVITY = false
    end
    ]]
    return  position,normal,blockdata,Shouldjump
end

function Utils.entityVsTerrainLoop(entity,position,velocity,whitelist,loop)
    local shouldjump = false
    local hitbox = Entity.get(entity,"Hitbox")
    local min = vector3(
        position.X-hitbox.X/2+(velocity.X <0 and velocity.X or 0)   ,
        position.Y-hitbox.Y/2+(velocity.Y <0 and velocity.Y or 0), 
        position.Z-hitbox.X/2+(velocity.Z <0 and velocity.Z or 0)   
    )   
    local max = vector3(
        position.X+hitbox.X/2 +(velocity.X >0 and velocity.X or 0),
        position.Y+hitbox.Y/2+(velocity.Y >0 and velocity.Y or 0), 
        position.Z+hitbox.X/2+(velocity.Z >0 and velocity.Z or 0)   
    )
    local normal = Vector3.zero
    local mintime = 1
    local blockdata 
    local gridsize = .5
    local bppos,bpsize = Collisions.GetBroadPhase(position,vector3(hitbox.X,hitbox.Y,hitbox.X),velocity)
    whitelist = whitelist or {}
    
    local whitelistClone = table.clone(whitelist)

    for x = min.X,calculateAdjustedGoal(min.X,max.X,gridsize),gridsize do    
    for y = min.Y,calculateAdjustedGoal(min.Y,max.Y,gridsize),gridsize do
    for z = min.Z,calculateAdjustedGoal(min.Z,max.Z,gridsize),gridsize do
        local block,coordsStr,coordsVector = DataHandler.GetBlock(x,y,z)
        if whitelist and whitelist[coordsStr] then continue end
        if block and tostring(block)  then
            local cx,cz =  CUtils.getChunk(x,y,z)
            local blockpos = CUtils.convertLocalToGrid(cx,cz, coordsVector.X,coordsVector.Y,coordsVector.Z) 
            local typejump, heightneeded,maxheight
            local currentmin = 1
            local newpos ,newsize = blockpos,Vector3.one
            local hbdata,CanCollide = Collisions.GenerateHitboxes(block,newpos)
            local loop = 0
            if not CanCollide then continue end 
            for i,v in hbdata do
                local newpos,newsize = v[2],v[1]
                if whitelist[coordsStr..','..loop] then
                    continue 
                end
                if  Collisions.AABBcheck(bppos,newpos,bpsize,newsize,true) then  
                    local collisiontime,newnormal1 = Collisions.SweaptAABB(position,newpos,vector3(hitbox.X,hitbox.Y,hitbox.X),newsize,velocity,mintime)
                    if collisiontime < 1 then
                        if collisiontime < currentmin or loop == 0 then
                            blockdata = {block,coordsStr,newpos,newsize,i}
                            currentmin = collisiontime
                            normal = newnormal1
                        end
                        local a,b,c = Utils.shouldjump(entity,newpos,newsize)
                        if a and (not heightneeded or c.Y >=maxheight.Y ) then
                            typejump, heightneeded,maxheight = a,b,c
                        end
                    end
                end
                whitelist[coordsStr..((loop == 0 and #hbdata == 1) and '' or loop)] = true 
                loop +=1
            end
            mintime = currentmin < mintime and currentmin or mintime
            if mintime < 1 and (typejump) then
                local dir = (maxheight-position).Unit
                if typejump == "Small" and entity.Grounded and heightneeded >=0.1 then
                    heightneeded += 0.023
                    whitelistClone[coordsStr] = true
                    --checks if it would hit a wall
                    local mintime2,normal2,blockdata2 = Utils.entityVsTerrainLoop(entity,position,vector3(velocity.X,velocity.Y+heightneeded,velocity.Z),whitelistClone,"Small")
                    if mintime2 <1 then
                        return loop and .1
                    end
                    local beforeChange = position
                    entity.NotSaved.NOGRAVITY = true
                    position += vector3(0,heightneeded,0)
                    local bfv = velocity
                    if velocity.Y <0 then
                        velocity = vector3(velocity.X,0,velocity.Z)
                    end

                    local m2,n2,z2 = Utils.entityVsTerrainLoop(entity,position,velocity,nil,"Small")

                    if m2 >= 1 then
                        return m2,n2,z2 ,velocity,position,false
                    end

                    position = beforeChange
                    velocity = bfv
                    return  m2,n2,z2,velocity,position,nil,false
                elseif typejump == "Full" and (Entity.get(entity,"AutoJump") or false)   then
                    local AutoJump = Entity.get(entity,"AutoJump")
                    whitelistClone[coordsStr] = true
                    local m2,n2,z2 = Utils.entityVsTerrainLoop(entity,position,vector3(velocity.X, (AutoJump and (typeof(AutoJump) == "boolean" and 1 or AutoJump)),velocity.Z),whitelistClone,"Full")
                    if not m2 or m2 <1 then
                        if loop then
                            return  .1
                        end
                        shouldjump = true
                    end
                end
            end
        end
        end 
        end 
    end 
    return mintime,normal,blockdata,velocity,nil,nil,shouldjump
end
function  Utils.isGrounded(entity,CheckForBlockAboveInstead)
    local position = entity.Position
    local hitbox = Entity.get(entity,"Hitbox")
    local invert = CheckForBlockAboveInstead and -1 or 1
    local aa = CheckForBlockAboveInstead and 0 or 1
    local bb = CheckForBlockAboveInstead and 1 or 0
    local min = vector3(
        position.X-hitbox.X/2,
        position.Y-(hitbox.Y/2+0.0225*aa)*invert,
        position.Z-hitbox.X/2
    )   
    local max = vector3(
        position.X+hitbox.X/2,
        position.Y-(hitbox.Y/2+0.0225*bb)*invert,
        position.Z+hitbox.X/2 
)
    local gridsize = .5
--a
    local whitelist = {}
    for x = min.X,calculateAdjustedGoal(min.X,max.X,gridsize),gridsize do    
    for y = min.Y,calculateAdjustedGoal(min.Y,max.Y,gridsize),gridsize do
    for z = min.Z,calculateAdjustedGoal(min.Z,max.Z,gridsize),gridsize do
        local block,coordstring,coordsvector = DataHandler.GetBlock(x,y,z)
        if whitelist and whitelist[coordstring] then continue end
        if block and not block:isFalse() then
            whitelist[coordstring] = true
            local cx,cz =  CUtils.getChunk(x,y,z)
            local blockpos = CUtils.convertLocalToGrid(cx,cz, coordsvector.X,coordsvector.Y,coordsvector.Z) 
            local newpos ,newsize = blockpos,Vector3.one
            local hbdata,CanCollide = Collisions.GenerateHitboxes(block,newpos)
            local loop = 0
            if not CanCollide then continue end 
            for i,v in hbdata do
                local newpos,newsize = v[2],v[1]
                if Collisions.AABBcheck(vector3(position.X, position.Y-(0.01*invert),position.Z),newpos,vector3(hitbox.X,hitbox.Y,hitbox.X),newsize) then
                    return true,block
                end
            end
        end
    end 
    end  
    end 
    return false
end
    

return Utils 