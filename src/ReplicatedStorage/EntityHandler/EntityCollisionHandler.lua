local Collision = {}
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local CollisionHandler = require(game.ReplicatedStorage.CollisionHandler)
local DataHandler = require(game.ReplicatedStorage.Data)
local CUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local MathUtils = require(game.ReplicatedStorage.Libs.MathFunctions)
local GameSetting = require(game.ReplicatedStorage.GameSettings)
local Chx,ChY = GameSetting.getChunkSize()
local Entity
local BlockUtils = require(game.ReplicatedStorage.Utils.BlockUtils)
function Collision.Init(entity)
    Entity = entity
end

local INCREMENT = 1/2
local vector3 = Vector3.new
local function calculateAdjustedGoal(min,goal2,increased2)
	return goal2 +increased2*-math.sign( min - goal2)
end
function Collision.stayOnEdge(self,targetPosition)
    local CurrentPosition = self.Position*vector3(1,0,1)
    local CurrentY = self.Position.Y
    local CurrentX = CurrentPosition.X
    local CurrentZ = CurrentPosition.Z
    local Copy = {Hitbox = Entity.getHitbox(self)}
    local HitBox = Copy.Hitbox
    local diffrence = targetPosition*vector3(1,0,1)-CurrentPosition
    local onGround,block,LastData = Collision.isGrounded(self)
    if not onGround then return targetPosition end 
    local collided 
    local normalX,normalZ
    local function doSomething(targetPosition,Current,diffrence,xorz)
        if diffrence == 0 then return  end 
        local sign = math.sign(diffrence)
        local Increase = INCREMENT*sign
        local newtargetPosition = targetPosition + .01*sign
        for v = Current, newtargetPosition,Increase do
            if math.abs( v - newtargetPosition) <= INCREMENT then
                v = newtargetPosition
            end
            if xorz then
                CurrentX = v
            else
                CurrentZ = v
            end
            Copy.Position = vector3(CurrentX,CurrentY,CurrentZ)
            local onGround,block,collisionData = Collision.isGrounded(Copy)
            if not onGround then
                if xorz then
                    normalX = sign
                    CurrentX = LastData[1].X + (LastData[2].X/2+HitBox.X/2-.01)*sign
                else
                    normalZ = sign
                    CurrentZ = LastData[1].Z + (LastData[2].Z/2+HitBox.X/2-.01)*sign
                end
                collided = true
                return
            end
            LastData = collisionData
        end
        if xorz then
            CurrentX = targetPosition
        else
            CurrentZ = targetPosition
        end
    end
    doSomething(targetPosition.X,CurrentPosition.X,diffrence.X,true)
    doSomething(targetPosition.Z,CurrentPosition.Z,diffrence.Z,false)
   local normal = vector3(normalX,0,normalZ)
   if not collided then
    return targetPosition
   end
    return vector3(CurrentX,CurrentY,CurrentZ),normal
end

local ZERO = 0--9.99999993922529e-09 

function Collision.shouldjump(entity,bp,bs)
    local pos = entity.Position
    local hitbox = Entity.getHitbox(entity)
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
function Collision.entityVsTerrain(entity,velocity)
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
        MinTime,normal_,blockdata_,velocity,newPosition,Shouldjump_ = Collision.entityVsTerrainLoop(entity,position,velocity)
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

function Collision.entityVsTerrainLoop(entity,position,velocity,whitelist,loop)
    local shouldjump = false
    
    local hitbox = Entity.getHitbox(entity)
    local min = vector3(
        position.X-hitbox.X/2+(velocity.X <0 and velocity.X or 0)   ,
        position.Y-hitbox.Y/2+(velocity.Y <0 and velocity.Y or 0), 
        position.Z-hitbox.Z/2+(velocity.Z <0 and velocity.Z or 0)   
    )   
    local max = vector3(
        position.X+hitbox.X/2 +(velocity.X >0 and velocity.X or 0),
        position.Y+hitbox.Y/2+(velocity.Y >0 and velocity.Y or 0), 
        position.Z+hitbox.Z/2+(velocity.Z >0 and velocity.Z or 0)   
    )
    
    local normal = Vector3.zero
    local mintime = 1
    local blockdata 
    local gridsize = .5
    local bppos,bpsize = CollisionHandler.GetBroadPhase(position,vector3(hitbox.X,hitbox.Y,hitbox.X),velocity)
    whitelist = whitelist or {}
    
    local whitelistClone = table.clone(whitelist)

    for x = min.X,calculateAdjustedGoal(min.X,max.X,gridsize),gridsize do    
    for y = min.Y,calculateAdjustedGoal(min.Y,max.Y,gridsize),gridsize do
    for z = min.Z,calculateAdjustedGoal(min.Z,max.Z,gridsize),gridsize do
        local block,localGrid,Grid = CollisionHandler.getBlock(x,y,z)
        local GridStr = tostring(Grid)
        if whitelist and whitelist[GridStr] then continue end
        if block then
            if block == 0 then continue end 
            local typejump, heightneeded,maxheight
            local currentmin = 1
            local newpos ,newsize = Grid,Vector3.one
            local hbdata,CanCollide = CollisionHandler.GenerateHitboxes(block,newpos)
            local loop = 0
            if not CanCollide then continue end 
            for i,v in hbdata do
                local newpos,newsize = v[2],v[1]
                if whitelist[GridStr..','..loop] then
                    continue 
                end
                if  CollisionHandler.AABBcheck(bppos,newpos,bpsize,newsize,true) then  
                    local collisiontime,newnormal1 = CollisionHandler.SweaptAABB(position,newpos,vector3(hitbox.X,hitbox.Y,hitbox.X),newsize,velocity,mintime)
                    if collisiontime < 1 then
                        if collisiontime < currentmin or loop == 0 then
                            blockdata = {block,GridStr,newpos,newsize,i}
                            currentmin = collisiontime
                            normal = newnormal1
                        end
                        local a,b,c = Collision.shouldjump(entity,newpos,newsize)
                        if a and (not heightneeded or c.Y >=maxheight.Y ) then
                            typejump, heightneeded,maxheight = a,b,c
                        end
                    end
                end
                whitelist[GridStr..((loop == 0 and #hbdata == 1) and '' or loop)] = true 
                loop +=1
            end
            mintime = currentmin < mintime and currentmin or mintime
            if mintime < 1 and (typejump) then
                local dir = (maxheight-position).Unit
                if typejump == "Small" and entity.Grounded and heightneeded >=0.1 then
                    heightneeded += 0.023
                    whitelistClone[GridStr] = true
                    --checks if it would hit a wall
                    local mintime2,normal2,blockdata2 = Collision.entityVsTerrainLoop(entity,position,vector3(velocity.X,velocity.Y+heightneeded,velocity.Z),whitelistClone,"Small")
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

                    local m2,n2,z2 = Collision.entityVsTerrainLoop(entity,position,velocity,nil,"Small")

                    if m2 >= 1 then
                        return m2,n2,z2 ,velocity,position,false
                    end

                    position = beforeChange
                    velocity = bfv
                    return  m2,n2,z2,velocity,position,nil,false
                elseif typejump == "Full" and (Entity.get(entity,"AutoJump") or false)   then
                    local AutoJump = Entity.get(entity,"AutoJump")
                    whitelistClone[GridStr] = true
                    local m2,n2,z2 = Collision.entityVsTerrainLoop(entity,position,vector3(velocity.X, (AutoJump and (typeof(AutoJump) == "boolean" and 1 or AutoJump)),velocity.Z),whitelistClone,"Full")
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

function  Collision.isGrounded(entity,CheckForBlockAboveInstead)
    local position = entity.Position
    local hitbox = Entity.getHitbox(entity)
    local invert = CheckForBlockAboveInstead and -1 or 1
    local aa = CheckForBlockAboveInstead and 0 or 1
    local bb = CheckForBlockAboveInstead and 1 or 0
    local min = vector3(
        position.X-hitbox.X/2,
        position.Y-(hitbox.Y/2+0.0225*aa)*invert,
        position.Z-hitbox.Z/2
    )   
    local max = vector3(
        position.X+hitbox.X/2,
        position.Y-(hitbox.Y/2+0.0225*bb)*invert,
        position.Z+hitbox.Z/2 
)
    local gridsize = .5
--a
    local whitelist = {}::{[string]:boolean}
    for x = min.X,calculateAdjustedGoal(min.X,max.X,gridsize),gridsize do    
    for y = min.Y,calculateAdjustedGoal(min.Y,max.Y,gridsize),gridsize do
    for z = min.Z,calculateAdjustedGoal(min.Z,max.Z,gridsize),gridsize do
        local block,localGrid,Grid = CollisionHandler.getBlock(x,y,z)
        local coordstring = tostring(Grid)
        if whitelist and whitelist[localGrid] then continue end
        if block  then
            if block == 0 then continue end 
            whitelist[coordstring] = true
            local blockpos = Grid
            local newpos ,newsize = blockpos,Vector3.one
            local hbdata,CanCollide = CollisionHandler.GenerateHitboxes(block,newpos)
            local loop = 0
            if not CanCollide then continue end 
            for i,v in hbdata do
                local newpos,newsize = v[2],v[1]
                if CollisionHandler.AABBcheck(vector3(position.X, position.Y-(0.01*invert),position.Z),newpos,vector3(hitbox.X,hitbox.Y,hitbox.X),newsize) then
                    return true,block,{newpos,newsize}
                end
            end
        end
    end 
    end  
    end 
    return false
end
    
return Collision