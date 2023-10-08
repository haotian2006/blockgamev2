local RunService = game:GetService("RunService")
local collisions ={}
local qf = require(game.ReplicatedStorage.QuickFunctions)
local maindata = require(game.ReplicatedStorage.DataHandler)
local behavior = require(game.ReplicatedStorage.BehaviorHandler)
local vector3 = Vector3.new--function(x,y,z)return {X = x or 0 , Y= y or 0,Z= z or 0} end
local debris = require(game.ReplicatedStorage.Libarys.Debris).CreateFolder("Collision")
local rotationLib = require(game.ReplicatedStorage.Libarys.RotationData)
local function getincreased(min,goal2,increased2)
	local direaction = min - goal2
	return goal2 +increased2*-math.sign(direaction)
end
local function round(x)
    return math.floor(x+.5)
end
function  collisions.newSettings()
    return {
        BlackList = {},
        CanBeLiquid = 0,
        CanBeSolid = 0,
        CanBeTransparent =0,
        CanCollide = 0,

    }
end
function  collisions.GetBlocksInBounds(loc,size,Setting)
    local position = loc
    local hitbox = size
    local min = vector3(
        position.X-hitbox.X/2,
        position.Y-(hitbox.Y/2),
        position.Z-hitbox.X/2
    )   
    local max = vector3(
        position.X+hitbox.X/2,
        position.Y+(hitbox.Y/2),
        position.Z+hitbox.X/2 
)
    local gridsize = .5
--a
    local whitelist = {}
    for x = min.X,getincreased(min.X,max.X,gridsize),gridsize do    
        for y = min.Y,getincreased(min.Y,max.Y,gridsize),gridsize do
            for z = min.Z,getincreased(min.Z,max.Z,gridsize),gridsize do
                local block,coords = maindata.GetBlock(x,y,z,true)
                if whitelist and whitelist[coords] then continue end
                if block and not block:isFalse() then
                    whitelist[coords] = true
                    local cx,cz =  qf.GetChunkfromReal(x,y,z,true)
                    local bx,by,bz = unpack(coords:split(","))
                    local a = qf.cbt("chgrid",'grid',cx,cz,bx,by,bz)
                    bx,by,bz = a.X,a.Y,a.Z
                   local newpos ,newsize = vector3(bx,by,bz),vector3(1,1,1)--collisions.DealWithRotation(block)
                   local hbdata,CanCollide = collisions.GenerateHitboxes(block,newpos)
                   local loop = 0
                   if not CanCollide then continue end 
                   for i,v in hbdata do
                    local newpos,newsize = v[2],v[1]
                    if collisions.AABBcheck(vector3(position.X, position.Y,position.Z),newpos,vector3(hitbox.X,hitbox.Y,hitbox.X),newsize) then
                        return true,block
                    end
                   end
                end

            end 
        end 
    end 
end
function  collisions.IsGrounded(entity,CheckForBlockAboveInstead)
    local position = entity.Position
    local hitbox = entity.Hitbox
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
    for x = min.X,getincreased(min.X,max.X,gridsize),gridsize do    
        for y = min.Y,getincreased(min.Y,max.Y,gridsize),gridsize do
            for z = min.Z,getincreased(min.Z,max.Z,gridsize),gridsize do
                local block,coords = maindata.GetBlock(x,y,z,true)
                if whitelist and whitelist[coords] then continue end
                if block and not block:isFalse() then
                    whitelist[coords] = true
                    local cx,cz =  qf.GetChunkfromReal(x,y,z,true)
                    local bx,by,bz = unpack(coords:split(","))
                    local a = qf.cbt("chgrid",'grid',cx,cz,bx,by,bz)
                    bx,by,bz = a.X,a.Y,a.Z
                   local newpos ,newsize = vector3(bx,by,bz),vector3(1,1,1)--collisions.DealWithRotation(block)
                   local hbdata,CanCollide = collisions.GenerateHitboxes(block,newpos)
                   local loop = 0
                   if not CanCollide then continue end 
                   for i,v in hbdata do
                    local newpos,newsize = v[2],v[1]
                    if collisions.AABBcheck(vector3(position.X, position.Y-(0.01*invert),position.Z),newpos,vector3(hitbox.X,hitbox.Y,hitbox.X),newsize) then
                        return true,block
                    end
                   end
                end

            end 
        end  
    end 
    return false
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
function collisions.AABBvsPoint(point:Vector3,b1,s1)
    local min = vector3(b1.X-s1.X/2,b1.Y-s1.Y/2,b1.Z-s1.Z/2)
    local max = vector3(b1.X+s1.X/2,b1.Y+s1.Y/2,b1.Z+s1.Z/2)
    return(
        point.X >= min.X and
        point.X <= max.X and 
        point.Y >= min.Y and
        point.Y <= max.Y and 
        point.Z >= min.Z and
        point.Z <= max.Z  
    )
end 
function collisions.AABBcheck(b1,b2,s1,s2,isbp)
    if  isbp == true then
    else
        b1 = vector3(b1.X-s1.X/2,b1.Y-s1.Y/2,b1.Z-s1.Z/2)
    end
    b2 = vector3(b2.X-s2.X/2,b2.Y-s2.Y/2,b2.Z-s2.Z/2)
    return not (b1.X+s1.X <= b2.X or 
    b1.X>b2.X+s2.X or
    b1.Y+s1.Y < b2.Y or 
    b1.Y>b2.Y+s2.Y or                                     
    b1.Z+s1.Z < b2.Z or 
    b1.Z>b2.Z+s2.Z    )                             
end
local a = workspace.HitboxL
function  HitboxL(x,y,z)  
    a.Position = Vector3.new(x,y,z)*3 a.Anchored = true   
end
function b(x,y,z) local a = workspace.IDK a.Size = Vector3.new(3,3,3) a.Position = Vector3.new(x,y,z)*3 a.Anchored = true end 
function c(x,y,z) local a = workspace.IDK:Clone() a.Parent = workspace a.Size = Vector3.new(3,3,3) a.Position = Vector3.new(x,y,z)*3 a.Anchored = true game:GetService("Debris"):AddItem(a,1) end 
function  collisions.CalculateNormal(p1:Vector3,s1,p2,s2)
    local d:Vector3 = p1-p2
    local dx = d:Dot(vector3(1,0,0))
    if dx > s2.X/2 then dx = s2.X/2 end
    if dx < s2.X/2 then dx = -s2.X/2 end

    local dy = d:Dot(vector3(0,1,0))
    if dy > s2.Y/2 then dy = s2.Y/2 end
    if dy < s2.Y/2 then dy = -s2.Y/2 end

    local dz = d:Dot(vector3(0,0,1))
    if dz > s2.Z/2 then dz = s2.Z/2 end
    if dz < s2.Z/2 then dz = -s2.Z/2 end
    local contactpoint:Vector3 = p2 + dx*vector3(1,0,0)+dy*vector3(0,1,0)+dz*(vector3(0,0,1))
    local normal = (p1-contactpoint).Unit
    return vector3(round(normal.X),round(normal.Y),round(normal.Z))
end
function collisions.shouldjump(entity,bp,bs)
    local pos = entity.Position
    local hitbox = entity.Hitbox
    local feetpos = pos.Y - hitbox.y/2 
    local blockfeet = bp.Y - bs.Y/2
    local jumpneeded = bs.Y -(feetpos - blockfeet)
    local blockheight =  bp.Y + bs.Y/2
    blockheight = vector3(bp.X,blockheight,bp.Z)
    if jumpneeded > bs.Y or jumpneeded<= 0 then
        return nil
    end
    if (entity.MinTpHeight or .5) >= jumpneeded  then
       -- print(blockheight)
        return "Small",jumpneeded,blockheight
    elseif (entity.JumpHeight or 1) >= jumpneeded then
        return "Full",jumpneeded,blockheight
    end
    return nil
    
end
function collisions.AABBvsTerrain(position,hitbox,CanCollideMatters)
    local min = vector3(
        position.X-hitbox.X/2,
        position.Y-hitbox.Y/2, 
        position.Z-hitbox.Z/2   
    )   
   -- print(position.Z-hitbox.X,min.Z,(velocity.Z <0 and velocity.Z-.25 or 0) )
    local max = vector3(
        position.X+hitbox.X/2,
        position.Y+hitbox.Y/2, 
        position.Z+hitbox.Z/2   
    ) 
    local gridsize =.1
    local whitelist = {}
    for x = min.X,getincreased(min.X,max.X,gridsize),gridsize do    
        for y = min.Y,getincreased(min.Y,max.Y,gridsize),gridsize do
            for z = min.Z,getincreased(min.Z,max.Z,gridsize),gridsize do
                local block,coords = maindata.GetBlock(x,y,z,true)
                if whitelist and whitelist[coords] then continue end
                if block and tostring(block) ~= "NULL" and not block:isFalse()  then
                    whitelist[coords] = true
                    local cx,cz =  qf.GetChunkfromReal(x,y,z,true)
                    local bx,by,bz =  coords:match("([^,]*),?([^,]*),?([^,]*)")
                    local a = qf.cbt("chgrid",'grid',cx,cz,bx,by,bz)
                    bx,by,bz = a.X,a.Y,a.Z
                   local newpos ,newsize = vector3(bx,by,bz),vector3(1,1,1)--collisions.DealWithRotation(block)
                   local hbdata,cancollide = collisions.GenerateHitboxes(block,newpos)
                   local loop = 0
                   if not cancollide and CanCollideMatters then continue end 
                   for i,v in hbdata do
                    local newpos,newsize = v[2],v[1]
                        local found = collisions.AABBcheck(vector3(position.X, position.Y,position.Z),newpos,vector3(hitbox.X,hitbox.Y,hitbox.Z),newsize)
                        if found  then 
                        return true,block,qf.combinetostring(bx,by,bz)
                        end  
                    end
                end
            end 
        end 
    end 
end
local rotationHitboxs = {
    ["0,0,0"] = function(size)
        return size
    end,
    ["1,0,0"] = function(size)
        return vector3(size.X,size.Z,size.Y)  
    end,
    ["0,1,0"] = function(size)
        return vector3(size.Z,size.Y,size.X)
    end,
    ["0,0,1"] = function(size)
        return vector3(size.Y,size.X,size.Z)
    end,
    ["0,1,1"] = function(size)
        return vector3(size.Z,size.X,size.Y)
    end,
    ["1,1,0"] = function(size)
        return vector3(size.Y,size.Z,size.X)
    end,
}
local function makeallrhitboxs()-- making this function feels wrong but basicly it creates every possible rotation
	-- 1,0,0 --> -1,0,0 --> 1,-0,0 --> 1,0,-0 --> -1,-0,0 --> -1,-0,-0 --> 1,-0,-0 
	for i,v in rotationHitboxs do
		local values = string.split(i,',')
		for n =1,3 do
			local c = table.clone(values)
			c[n] = -tonumber(c[n])
			rotationHitboxs[table.concat(c,',')] = v
		end
	end
end
--calls it 3 times because yeah
makeallrhitboxs()
makeallrhitboxs()
makeallrhitboxs()

function collisions.RotateHitBoxs(rotation,hitboxinfo)
    if not rotation  then return hitboxinfo end 
    local new = {}
    local crotation = rotationLib.convertToCFrame(rotation)
    for i,v in hitboxinfo do
        if i == 'CanCollide' then continue end 
        new[i] = {Size = rotationHitboxs[rotation](v.Size),
        Offset = (crotation*
        CFrame.new(v.Offset or Vector3.zero)).
        Position
    }
    end
    return new
end
function collisions.GetBlockHitBox(data)
    local hitboxinfo = {}
    local cancollide = true
    --print(data)
    local Type,Ori = data:getName(),data:getFullRotation()
    local bdata = data:getComponentData()
    local hb = behavior.GetBlockHb(bdata.Hitbox)
    if hb then
        if type(hb) == "table" then
            hitboxinfo = hb
        else
            hitboxinfo = {{Size = hb}} 
        end
    end
    if Ori then
        hitboxinfo = collisions.RotateHitBoxs(Ori,hitboxinfo)
    end
    hitboxinfo['CanCollide'] = bdata.CanCollide 
    cancollide = bdata.CanCollide 

    return hitboxinfo,cancollide
end
function collisions.GenerateHitboxes(data,position)
    if data:isNULL() then
        return {{Vector3.one,position}},true
    end
    local hb = collisions.GetBlockHitBox(data)
    local t = {}
    local CanCollide = true
    for i,v in hb do
        if i == "CanCollide" then
            CanCollide = v
            continue
        end
        local size,offset = v.Size or Vector3.one,v.Offset or Vector3.zero
        t[i] = {size,position + offset}
    end
    return t,CanCollide 
end
function  collisions.entityvsterrain(entity,velocity,IsRay)
    local oldv = velocity
    local velocity = velocity
    local position = entity.Position
    local oldp = vector3(position.X,position.Y,position.Z)
   -- print(velocity.Y)
    local remainingtime = 1
    local MinTime
    local normal = {X =0,Y=0,Z=0}
    local allnormal = {X =0,Y=0,Z=0}
    local bba
    local a,d= false
    local jumpa 
    local bbaaa
    for i =1,3,1 do
    velocity = vector3(
        velocity.X * (1-math.abs(normal.X))*remainingtime,
        velocity.Y * (1-math.abs(normal.Y))*remainingtime,
        velocity.Z * (1-math.abs(normal.Z))*remainingtime
        )
        local bb
        local jump
        MinTime,normal,bb,velocity,a,d,jump = collisions.entityvsterrainloop(entity,position,velocity,{},IsRay,oldv)
        if jump then
            jumpa = true
        end
        bbaaa = bb or bbaaa
        if a then position = a end 
        if bb and IsRay then
            return nil,nil,bb
        end
        bba = bba or bb
        allnormal.X += normal.X
        allnormal.Y += normal.Y
        allnormal.Z += normal.Z
        local placevelocity = Vector3.new(velocity.X,velocity.Y,velocity.Z)*MinTime
        position += placevelocity
        if MinTime <1 then
            --epsilon 
            if velocity.X >0 and velocity.X ~= -9.99999993922529e-09 then
                position = qf.EditVector3(position,"x",position.X - 0.001)
            elseif velocity.X <0 then
                position = qf.EditVector3(position,"x",position.X + 0.001)
            end
            if velocity.Y >0 then
                position = qf.EditVector3(position,"y",position.Y - 0.0001)
            elseif velocity.Y <0 then
                position = qf.EditVector3(position,"y",position.Y + 0.001)
            end
            if velocity.Z >0 and velocity.Z ~= -9.99999993922529e-09 then
                position = qf.EditVector3(position,"z",position.Z - 0.001)
            elseif velocity.Z <0 then
                position = qf.EditVector3(position,"z",position.Z + 0.001)
            end
            -- if a then
            --     local info = Ray.newInfo()
            --     info.IgnoreEntities = true
            --     info.RaySize = Vector3.new(entity.Hitbox.X,.02,entity.Hitbox.X)
            --     info.Increaseby = 0.05
            --     info.BreakOnFirstHit = true
            --     local ray = Ray.Cast(position,-Vector3.new(0,(entity.MinTpHeight or .5)+.1,0)+entity.Hitbox.Y/2,info)
            --     if ray and ray.Objects[1]  then
            --         local hit = ray.Objects[1]
                    
            --         if (hit.PointOfInt -ray.Origin).Magnitude <= (entity.MinTpHeight or .5)+0.001 +entity.Hitbox.Y/2 then
            --             position = Vector3.new(position.X,hit.PointOfInt.Y+entity.Hitbox.Y/2,position.Z)
            --         end
            --     end
            -- end
        end
        remainingtime = 1.0-MinTime
        if remainingtime <=0 then break end
        
    end
    if RunService:IsClient() then
        --print(bbaaa)
    end
    if  entity.NotSaved and jumpa ==false then 
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
    elseif jumpa then
        entity.NotSaved.NoFall = false
        entity.NotSaved.NOGRAVITY = false
    end
    return  position,allnormal,bba,jumpa
end
local a = false
function collisions.entityvsterrainloop(entity,position,velocity,whitelist,looop,old)
    local j = false
    local hitbox = entity.Hitbox
    local min = vector3(
        position.X-hitbox.X/2+(velocity.X <0 and velocity.X or 0)   ,
        position.Y-hitbox.Y/2+(velocity.Y <0 and velocity.Y or 0), 
        position.Z-hitbox.X/2+(velocity.Z <0 and velocity.Z or 0)   
    )   
   -- print(position.Z-hitbox.X,min.Z,(velocity.Z <0 and velocity.Z-.25 or 0) )
    local max = vector3(
        position.X+hitbox.X/2 +(velocity.X >0 and velocity.X or 0),
        position.Y+hitbox.Y/2+(velocity.Y >0 and velocity.Y or 0), 
        position.Z+hitbox.X/2+(velocity.Z >0 and velocity.Z or 0)   
    )
   -- HitboxL(max.X,min.Y,min.Z)
    local normal = {X =0,Y=0,Z=0}
    local mintime = 1
    local zack 
    local gridsize = .5
    local bppos,bpsize = collisions.GetBroadPhase(position,vector3(hitbox.X,hitbox.Y,hitbox.X),velocity)
    whitelist = whitelist or {}
    local first = qf.deepCopy(whitelist)
 --   HitboxL(getincreased(min.X,max.X,gridsize),max.Y,max.Z)
   -- print(min)
    for x = min.X,getincreased(min.X,max.X,gridsize),gridsize do    
        for y = min.Y,getincreased(min.Y,max.Y,gridsize),gridsize do
            for z = min.Z,getincreased(min.Z,max.Z,gridsize),gridsize do
                local block,coords = maindata.GetBlock(x,y,z)
                if whitelist and whitelist[coords] then continue end
                if block and tostring(block)  then
                    local cx,cz =  qf.GetChunkfromReal(x,y,z,true)
                    local bx,by,bz =  coords:match("([^,]*),?([^,]*),?([^,]*)")
                    local a = qf.cbt("chgrid",'grid',cx,cz,bx,by,bz)
                    bx,by,bz = a.X,a.Y,a.Z
                   local typejump, needed,maxheight
                   local currentmin = 1
                   local newpos ,newsize = vector3(bx,by,bz),vector3(1,1,1) 
                   local hbdata,CanCollide = collisions.GenerateHitboxes(block,newpos)
                   local loop = 0
                   if not CanCollide then continue end 
                   for i,v in hbdata do
                    local newpos,newsize = v[2],v[1]
                    if whitelist[coords..','..loop] then
                       continue 
                    end
                    if  collisions.AABBcheck(bppos,newpos,bpsize,newsize,true) then  
                        local collisiontime,newnormal1 = collisions.SweaptAABB(position,newpos,vector3(hitbox.X,hitbox.Y,hitbox.X),newsize,velocity,mintime)
                        if collisiontime < 1 then
                            if collisiontime < currentmin or loop == 0 then
                                zack = {block,coords,newpos,newsize,i}
                                currentmin = collisiontime
                                normal = newnormal1
                            end
                            local a,b,c = collisions.shouldjump(entity,newpos,newsize)
                            if a and (not needed or c.Y >=maxheight.Y ) then
                                typejump, needed,maxheight = a,b,c
                            end
                         end
                       end
                       whitelist[coords..','..((loop == 0 and #hbdata == 1) and '' or loop)] = true 
                       loop +=1
                   end
                    mintime = currentmin < mintime and currentmin or mintime
                     if mintime < 1 and (typejump) then
                        local dir = (maxheight-position).Unit
                        if typejump == "Small" and entity.Data and entity.Data.Grounded and needed >=0.1 then
                              needed += 0.023
                              first[coords] = true
                              local m2,n2,z2 = collisions.entityvsterrainloop(entity,vector3(position.X,position.Y,position.Z),vector3(velocity.X,velocity.Y+needed,velocity.Z),first,"Small")
                              if m2 <1 then
                                if looop then
                                    return .1
                                end
                              else
                                local before = position
                                entity.NotSaved.NOGRAVITY = true
                                if RunService:IsClient() and false then
                                    local p = Instance.new("Part",workspace)
                                    p.Color = Color3.new(1, 0, 0)
                                    p.Size = Vector3.new(3,.1,3)
                                    game:GetService("Debris"):AddItem(p,5)
                                    p.Anchored = true
                                    p.Position = (position- vector3(0,entity.Hitbox.y/2)) *3
                                    print( "Feet",(position- vector3(0,entity.Hitbox.y/2)).y)
                                    local p = Instance.new("Part",workspace)
                                    p.Color = Color3.new(0.368627, 1, 0)
                                    p.Size = Vector3.new(3,.1,3)
                                    game:GetService("Debris"):AddItem(p,5)
                                    p.Anchored = true
                                    p.Position = (position- vector3(0,entity.Hitbox.y/2) + vector3(0,needed,0))*3
                                    print( "TP",(position- vector3(0,entity.Hitbox.y/2)+ vector3(0,needed,0)).y)
                                end
                                position += vector3(0,needed,0)
                                local bfv = velocity
                                if velocity.Y <0 then
                                    velocity = vector3(velocity.X,0,velocity.Z)-- velocity.Y 
                                end
                                local m2,n2,z2 = collisions.entityvsterrainloop(entity,position,velocity,{},"Small")
                                if m2 <1 then
                                    position = before
                                    velocity = bfv
                                    return  m2,n2,z2,velocity,position,nil,false
                                else
                                   -- print(needed)
                                    return m2,n2,z2 ,velocity,position,1,false
                                end
                              end
                           elseif typejump == "Full" and (entity["AutoJump"]or false)   then
                            first[coords] = true
                               local m2,n2,z2 = collisions.entityvsterrainloop(entity,vector3(position.X,position.Y,position.Z),vector3(velocity.X, 1,velocity.Z),first,"Full")
                               if not m2 or m2 <1 then
                                if looop then
                                    return .1
                                end
                                j = true
                               -- print(z2,zack)
                               else
                               end
                           end

                    end
                end
            end 
        end 
    end 
    return mintime,normal,zack,velocity,nil,nil,j
end
--b1:entitypos b2:blockpos s1:entitysize s2:blocksize o1:entity orientation o2:block orientation 

function  collisions.SweaptAABB(b1,b2,s1,s2,velocity,mintime)
    local aaa = b2
    local a = b1.X-s1.X/2
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
      --  print(Entry.X)
    elseif velocity.X <0 then
        InvEntry.X = (b2.X+s2.X) - b1.X
        InvExit.X = b2.X - (b1.X+s1.X)
        Entry.X = InvEntry.X/velocity.X
        Exit.X = InvExit.X/velocity.X
    else
        -- InvEntry.X = (b2.X+s2.X) - b1.X
        -- InvExit.X = b2.X - (b1.X+s1.X)

        Entry.X = -math.huge
        Exit.X = math.huge
    end
  --  print(InvEntry.X,Entry.X,velocity.X)
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
    if entrytime == Entry.X then
        a = "a"
    elseif entrytime == Entry.Y then
        a = "b"
    else 
        a = "c"
    end
    if entrytime == Entry.X and entrytime == Entry.Z then
        a = "d"
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
            normal.Z = -math.sign(velocity.Z)
        else
            normal.X = 0
            normal.Y = -math.sign(velocity.Y)
            normal.Z = 0
        end 
    end
    return entrytime,normal
end
--serveronly 
if RunService:IsClient() then return collisions end
local Push = 0.3
function collisions.entityvsentity(entity,entity2)
    local h1,h2 = entity.Hitbox,entity2.Hitbox
    if not entity["CanCollideWithEntities"] or not entity2["CanCollideWithEntities"] or entity:GetState('Dead') or entity2:GetState('Dead')  then return end 
    if collisions.AABBcheck(entity.Position,entity2.Position,vector3(h1.X,h1.Y,h1.X),vector3(h2.X,h2.Y,h2.X)) then
        local p1,p2 = entity.Position,entity2.Position
        local x,z = p1.X - p2.X,p1.Z - p2.Z
        local sqrtdistance = x*x + z*z
        local distance = math.sqrt(sqrtdistance)
        local p = vector3(p2.X - p1.X,0,p2.Z-p1.Z)/math.max(distance,0.0001)
        local force = Push/math.max(sqrtdistance,0.2)
        local mass1,mass2 = entity.Mass or 1, entity2.Mass or 1
        mass1,mass2 = math.max(.1,mass1), math.max(.1,mass2)
        local force1 = force*(mass2/mass1)--*task.wait()
        local force2 = force*(mass1/mass2)--*task.wait()
        entity:AddVelocity("EntityCollide",vector3(-p.X*force1,0,-p.Z*force1))
        entity2:AddVelocity("EntityCollide",vector3(p.X*force2,0,p.Z*force2))
    end
end
return collisions