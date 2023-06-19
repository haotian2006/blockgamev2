local Chunk = {}
local qF = require(game.ReplicatedStorage.QuickFunctions)
local settings = require(game.ReplicatedStorage.GameSettings)
local chunksize = settings.ChunkSize
local Players = game:GetService("Players")
local runservice = game:GetService("RunService")
local multihandler = require(game.ReplicatedStorage.MultiHandler)
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
Chunk.to1D = function(x,y,z)
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
    self.Blocks = data.Blocks or table.create(chunksize.X^2*chunksize.Y,false)
    self.Chunk =Vector2.new(x,z)
    self.Entities = data.Entities or {}
    self.Setttings = data.Setttings or {}
    self.RenderedBlocks = {}
    self.ToLoad = data.ToLoad or {}
    self.Changed = data and  (data.Changed ~= false and true or false)
    return self
end
function Chunk:AddToLoad(stuff)
    self.Changed = true
    if  self.Setttings.Generated  then
        for i,v in stuff do
            local t = i:split(',')
            if tonumber(t[2]) <=0 then continue end  
            self.Blocks[self.to1D(unpack(t))] = v
        end
    else
        for i,v in stuff do
            self.ToLoad[i] = v
        end
    end
end
function Chunk.tableTo3D(Blocks)
    local new = {}
    for i,v in Blocks do
        local x,y,z = Chunk.to3D(i)
        new[x..','..y..','..z] = v
    end
    return new
end
function Chunk.tableTo3DV(Blocks)
    local new = {}
    for i,v in Blocks do
        local x,y,z = Chunk.to3D(i)
        new[Vector3.new(x,y,z)] = v
    end
    return new
end
function Chunk:to3DBlocks()
    local new = {}
    for i,v in self.Blocks do
        local x,y,z = self.to3D(i)
        new[Vector3.new(x,y,z)] = v
    end
    return new
end
function  Chunk:GetBlock(x,y,z)
    local at = self.Blocks[self.to1D(x,y,z)]
    return  at and at 
end
function Chunk:RemoveBlock(x,y,z)
    self:InsertBlock(x,y,z,false)
    self.Changed = true
end
function Chunk:InsertBlock(x,y,z,data)
    self.Blocks[self.to1D(x,y,z)] = data
    self.Changed = true
end
function Chunk:GetAllBlocks()
    return self.Blocks
end
function Chunk:GetEdge(dir)
    local toLoop = self.EdgeIndexs[dir]
    local newtable = {}
    for i,v in toLoop do
        if self.Blocks[v] then
            newtable[Vector3.new(self.to3D(v))] = self.Blocks[v]
        end
    end
    return newtable
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
            table.insert(compressed,{last,count})
            last = current
            total+= count
            count = 1
            
        end
    end
    table.insert(compressed,{last,count})
    return compressed
end
function Chunk.DeCompressVoxels(data)
    local decompressed = {}
    local current = 1
    for i,v in data do
        for _ = 1,v[2] do
            decompressed[current] = v[1]
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