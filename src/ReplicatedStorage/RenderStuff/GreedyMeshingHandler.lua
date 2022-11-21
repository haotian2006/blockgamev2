local meshing  = {}
meshing.__index = meshing
meshing.Blocks = {}
meshing.MeshedBlocks = {}
--[[
    - C










]]
function meshing.newmesh()
    local self = setmetatable({},meshing)
    
    return self
end
function meshing:Combine(Mesh)
    
end
return meshing