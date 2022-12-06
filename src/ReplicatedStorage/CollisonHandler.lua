local RunService = game:GetService("RunService")
local collisions ={}
local qf = require(game.ReplicatedStorage.QuickFunctions)
local blockhandler
local vector3 = Vector3.new
local function getincreased(min,goal2,increased2)
	local direaction = min - goal2
	return goal2 +increased2*-math.sign(direaction)
end

function  collisions.IsGrounded(entity)
    local position = entity.Position
    local hitbox = entity.HitBoxSize
    local min = vector3(
        position.X-hitbox.x/2,
        position.Y-(hitbox.y/2+0.03),
        position.Z-hitbox.z/2
    )   
    local max = vector3(
        position.X+hitbox.x/2,
        position.Y-(hitbox.y/2),
        position.Z+hitbox.z/2 
)
    local gridsize = 1
--a
    for x = min.X,getincreased(min.X,max.X,gridsize),gridsize do    
        for y = min.Y,getincreased(min.Y,max.Y,gridsize),gridsize do
            for z = min.Z,getincreased(min.Z,max.Z,gridsize),gridsize do
                local block,a = refunction.GetBlock({x,y,z})
                if block then
                   local a2 = refunction.convertPositionto(a,"table")
                   local newpos ,newsize,n2,s2,n3,s3,n4,s4 = collisions.DealWithRotation(block)
                   if  collisions.AABBcheck(vector3(position.X, position.Y-1,position.Z),newpos,vector3(hitbox.X,hitbox.Y,hitbox.Z),newsize) then 
                    return true,block
                    end  
                end

            end 
        end 
    end 
    return false
end
function  collisions.entityvsterrain(entity)
    local oldv = entity:GetVelocity()
    local velocity = entity:GetVelocity()
    local position = entity.Position
    local oldp = vector3(position.X,position.Y,position.Z)
   -- print(velocity.Y)
    local remainingtime = 1
    local MinTime
    local normal = vector3(0,0,0)
    for i =1,3,1 do
      
    velocity = vector3(
        velocity.X * (1-math.abs(normal.X))*remainingtime,
        velocity.Y * (1-math.abs(normal.Y))*remainingtime,
        velocity.Z * (1-math.abs(normal.Z))*remainingtime
        )
        local bb
        normal = vector3()
        MinTime,normal,bb,velocity = collisions.entityvsterrainloop(entity,position,velocity,{},false,oldv)
        local placevelocity = vector3(velocity.X*MinTime,velocity.Y*MinTime,velocity.Z*MinTime)
        position = vector3(
            position.X + placevelocity.X,
            position.Y + placevelocity.Y,
            position.Z + placevelocity.Z
        )
        if MinTime <1 then
            --epsilon 
            if velocity.X >0 and velocity.X ~= 0.00000001 then
                position = qf.EditVector3(position,"x",position.X - 0.001)
            elseif velocity.X <0 then
                position = qf.EditVector3(position,"x",position.X + 0.001)
            end
            if velocity.Y >0 then
                position = qf.EditVector3(position,"y",position.Y - 0.0001)
            elseif velocity.Y <0 then
                position = qf.EditVector3(position,"y",position.Y + 0.001)
            end
            if velocity.Z >0 and velocity.Z ~= 0.00000001 then
                position = qf.EditVector3(position,"z",position.Z - 0.00001)
            elseif velocity.Z <0 then
                position = qf.EditVector3(position,"z",position.Z + 0.00001)
            end
        end
        remainingtime = 1.0-MinTime
        if remainingtime <=0 then break end
        
    end
    return  position
end
function collisions.GetBroadPhase(b1,s1,velocity)
    b1 = vector3(b1.X-s1.X/2,b1.Y-s1.Y/2,b1.Z-s1.Z/2)
    local position = vector3()
    local size = vector3()
    position.X = velocity.X >0 and b1.X or b1.X + velocity.X
    position.Y = velocity.Y >0 and b1.Y or b1.Y + velocity.Y
    position.Z = velocity.Z >0 and b1.Z or b1.Z + velocity.Z
    size.X = velocity.X >0 and velocity.X+s1.X or s1.X - velocity.X
    size.Y = velocity.Y >0 and velocity.Y+s1.Y or s1.Y - velocity.Y
    size.Z = velocity.Z >0 and velocity.Z+s1.Z or s1.Z - velocity.Z
    return position,size
end
function collisions.AABBcheck(b1,b2,s1,s2,isbp)
    if  isbp == true then
    else
        b1 = vector3(b1.X-s1.X/2,b1.Y-s1.Y/2,b1.Z-s1.Z/2)
    end
    b2 = vector3(b2.X-s2.X/2,b2.Y-s2.Y/2,b2.Z-s2.Z/2)
    return not (b1.X+s1.X < b2.X or 
                b1.X>b2.X+s2.X or
                b1.Y+s1.Y < b2.Y or 
                b1.Y>b2.Y+s2.Y or                                       
                b1.Z+s1.Z < b2.Z or 
                b1.Z>b2.Z+s2.Z )                                      
end
function collisions.shouldjump(entity,pos,p,s,pri)
    local hitbox = entity.HitBoxSize
    local feetpos = pos.Y - hitbox.y/2 
    local blockfeet = p.Y - s.Y/2
    local jumpneeded = s.Y -(feetpos - blockfeet)
    local blockheight =  p.Y + s.Y/2
    blockheight = vector3(p.X,blockheight,p.Z)
    if jumpneeded > s.Y or jumpneeded<= 0 then
        return nil
    end
    if entity.JumpWhen.SmallJump >= jumpneeded  then
        return "Small",jumpneeded,blockheight
    elseif entity.JumpWhen.FullJump >= jumpneeded then
        return "Full",jumpneeded,blockheight
    end
    return nil
end
function collisions.entityvsterrainloop(entity,position,velocity,whitelist,looop,old)
    local hitbox = entity.HitBoxSize
    local min = vector3(
        position.X-hitbox.x/2+(velocity.X <0 and velocity.X-1 or 0)   ,
        position.Y-hitbox.y/2+(velocity.Y <0 and velocity.Y-1 or 0), 
        position.Z-hitbox.z/2+(velocity.Z <0 and velocity.Z-1 or 0)   
    )   
    local max = vector3(
        position.X+hitbox.X/2 +(velocity.X >0 and velocity.X+1 or 0),
        position.Y+hitbox.Y/2+(velocity.Y >0 and velocity.Y+1 or 0), 
        position.Z+hitbox.Z/2+(velocity.Z >0 and velocity.Z+1 or 0)   
    )
    local normal = vector3(0,0,0)
    local mintime = 1
    local zack 
    local gridsize = 1
    local bppos,bpsize = collisions.GetBroadPhase(position,vector3(hitbox.X,hitbox.Y,hitbox.Z),velocity)
    for x = min.X,getincreased(min.X,max.X,gridsize),gridsize do    
        for y = min.Y,getincreased(min.Y,max.Y,gridsize),gridsize do
            for z = min.Z,getincreased(min.Z,max.Z,gridsize),gridsize do
                local block,a = refunction.GetBlock(vector3(x,y,z),false,position)

                if whitelist and whitelist[a] then continue end
                if block then
                   local typejump 
                   local needed
                   local maxheight
                   local currentmin = 1
                   local newpos ,newsize = collisions.DealWithRotation(block)
                   if  collisions.AABBcheck(bppos,newpos,bpsize,newsize,true) then  
                    local collisiontime1,newnormal1 = collisions.SweaptAABB(position,newpos,vector3(hitbox.X,hitbox.Y,hitbox.Z),newsize,velocity,mintime)
                    if collisiontime1 < 1 then
                       zack = {newpos,newsize}
                        currentmin = collisiontime1
                        normal = newnormal1
                        local a,b,c = collisions.shouldjump(entity,position,newpos,newsize)
                        if not needed or c.Y >=maxheight.Y  then
                          typejump,needed,maxheight =  a,b,c
                        end
                     end
                    end
                    mintime = currentmin < mintime and currentmin or mintime
                     if mintime < 1 and not looop and typejump  then
                        local direaction = refunction.convertPositionto(refunction.GetUnit(maxheight,position),"table")

                    end
                end
            end 
        end 
    end 
    return mintime,normal,zack,velocity
end
--b1:entitypos b2:blockpos s1:entitysize s2:blocksize o1:entity orientation o2:block orientation 
function  collisions.SweaptAABB(b1,b2,s1,s2,velocity,mintime)
    local aaa = b2
    b1 = vector3(b1.X-s1.X/2,b1.Y-s1.Y/2,b1.Z-s1.Z/2)--get the bottem left corners
    b2 = vector3(b2.X-s2.X/2,b2.Y-s2.Y/2,b2.Z-s2.Z/2)
    local InvEntry = vector3()
    local InvExit = vector3()
    local Entry = vector3()
    local Exit = vector3()
    if velocity.X> 0 then
        InvEntry.X = b2.X - (b1.X+s1.X)
        InvExit.X = (b2.X+s2.X) - b1.X

        Entry.X = InvEntry.X/velocity.X
        Exit.X = InvExit.X/velocity.X
    elseif velocity.X <0 then
        InvEntry.X = (b2.X+s2.X) - b1.X
        InvExit.X = b2.X - (b1.X+s1.X)
       
        Entry.X = InvEntry.X/velocity.X
        Exit.X = InvExit.X/velocity.X
    else
        InvEntry.X = (b2.X+s2.X) - b1.X
        InvExit.X = b2.X - (b1.X+s1.X)

        Entry.X = -math.huge
        Exit.X = math.huge
    end

    if velocity.Y> 0 then
        InvEntry.Y = b2.Y - (b1.Y+s1.Y)
        InvExit.Y = (b2.Y+s2.Y) - b1.Y
        Entry.Y = InvEntry.Y/velocity.Y
        Exit.Y = InvExit.Y/velocity.Y
    elseif velocity.Y <0 then
        InvEntry.Y = (b2.Y+s2.Y) - b1.Y
        InvExit.Y = b2.Y - (b1.Y+s1.Y)
        Entry.Y = InvEntry.Y/velocity.Y
        Exit.Y = InvExit.Y/velocity.Y
    else
        InvEntry.Y = (b2.Y+s2.Y) - b1.Y
        InvExit.Y = b2.Y - (b1.Y+s1.Y)

        Entry.Y = -math.huge
        Exit.Y = math.huge
    end

    if velocity.Z> 0 then
        InvEntry.Z = b2.Z - (b1.Z+s1.Z)
        InvExit.Z = (b2.Z+s2.Z) - b1.Z
        Entry.Z = InvEntry.Z/velocity.Z
        Exit.Z = InvExit.Z/velocity.Z
    elseif velocity.Z <0 then
        InvEntry.Z = (b2.Z+s2.Z) - b1.Z
        InvExit.Z = b2.Z - (b1.Z+s1.Z)
        Entry.Z = InvEntry.Z/velocity.Z
        Exit.Z = InvExit.Z/velocity.Z
    else
        InvEntry.Z = (b2.Z+s2.Z) - b1.Z
        InvExit.Z = b2.Z - (b1.Z+s1.Z)

        Entry.Z = -math.huge
        Exit.Z = math.huge
    end
    local entrytime = math.max(math.max(Entry.X,Entry.Z),Entry.Y)
    local a 
    if entrytime == Entry.X then
        a = "a" 
    elseif entrytime == Entry.Y then
        a = "b" 
    else
        a = "c" 
    end
    if entrytime >= mintime then return 1.0,1 end
    if entrytime < 0 then return 1.0,entrytime end

    local exittime = math.min(math.min(Exit.X,Exit.Z),Exit.Y)
    if entrytime > exittime then return 1.0,3 end
    if Entry.X > 1 then
        if b2.X + s2.X <b1.X or b1.X + s1.X > b2.X then
            return 1,4
        end
    end
    if Entry.Y > 1 then
        if b2.Y + s2.Y <b1.Y or b1.Y + s1.Y > b2.Y then
            return 1,5
        end
    end
    if Entry.Z > 1 then
        if b2.Z + s2.Z <b1.Z or b1.Z + s1.Z > b2.Z then
            return 1,6
        end
    end
    local normal = vector3(0,0,0)
    if Entry.X > Entry.Z then
        if Entry.X > Entry.Y then
            normal.X = -math.sign(velocity.X)
            normal.Y = 0
            normal.Z = 0
        else
            normal.X = 0
            normal.Y = -math.sign(velocity.Y)
            normal.Z = 0
        end
    else
        if Entry.Z > Entry.Y then
            normal.X = 0
            normal.Y = 0
            normal.Z = -math.sign(velocity.X)
        else
            normal.X = 0
            normal.Y = -math.sign(velocity.Y)
            normal.Z = 0
        end 
    end
    return entrytime,normal
end
return collisions