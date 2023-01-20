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
        Debug = false,
    }
end
function ray.CalculateNormal(dir)
    
end
function ray.Cast(Origin: Vector3, Direction: Vector3,rayinfo)  
    rayinfo = rayinfo or ray.newInfo()
    local newlist = {}
    for i,v in rayinfo.BlackList do
        newlist[v] = true
    end
    rayinfo.BlackList = newlist
    if typeof(Origin) ~= "Vector3" or typeof(Direction) ~= "Vector3" then error("Wrong Arguments sent") end
    local increaseby =  .1
    local unit = Direction.Unit*increaseby
    local currentposition = Origin
    local distanceneeded = (Direction).Magnitude
    local distancetraveled = 0
    local hittargets = {}
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
            local collided,block,blockposition = collisonH.AABBvsTerrain(Vector3.new(x,y,z),Vector3.new(.1,.1,.1))
           -- local block,strcoord = Data.GetBlock(x,y,z)
            if collided and block and block ~= "Null"  then
                if not hitname[blockposition] and not rayinfo.BlackList[blockposition] then
                    table.insert(hittargets,blockposition)
                    hitname[blockposition] = true
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
                        table.insert(hittargets,{i,"Entity"})
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