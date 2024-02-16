local Tasks = {}

local Cull = require(script.Parent.Helper.SimpleCull)
local Greedy = require(script.Parent.Helper.GreedyMesh)
local FloodFill = require(script.Parent.Helper.FloodFill)

local Config = require(script.Parent.Config)

local time = Config.ANTI_LAG_TIME
local AntiLag = Config.ANTI_LAG

function Tasks.ComputeFlood(section,TransparencyBuffer,StartTime)
    if os.clock()-StartTime >=0.013 and AntiLag then return false end 
    return FloodFill(TransparencyBuffer,section)
end 

function Tasks.ComputeFloodLarge(sections,TransparencyBuffer,StartTime)
    if os.clock()-StartTime >=0.016 and AntiLag then return false end 
    debug.profilebegin("LARGESECTION")
    local offset = sections*8
    local Data = {}
    for i = 0,7 do
        local section = offset+i
        Data[i+1] = FloodFill(TransparencyBuffer,section)
    end
    debug.profileend()
    return Data
end 


function Tasks.ComputeCull(chunk,center,centerData,north,east,south,west,sections,StartTime )
    if os.clock()-StartTime >=0.013 and AntiLag then return false end 
    local CulledData = Cull.cull(chunk, center, centerData, north, east, south, west, sections)
    debug.profilebegin("GreedyMesh")
    local Meshed = Greedy.meshtable(CulledData)
    debug.profileend()
    return Meshed
end

return Tasks