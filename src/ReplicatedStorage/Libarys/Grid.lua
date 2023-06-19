local grid = {}
grid.__index = grid
function grid.new(data,size)
    return setmetatable(table.create(size,false),grid) 
end
grid.__add = function(self,other)
    for i,v in other do
        self[tonumber(i)] = v
    end
end
local cmp = function(x,y,z)
    return y * (area1) + z * (area2) + x
end
grid.To1D = function(x,y,z)
    if typeof(x) == "Vector3" then return cmp(x.X,x.Y,x.Z) end
    return cmp(x,y,z)
 end
function grid:Insert(x,y,z,data)
    if not data[x] then data[x] ={y = {z = data}} return end
    if not data[x][y] then data[x][y] = {z = data} return end 
    
end
return grid