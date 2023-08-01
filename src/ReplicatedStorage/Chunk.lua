local Chunk = {}
local qF = require(game.ReplicatedStorage.QuickFunctions)
local settings = require(game.ReplicatedStorage.GameSettings)
local chunksize = settings.ChunkSize
local Players = game:GetService("Players")
local runservice = game:GetService("RunService")
local bs = require(game.ReplicatedStorage.Libarys.Store)
Chunk.EdgeIndexs ={
    x = {},["-x"] = {},z = {},["-z"] = {}
}

Chunk.__index = Chunk
Chunk.__tostring = function(self)
    return self:GetNString()
end
Chunk.__call = function(self)
    return self:GetNTuple()
end
local farea = (chunksize.X)*(chunksize.Y)
Chunk.to1D = function(x,y,z,toString)
    if toString then
        return tostring(x + y * chunksize.X + z *farea+1)
    end
    return x + y * chunksize.X + z *farea+1
end
local ym = chunksize.Y-1
Chunk.to3D = function(index)
    index = tonumber(index) - 1
	local x = index % chunksize.X
	index = math.floor(index / chunksize.X)
	local y = index % chunksize.Y
	index = math.floor(index / chunksize.Y)
	local z = index % chunksize.X
	return x, y, z
end
local function round(x)
    return math.floor(x+.5)
end

function  Chunk.new(x,z,data)
    data = data or {}
    local self = setmetatable({},Chunk)
    self.Blocks = data.Blocks or table.create(chunksize.X^2*chunksize.Y,bs:get(false))
    self.Chunk =Vector2.new(x,z)
    self.Entities = data.Entities or {}
    self.Settings = data.Settings or {}
    self.RenderedBlocks = {}
    self.ToLoad = data.ToLoad or {}
    self.Changed = data and  (data.Changed ~= false and true or false)
    return self
end
function Chunk:AddToLoad(stuff)
    self.Changed = true
    if  self.Settings.Generated  then
        for i,v in stuff do
            if tonumber(i) <=0 then continue end  
            self:AddBlock(i,v)
        end
    else
        for i,v in stuff do
            self.ToLoad[i] = v
        end
    end
end
local Vector3 = Vector3.new

function Chunk:to3DBlocks()
    local new = {}
    for i,v in self.Blocks do
        local x,y,z = self.to3D(i)
        new[Vector3(x,y,z)] = v
    end
    return new
end
function  Chunk:GetBlock(x,y,z)
    local at = self.Blocks[self.to1D(x,y,z)]
    return  at and at 
end
function Chunk:GetBlockGrid(x,y,z)
    x,y,z = x%chunksize.X,y,z%chunksize.X
    return self:GetBlock(x,y,z)
end
function Chunk:RemoveBlockGrid(x,y,z)
    x,y,z = x%chunksize.X,y,z%chunksize.X
    return self:RemoveBlock(x,y,z)
end
function Chunk:RemoveBlock(x,y,z)
    self:InsertBlock(x,y,z,false)
    self.Changed = true
end
function Chunk:InsertBlock(x,y,z,data)
    self:AddBlock(self.to1D(x,y,z),data)
end
function Chunk:InsertBlockGrid(x,y,z,data)
    x,y,z = x%chunksize.X,y,z%chunksize.X
    return self:InsertBlock(x,y,z,data)
end
function  Chunk:AddBlock(index,data)
    if type(data)=="string" or type(data) == "boolean" then
        data = bs:get(data)
    end
    index = tonumber(index)
    if index >8192 or index <1 then 
        error("OUT OF BOUNDS") 
    end 
    self.Blocks[index] = data
    self.Changed = true
end
function Chunk:GetAllBlocks()
    return self.Blocks
end
function Chunk:InBounds(x,y,z,GetChunkCoord)
    local min,max = self:GetCorners2D()
    if (x >= min.X and x <= max.X and z >= min.Y and z <= max.Y) then
        return true,self.Chunk.X,self.Chunk.Y
    elseif GetChunkCoord then
        return false,math.floor((x+0.5)/settings.ChunkSize.X),
        math.floor((z+0.5)/settings.ChunkSize.X)
    end
    return false
end
function Chunk:GetEdge(dir)
    local toLoop = self.EdgeIndexs[dir]
    local newtable = {}
    for i,v in toLoop do
        if self.Blocks[v] then
            newtable[Vector3(self.to3D(v))] = self.Blocks[v]
        end
    end
    return newtable
end
function Chunk:GetCorners2D()
    local min,max = self:ConvertLocalToGrid(0,0,0),self:ConvertLocalToGrid(settings.ChunkSize.X-1,0,settings.ChunkSize.X-1)
    return Vector2.new(min.X,min.Z),Vector2.new(max.X,max.Z)
end
function Chunk:ConvertLocalToGrid(x,y,z)
    return Vector3(x,y,z) + Vector3(self.Chunk.X,0,self.Chunk.Y)*settings.ChunkSize.X
end
function Chunk:CompressVoxels()
    local blocks = self:GetAllBlocks()
    local compressed = {}
    local last = blocks[1]
    local count = 1
    local total = 0
    for i =2, #blocks do
        local current = blocks[i]
        if current == last then
            count +=1
        else
            table.insert(compressed,{last:getKey(),count})
            last = current 
            total+= count
            count = 1
            
        end
    end
    table.insert(compressed,{last:getKey(),count})
    return compressed
end
function Chunk.DeCompressVoxels(data)
    local decompressed = {}
    local current = 1
    for i,v in data do
        for _ = 1,v[2] do
            decompressed[tonumber(current)] = bs:get(v[1])
            current +=1
        end
    end
    return decompressed
end
function Chunk:GetNString():string
    return self.Chunk.X..","..self.Chunk.Y
end
function Chunk:GetNTuple():IntValue|IntValue
    return self.Chunk.X,self.Chunk.Y
end
function Chunk:SetData(which,data)
    self.Changed = true
    self[which] = data
end
do 
    for y = 0, chunksize.Y-1 do for z =0,chunksize.X-1 do
        table.insert(Chunk.EdgeIndexs.x,Chunk.to1D(0,y,z))
    end end
    for y = 0, chunksize.Y-1 do for z =0,chunksize.X-1 do
        table.insert(Chunk.EdgeIndexs["-x"],Chunk.to1D(chunksize.X-1,y,z))
    end end
    for y = 0, chunksize.Y-1 do for x =0,chunksize.X-1 do
        table.insert(Chunk.EdgeIndexs.z,Chunk.to1D(x,y,0))
    end end
    for y = 0, chunksize.Y-1 do for x =0,chunksize.X-1 do
        table.insert(Chunk.EdgeIndexs["-z"],Chunk.to1D(x,y,chunksize.X-1))
    end end
end
function Chunk:Destroy()
    setmetatable(self, nil) self = nil
end
return Chunk 