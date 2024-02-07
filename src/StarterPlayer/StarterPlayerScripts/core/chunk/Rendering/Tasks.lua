local Tasks = {}

local Cull = require(script.Parent.Helper.SimpleCull)
local Greedy = require(script.Parent.Helper.GreedyMesh)
local FloodFill = require(script.Parent.Helper.FloodFill)

function Tasks.ComputeFlood(section,TransparencyBuffer,StartTime)
    if os.clock()-StartTime >=0.013 then return false end 
    return FloodFill(TransparencyBuffer,section)
end 

function Tasks.ComputeCull(chunk,center,centerData,north,east,south,west,sections,StartTime )
    if os.clock()-StartTime >=0.013 then return false end 
    local CulledData = Cull.cull(chunk, center, centerData, north, east, south, west, sections)
    debug.profilebegin("GreedyMesh")
    local Meshed = Greedy.meshtable(CulledData)
    debug.profileend()
    return Meshed
end

return Tasks