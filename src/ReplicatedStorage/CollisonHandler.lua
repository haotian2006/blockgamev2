local RunService = game:GetService("RunService")
local collisions ={}
local qf = require(game.ReplicatedStorage.QuickFunctions)
local maindata = require(game.ReplicatedStorage.DataHandler)
local vector3 = Vector3.new
local function getincreased(min,goal2,increased2)
	local direaction = min - goal2
	return goal2 +increased2*-math.sign(direaction)
end
local function round(x)
    return math.floor(x+.5)
end
function  collisions.IsGrounded(entity)
    local position = entity.Position
    local hitbox = entity.HitBox
    local min = vector3(
        position.X-hitbox.X/2,
        position.Y-(hitbox.Y/2+0.0225),
        position.Z-hitbox.X/2
    )   
    local max = vector3(
        position.X+hitbox.X/2,
        position.Y-(hitbox.Y/2),
        position.Z+hitbox.X/2 
)
    local gridsize = 1
--a
    for x = min.X,getincreased(min.X,max.X,gridsize),gridsize do    
        for y = min.Y,getincreased(min.Y,max.Y,gridsize),gridsize do
            for z = min.Z,getincreased(min.Z,max.Z,gridsize),gridsize do
                local block,coords = maindata.GetBlock(x,y,z)
                if block then
                    local cx,cz =  qf.GetChunkfromReal(x,y,z,true)
                    --local chg =  qf.cbt("grid","chgrid",round(x),round(y),round(z) )
                    local bx,by,bz = unpack(coords:split(","))
                    local a = qf.cbt("chgrid",'grid',cx,cz,bx,by,bz)
                    bx,by,bz = a.X,a.Y,a.Z
                   local newpos ,newsize = vector3(bx,by,bz),vector3(1,1,1)--collisions.DealWithRotation(block)
                   if  collisions.AABBcheck(vector3(position.X, position.Y,position.Z),newpos,vector3(hitbox.X,hitbox.Y,hitbox.X),newsize) then 
                    return true,block
                    end  
                end

            end 
        end 
    end 
    return false
end
function  collisions.entityvsterrain(entity,velocity)
    local oldv = velocity
    local velocity = velocity
    local position = entity.Position
    local oldp = vector3(position.X,position.Y,position.Z)
   -- print(velocity.Y)
    local remainingtime = 1
    local MinTime
    local normal = {X =0,Y=0,Z=0}
    local allnormal = {X =0,Y=0,Z=0}
    for i =1,3,1 do
      
    velocity = vector3(
        velocity.X * (1-math.abs(normal.X))*remainingtime,
        velocity.Y * (1-math.abs(normal.Y))*remainingtime,
        velocity.Z * (1-math.abs(normal.Z))*remainingtime
        )
        local bb
        MinTime,normal,bb = collisions.entityvsterrainloop(entity,position,velocity,{},false,oldv)
        allnormal.X += normal.X
        allnormal.Y += normal.Y
        allnormal.Z += normal.Z
        local placevelocity = vector3(velocity.X,velocity.Y,velocity.Z)*MinTime
        position += placevelocity
        if MinTime <1 then
            --epsilon 
            if velocity.X >0 and velocity.X ~= 9.99999993922529e-09 then
                position = qf.EditVector3(position,"x",position.X - 0.001)
            elseif velocity.X <0 then
                position = qf.EditVector3(position,"x",position.X + 0.001)
            end
            if velocity.Y >0 then
                position = qf.EditVector3(position,"y",position.Y - 0.0001)
            elseif velocity.Y <0 then
                position = qf.EditVector3(position,"y",position.Y + 0.001)
            end
            if velocity.Z >0 and velocity.Z ~= 9.99999993922529e-09 then
                position = qf.EditVector3(position,"z",position.Z - 0.00001)
            elseif velocity.Z <0 then
                position = qf.EditVector3(position,"z",position.Z + 0.00001)
            end
        end
        remainingtime = 1.0-MinTime
        if remainingtime <=0 then break end
        
    end
    return  position,allnormal
end
function collisions.GetBroadPhase(b1,s1,velocity)
    b1 = vector3(b1.X-s1.X/2,b1.Y-s1.Y/2,b1.Z-s1.Z/2)
    local position = vector3(
        velocity.X >0 and b1.X or b1.X + velocity.X,
        velocity.Y >0 and b1.Y or b1.Y + velocity.Y,
        velocity.Z >0 and b1.Z or b1.Z + velocity.Z
        )
    local size = vector3(    
        velocity.X >0 and velocity.X+s1.X or s1.X - velocity.X,
        velocity.Y >0 and velocity.Y+s1.Y or s1.Y - velocity.Y,
        velocity.Z >0 and velocity.Z+s1.Z or s1.Z - velocity.Z
        )
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
function b(x,y,z) local a = workspace.IDK a.Size = Vector3.new(3,3,3) a.Position = Vector3.new(x,y,z)*3 a.Anchored = true end 
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
    local hitbox = entity.HitBox
    local min = vector3(
        position.X-hitbox.X/2+(velocity.X <0 and velocity.X-.25 or 0)   ,
        position.Y-hitbox.Y/2+(velocity.Y <0 and velocity.Y-.25 or 0), 
        position.Z-hitbox.X/2+(velocity.Z <0 and velocity.Z-.25 or 0)   
    )   
   -- print(position.Z-hitbox.X,min.Z,(velocity.Z <0 and velocity.Z-.25 or 0) )
    local max = vector3(
        position.X+hitbox.X/2 +(velocity.X >0 and velocity.X+.25 or 0),
        position.Y+hitbox.Y/2+(velocity.Y >0 and velocity.Y+.25 or 0), 
        position.Z+hitbox.X/2+(velocity.Z >0 and velocity.Z+.25 or 0)   
    )
    local normal = {X =0,Y=0,Z=0}
    local mintime = 1
    local zack 
    local gridsize = 1
    local bppos,bpsize = collisions.GetBroadPhase(position,vector3(hitbox.X,hitbox.Y,hitbox.X),velocity)
    for x = min.X,getincreased(min.X,max.X,gridsize),gridsize do    
        for y = min.Y,getincreased(min.Y,max.Y,gridsize),gridsize do
            for z = min.Z,getincreased(min.Z,max.Z,gridsize),gridsize do
                local block,coords = maindata.GetBlock(x,y,z)
                if whitelist and whitelist[coords] then continue end
                if block then
                    local cx,cz =  qf.GetChunkfromReal(x,y,z,true)
                    --local chg =  qf.cbt("grid","chgrid",round(x),round(y),round(z) )
                    local bx,by,bz = unpack(coords:split(","))
                    local a = qf.cbt("chgrid",'grid',cx,cz,bx,by,bz)
                    bx,by,bz = a.X,a.Y,a.Z
                    
                    --print(cx,cz,'|',a,"|",min.X,x,max.X)
                    --print(position,'|',x,y,z,'|',qf.cbt("chgrid",'grid',-1,1,bx,by,bz))
                   local typejump 
                   local needed
                   local maxheight
                   local currentmin = 1
                   local newpos ,newsize = vector3(bx,by,bz),vector3(1,1,1) --collisions.DealWithRotation(block)
                   if  collisions.AABBcheck(bppos,newpos,bpsize,newsize,true) then  
                    local collisiontime1,newnormal1 = collisions.SweaptAABB(position,newpos,vector3(hitbox.X,hitbox.Y,hitbox.X),newsize,velocity,mintime)
                    if collisiontime1 < 1 then
                        b(a.X,a.Y,a.Z)
                       zack = Vector2.new(newpos,newsize)
                        currentmin = collisiontime1
                        normal = newnormal1
                        -- local a,b,c = collisions.shouldjump(entity,position,newpos,newsize)
                        -- if not needed or c.Y >=maxheight.Y  then
                        --   typejump,needed,maxheight =  a,b,c
                        -- end
                     end
                    end
                    mintime = currentmin < mintime and currentmin or mintime
                     if mintime < 1 and not looop and typejump  then
                        --local direaction = refunction.convertPositionto(refunction.GetUnit(maxheight,position),"table")

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
    local InvEntry = {X =0,Y=0,Z=0}
    local InvExit = {X =0,Y=0,Z=0}
    local Entry = {X =0,Y=0,Z=0}
    local Exit = {X =0,Y=0,Z=0}
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
    local normal = {X =0,Y=0,Z=0}
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