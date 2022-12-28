local ray = {}
local Data = require(game.ReplicatedStorage.DataHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local collisonH = require(game.ReplicatedStorage.CollisonHandler)
function ray.newInfo()
    return {
        BreakOnFirstHit = false,
        IgnoreEntities = false,
        IgnoreBlocks = false,
        BlackList = {},
    }
end
function ray.Cast(Origin: Vector3, Direction: Vector3,rayinfo)  
    rayinfo = rayinfo or ray.newInfo()
    local newlist = {}
    for i,v in rayinfo.BlackList do
        newlist[v] = true
    end
    rayinfo.BlackList = newlist
    if rayinfo.IgnoreBlocks and rayinfo.IgnoreEntities then error("Why Cast a ray and waste resources bruv") end 
    if typeof(Origin) ~= "Vector3" or typeof(Direction) ~= "Vector3" then error("Wrong Arguments sent") end
    local increaseby =  .1 
    local unit = Direction.Unit*increaseby
    local currentposition = Origin
    local distanceneeded = (Direction).Magnitude
    local distancetraveled = 0
    local hittargets = {}
    local hitname = {}
    if not rayinfo.IgnoreBlocks  then
        
    end
    repeat
        local x,y,z = currentposition.X,currentposition.Y,currentposition.Z
        local cx,cz = qf.GetChunkfromReal(x,y,z,true)
        if not rayinfo.IgnoreBlocks  then
            local block,strcoord = Data.GetBlock(x,y,z)
            if block ~= "Null" and block then
                local bx,by,bz = unpack(strcoord:split(","))
                local a = qf.cbt("chgrid",'grid',cx,cz,bx,by,bz)
                bx,by,bz = a.X,a.Y,a.Z
                if not hitname[bx..','..by..','..bz] and not rayinfo.BlackList[bx..','..by..','..bz] then
                    table.insert(hittargets,bx..','..by..','..bz)
                    hitname[bx..','..by..','..bz] = true
                    if rayinfo.BreakOnFirstHit then
                        return hittargets
                    end
                end
            end
        end
        if not rayinfo.IgnoreEntities then
            local chunk = Data.GetChunk(cx,cz)
            if chunk then
                for i,v in chunk.Entities do
                    if hitname[i] or rayinfo.BlackList[i] then continue end 
                    if collisonH.AABBvsPoint(currentposition,v.Position,Vector3.new(v.HitBox.X,v.HitBox.Y,v.HitBox.X)) then
                        table.insert(hittargets,i)
                        hitname[i] = true
                        if rayinfo.BreakOnFirstHit then
                            return hittargets
                        end
                    end
                end
            end
        end
        currentposition += unit
        distancetraveled +=increaseby
    until distancetraveled>= distanceneeded
    return hittargets
end
return ray 