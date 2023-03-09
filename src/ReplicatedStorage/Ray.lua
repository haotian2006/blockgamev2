local ray = {}
local Data = require(game.ReplicatedStorage.DataHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local collisonH = require(game.ReplicatedStorage.CollisonHandler)
local debugpart = Instance.new("Part")
debugpart.Size = Vector3.new(.1,.1,.1)
debugpart.Anchored = true
debugpart.Shape = Enum.PartType.Ball
debugpart.Material = Enum.Material.Neon
debugpart.Transparency = .5
function ray.newInfo()
    return {
        BreakOnFirstHit = false,
        IgnoreEntities = false,
        IgnoreBlocks = false,
        BlackList = {},
        GetNormal = false,
        Debug = false,
        RaySize = Vector3.new(.1,.1,.1),
        Increaseby = .1,
        IgnoreDead= true,
    }
end
function ray.newData()
    return {
        Objects = {},
        Origin = Vector3.zero,
        RayInfo = {},
    }
end
function ray.Cast(Origin: Vector3, Direction: Vector3,rayinfo)  
    rayinfo = rayinfo or ray.newInfo()
    local newlist = {}
    for i,v in rayinfo.BlackList do newlist[v] = true end
    rayinfo.BlackList = newlist
    if typeof(Origin) ~= "Vector3" or typeof(Direction) ~= "Vector3" then error("Wrong Arguments sent") end
    local increaseby =  rayinfo.Increaseby or .1
    local unit = Direction.Unit*increaseby
    local currentposition = Origin
    local distanceneeded = (Direction).Magnitude
    local distancetraveled = 0
    local raydata = ray.newData()
    raydata.RayInfo = rayinfo
    raydata.Origin = Origin
    raydata.direaction = Direction
    local hitname = {}
    local debugfolder = rayinfo.Debug and Instance.new("Folder",workspace)
    if debugfolder then
        game:GetService("Debris"):AddItem(debugfolder,3)
    end
    repeat
        local x,y,z = currentposition.X,currentposition.Y,currentposition.Z
        if rayinfo.Debug then
            debugfolder.Name = "Debug"
            local clone = debugpart:Clone()
            clone.Parent = debugfolder
            clone.Position = Vector3.new(x,y,z)*3
        end
        local cx,cz = qf.GetChunkfromReal(x,y,z,true)
        if not rayinfo.IgnoreBlocks then
            local collided,block,blockposition = collisonH.AABBvsTerrain(Vector3.new(x,y,z),rayinfo.RaySize)
           -- local block,strcoord = Data.GetBlock(x,y,z)
            if collided and block and block ~= "Null"  then
                if not hitname[blockposition] and not rayinfo.BlackList[blockposition] then
                    local _,normal = nil
                    hitname[blockposition] = true
                    if rayinfo.GetNormal then
                         _,normal = collisonH.SweaptAABB(Vector3.new(x,y,z)-Direction.Unit*2,Vector3.new(unpack(blockposition:split(','))),Vector3.new(.01,.01,.01),Vector3.new(1,1,1),unit.Unit*5.2,1)
                         if type(normal) == "table" and normal.X then elseif rayinfo.BreakOnFirstHit then return raydata else continue end 
                    end
                    table.insert(raydata.Objects,{Type = "Block",BlockPosition = Vector3.new(unpack(blockposition:split(','))),Block = block,Normal = rayinfo.GetNormal and Vector3.new(normal.X,normal.Y,normal.Z) or Vector3.one,PointOfInt = Vector3.new(x,y,z)})
                    if rayinfo.BreakOnFirstHit then
                        return raydata
                    end
                end
            end
        end
        if not rayinfo.IgnoreEntities then
            local chunk = Data.GetChunk(cx,cz)
            if chunk then
                for i,v in chunk.Entities do
                    if hitname[i] or rayinfo.BlackList[i] or ( v:GetState('Dead') and  rayinfo.IgnoreDead)  then continue end 
                    if collisonH.AABBvsPoint(currentposition,v.Position,Vector3.new(v.HitBox.X,v.HitBox.Y,v.HitBox.X))  then
                        table.insert(raydata.Objects,{Type = "Entity",EntityId = i,EntityData = v,PointOfInt = Vector3.new(x,y,z)})
                        hitname[i] = true
                        if rayinfo.BreakOnFirstHit then
                            return raydata
                        end
                    end
                end
            end
        end
        currentposition += unit
        distancetraveled +=increaseby
    until distancetraveled>= distanceneeded
    return raydata
end
return ray 