local RunService = game:GetService("RunService")
local collisions ={}
local behavior = require(game.ReplicatedStorage.BehaviorHandler)
local vector3 = Vector3.new
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)

local ChunkHandler = require(game.ReplicatedStorage.Chunk)
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local ChunkWidth,ChunkHeight = GameSettings.getChunkSize()
local rotationLib = require(game.ReplicatedStorage.Utils.RotationUtils)
local DataH = require(game.ReplicatedStorage.Data)
local Core = require(game.ReplicatedStorage.Core)
local Shared:Core.Shared
local EntityService:Core.EntityService
task.spawn(function()
    Shared = Core.await("Shared")::Core.Shared
    EntityService = Shared.awaitModule("EntityService")::Core.EntityService
end)
local function getincreased(min,goal2,increased2)
	local direction = min - goal2
	return goal2 +increased2*-math.sign(direction)
end
collisions.calculateAdjustedGoal = getincreased
local function round(x)
    return math.floor(x+.5)
end

function collisions.getBlock(x,y,z)
    local cx,cz = ConversionUtils.getChunk(x, y, z)
    local chunk = DataH.getChunk(cx,cz)
    local localized = Vector3.new(round(x)%ChunkWidth+1,round(y),round(z)%ChunkWidth+1)
    local Grid = Vector3.new(round(x),round(y),round(z))
    if chunk then
        if localized.Y > ChunkHeight or localized.Y <=0 then
            return false,localized,Grid
        end
        local b = ChunkHandler.getBlockAt(chunk,localized.X,localized.Y,localized.Z)
        return b,localized,Grid
    else
       return -1,localized,Grid
    end
end

function collisions.createEntityParams(Guids,Types,WhiteList,checkGlobal)
    local guid = {}
    local types = {}
    for i,v in Guids or {} do
        guid[v] = true
    end
    for i,v in Types or {} do
        types[v] = true
    end
    return {
        Guids = guid,
        Types = types,
        CheckGlobal = checkGlobal,
        IsWhiteList = WhiteList,
    }
end

function collisions.getEntitiesInBox(center,size,EntityParams)


    EntityParams = EntityParams or collisions.createEntityParams()
    local entitiesInBox = {}
    local halfSize = size / 2

    local minCorner = center - halfSize
    local maxCorner = center + halfSize

    local minX, minY, minZ = minCorner.X, minCorner.Y, minCorner.Z
    local maxX, maxY, maxZ = maxCorner.X, maxCorner.Y, maxCorner.Z

    local index = 1
    
    local Guids = EntityParams.Guids
    local types = EntityParams.Types

    local IsBlack = not EntityParams.IsWhiteList

    if not EntityParams.CheckGlobal then
        local centerX = (center.X // 8)
        local centerZ = (center.Z // 8)

        local sizeX,sizeZ = (size/8).X,(size/8).Z
        local minCX = centerX - math.ceil(sizeX)
        local maxCX = centerX + math.ceil(sizeX)
        local minCZ = centerZ - math.ceil(sizeZ)
        local maxCZ = centerZ + math.ceil(sizeZ)

        for x = minCX, maxCX do
            for z = minCZ, maxCZ do
                local coords = vector3(x,0,z)
                local chunk = DataH.getChunkFrom(coords)
                if not chunk then continue end 
                for i,entity:Core.Entity in chunk.Entities do
                    if (Guids[entity.Guid] or types[entity.Type]) and IsBlack then continue end 
                    local HitBox = EntityService.getHitbox(entity)
                    local Size = HitBox/2
                    local entityMinCorner = entity.Position - Size
                    local entityMaxCorner = entity.Position + Size
                  if entityMaxCorner.X > minX and
                       entityMinCorner.X < maxX and
                       entityMaxCorner.Y > minY and
                       entityMinCorner.Y < maxY and
                       entityMaxCorner.Z > minZ and
                       entityMinCorner.Z < maxZ then
                        entitiesInBox[index] = entity
                        index+=1
                    end
                end
            end
        end
    else
        for _, entity:Core.Entity in     DataH.getAllEntities() do
            if (Guids[entity.Guid] or types[entity.Type]) and IsBlack then continue end 
            local HitBox = EntityService.getHitbox(entity)
            local Size = HitBox/2
            local entityMinCorner = entity.Position - Size
            local entityMaxCorner = entity.Position + Size
          if entityMaxCorner.X > minX and
               entityMinCorner.X < maxX and
               entityMaxCorner.Y > minY and
               entityMinCorner.Y < maxY and
               entityMaxCorner.Z > minZ and
               entityMinCorner.Z < maxZ then
                entitiesInBox[index] = entity
                index+=1
            end
        end
    end

    return entitiesInBox
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
			c[n] = -(tonumber(c[n]) or 1)
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
    local hb-- = behavior.GetBlockHb(bdata.Hitbox)
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
    if true then
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
    local entryTime = math.max(math.max(Entry.X,Entry.Z),Entry.Y)

    if entryTime >= mintime then return 1.0,1 end
    if entryTime < 0 then return 1.0,entryTime end

    local exitTime = math.min(math.min(Exit.X,Exit.Z),Exit.Y)
    if entryTime > exitTime then return 1.0,3 end
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
    local normal 
    if Entry.X > Entry.Z then
        if Entry.X > Entry.Y then
            normal = vector3(-math.sign(velocity.X),0,0)
        else
            normal = vector3(0,-math.sign(velocity.Y),0)
        end
    else
        if Entry.Z > Entry.Y then
            normal = vector3(0,0, -math.sign(velocity.Z))
        else
            normal = vector3(0,-math.sign(velocity.Y),0)
        end 
    end
    return entryTime,normal
end
--serverOnly 
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