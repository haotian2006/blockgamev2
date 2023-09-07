local Chunk = {}
local qF = require(game.ReplicatedStorage.QuickFunctions)
local settings = require(game.ReplicatedStorage.GameSettings)
local chunksize = settings.ChunkSize
local Players = game:GetService("Players")
local runservice = game:GetService("RunService")
local bs = require(game.ReplicatedStorage.Libarys.Store)
Chunk.EdgeIndexs ={
    x = {},["-x"] = {},z = {},["-z"] = {},init = false
}

Chunk.__index = Chunk
Chunk.__tostring = function(self)
    return self:GetNString()
end
Chunk.__call = function(self)
    return self:GetNTuple()
end
local farea = (chunksize.X)*(chunksize.Y)
Chunk.to1D = settings.to1D
local ym = chunksize.Y-1
Chunk.to3D = settings.to3D
local function round(x)
    return math.floor(x+.5)
end
local dsize = chunksize.X^2*chunksize.Y
function  Chunk.new(x,z,data)
    data = data or {}
    local self = setmetatable({},Chunk)
    self.Blocks = data.Blocks or self.newBluePrint()
    self.Chunk =Vector2.new(x,z)
    self.Entities = data.Entities or {}
    self.Settings = data.Settings or {}
    self.RenderedBlocks = {}
    self.ToLoad = data.ToLoad or {}
    self.Changed = data and  (data.Changed ~= false and true or false)
    return self
end
local Vector3 = Vector3.new
function Chunk.newBluePrint(deafult)
    return  table.create(dsize,deafult or bs:get(false))
end
local function specialidk(data,refrence)
    local key = data:getKey()
    if not key or  refrence.data[key] then return key end 
    local info = table.clone(data:getData())
    local rsdata = info.Data
    info.Data = nil
    refrence.data[key] = info
    if not refrence.rsdata[info.T] then
    refrence.rsdata[info.T] = rsdata
    end
    return key
end
function Chunk:to3DBlocks(special,refrence)
    local new = self.newBluePrint(if special then false else nil)
    local refrence =  refrence or (special and {data = {},rsdata= {}})
    for i,v in self.Blocks do
        local data = v
        if special then
            data = specialidk(data,refrence)   
        end
        new[i] = data
    end
    return new,refrence
end
local xsizel = settings.ChunkSize.X/4
local ysizel = settings.ChunkSize.Y/8
local farea = xsizel*ysizel
local function to1dLocal4x4(x,y,z)
    return x + y * xsizel + z *farea+1
end
function Chunk:GetBiomeAt(x,y,z)
    x = math.floor(x/4)
    y = math.floor(y/8)
    z = math.floor(x/4)
    return type(self.Biome) == "string" and self.Biome or  self.Biome[to1dLocal4x4(x,y,z)]
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
local maxsize = chunksize.X^2*chunksize.Y
function Chunk:BulkAdd(table)
    local found = {}
    for i,v in table do
        if not found[v] then
            local x = bs:get(v)
            found[v] = x--v
        end
       self.Blocks[i] = found[v]
    end
    self.Changed = true
end
function  Chunk:AddBlock(index,data)
    if type(data)=="string" or type(data) == "boolean" then
        data = bs:get(data)
    end
    index = tonumber(index)
    if index >maxsize or index <1 then 
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
function Chunk:GetEdge(dir,refrence)
    local toLoop = self.GetEdgeIndexs(dir)
    local newtable = self.newBluePrint(if refrence then false else nil)
    for v,idx in toLoop do
        if self.Blocks[v] then
            local data = self.Blocks[idx]
            if refrence then
                data = specialidk(data,refrence)   
            end
            newtable[idx] = data
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

function Chunk:CompressVoxels(keytable)
    local blocks =  self:GetAllBlocks() 
    local compressed = {}
    local key = {}
    local index = keytable or {}
    local last = blocks[1]
    local count = 1
    local total = 0
    local function get(id)
        local idx = table.find(index,id)
        if idx then return idx end
        local len = #index+1
        index[len] = id
        return len
    end
    for i =2, #blocks do
        local current = blocks[i]
        if current == last then
            count +=1
        else
            table.insert(compressed,Vector2int16.new(get(last:getKey()),count))
         --   table.insert(key,count)
            last = current 
            total+= count
            count = 1
            
        end
    end
    table.insert(compressed,Vector2int16.new(get(last:getKey()),count))
 --   table.insert(key,count)
    return {compressed,not keytable and index}
end
function Chunk.DeCompressVoxels(comp,key)
    local decompressed = {}
    local current = 1
    for i,v in comp do
        for _ = 1,v.Y do
            decompressed[tonumber(current)] =  bs:get(key[v.X])
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
function  Chunk.GetEdgeIndexs(edge)
    if  Chunk.EdgeIndexs.init then
        return Chunk.EdgeIndexs[edge]
    end
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
    Chunk.EdgeIndexs.init = true
    return Chunk.EdgeIndexs[edge]
end
 
function Chunk:Destroy()
    setmetatable(self, nil) self = nil
end
return Chunk 