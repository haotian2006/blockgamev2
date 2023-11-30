local Chunk = {}
local qF = require(game.ReplicatedStorage.QuickFunctions)
local settings = require(game.ReplicatedStorage.GameSettings)
local chunksize = settings.ChunkSize
local Players = game:GetService("Players")
local runservice = game:GetService("RunService")
local blockPool = require(game.ReplicatedStorage.core.BlockPool)
local IsServer =runservice:IsServer()
Chunk.EdgeIndexs ={
    x = {},["-x"] = {},z = {},["-z"] = {},init = false
}

Chunk.__index = Chunk
Chunk.__tostring = function(self)
    if not self.String then self.String = self.Chunk.X..","..self.Chunk.Y end 
    return self.String
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
    self.LVersion = 0 
    self.toLoad = data.toLoad or {{},{}}--overrid,non
    self.Loaded = IsServer and 0
    self.Changed = data and  (data.Changed ~= false and true or false)
    return self
end

local Vector3 = Vector3.new
function Chunk.newBluePrint(deafult)
    return  table.create(dsize,deafult or blockPool:get(false))
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
    local biome = self.Biome
    if typeof(biome) == "string" then
        return biome
    else 
        return biome[settings.to1DXZ(x,z)]
    end
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
    self:RemoveBlockIndex(self.to1D(x,y,z),false)
end
function Chunk:RemoveBlockIndex(id)
    local current =  self.Blocks[id]
    if not current or current[2] == false then return end 
    current:release()
    self.Blocks[id] = blockPool.CONST_FALSE
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
function  Chunk:AddBlock(index,data)
    index = tonumber(index)
    if index >maxsize or index <1 then 
        error("OUT OF BOUNDS") 
    end 
    local current = self.Blocks[index]
    if current[2] == data then return end 
    self.Blocks[index] = blockPool:get(data)
    current:release()  
    self.Changed = true
end
function Chunk:GetAllBlocks()
    return self.Blocks
end
function Chunk:InBounds(x,z,GetChunkCoord)
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
function Chunk:GetHighestBlock(x,z,higest,lowest,ignore)
    for y = higest or chunksize.Y-1,lowest or 0,-1 do
        local block = self.Blocks[settings.to1D(x,y,z)] 
        if  (not ignore and not block:isFalse()) or  (ignore and block[1][1] ~= ignore and not block:isFalse())  then
            return y,block
        end
    end
end
function Chunk:GetCorners2D()
    if self.Corners then return unpack(self.Corners) end 
    local min,max = self:ConvertLocalToGrid(0,0,0),self:ConvertLocalToGrid(settings.ChunkSize.X-1,0,settings.ChunkSize.X-1)
    self.Corners = {Vector2.new(min.X,min.Z),Vector2.new(max.X,max.Z)}
    return self.Corners
end
function Chunk:ConvertLocalToGrid(x,y,z)
    return Vector3(x,y,z) + Vector3(self.Chunk.X,0,self.Chunk.Y)*settings.ChunkSize.X
end

function Chunk:CompressVoxels(keytable)
    local blocks =  self.Blocks
    local newvector = Vector2int16.new
    local compressed = {}
    local key = {}
    local index = keytable or {}
    local secondarykey = {}
    for i,v in index do
        secondarykey[v] = i
    end
    local last = blocks[1]
    local count = 1
    local total = 0
    local size = 0
    local function get(id)
        local idx = secondarykey[id]
        if idx then return idx end
        local len = #index+1
        index[len] = id
        secondarykey[id] = len
        return len
    end
    for i =2, #blocks do
        local current = blocks[i]
        if current[2] == last[2] then
            count +=1
        else
            size+=1
            compressed[size] = newvector(get(last[2]),count)
            last = current 
            total+= count
            count = 1
            
        end
    end
    size+=1
    compressed[size] = newvector(get(last[2]),count)
    return {compressed,not keytable and index}
end
function Chunk:DeCompresAndInsert(comp,key)
    local decompressed = {}
    local current = 1
    for i,v in comp do
        local block
        for _ = 1,v.Y do
            if not block then
                block = blockPool:get(key[v.X])
            else
                block:increase()
            end
            self.Blocks[current] = block
            current +=1
        end
    end
    return decompressed
end
function Chunk.DeCompressVoxels(comp,key)
    local decompressed = {}
    local current = 1
    for i,v in comp do
        local value = key[v.X] 
        for _ = 1,v.Y do
            decompressed[current] = value
            current +=1
        end
    end
    return decompressed
end
function Chunk:GetNString():string 
   return tostring(self)
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
    setmetatable(self, nil) 
    local amtOfEach = {}
    for i,v in self.Blocks do
        amtOfEach[v[2]] = amtOfEach[v[2]] and  amtOfEach[v[2]]+1 or 1
    end
    for i,v in amtOfEach do
        blockPool:bulkRelease(i,v)
    end
    self.Destroyed = true
    self.Blocks = nil
end
return Chunk 