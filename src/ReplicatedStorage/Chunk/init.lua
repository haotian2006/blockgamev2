local Chunk = {}
Chunk.Width = 16
Chunk.Height = 256

local IndexConverter = require(game.ReplicatedStorage.Utils.IndexUtils)
IndexConverter.preCompute2D()
local ResourchHandler = require(game.ReplicatedStorage.ResourceHandler)
local IS_CLIENT = game:GetService("RunService"):IsClient()
local to1d = IndexConverter.to1D
local to1dXZ = IndexConverter.to1DXZ


function Chunk.new(x,z,Block:buffer?,biomes:nil|buffer|number,transparencyData)
    local self = {
        X = x;
        Z =z;
    } 
    self.Entities = {} 
    self.Blocks = Block or buffer.create(8*8*256*4)
    self.BiomeMap = biomes
    self.TransparencyBuffer = transparencyData
    self.Status = {
        Simulated = false,
        Version = 0; 
    }
    self.Data = {
         
    }
    if IS_CLIENT then
        self.SubChunks = {}
        self.CurrentlyLoaded = buffer.create(32)
    end
    self.Changes = {}
    self.Cache = {}
    return table.freeze(self)
end

function Chunk.getStatus(self,key)
    return self.Status[key]
end

function Chunk.isSimulated(self)
    return self.Status.Simulated
end

function Chunk.setStatus(self,key,value)
    self.Status[key] = value
end

function Chunk.addEntity(self,Entity)
    self.Entities[Entity.Guid] =  Entity
end
function Chunk.removeEntity(self,Entity) 
    self.Entities[Entity.Guid] = nil
end
function Chunk.getEntity(self,Entity)
    return self.Entities[Entity.Guid] 
end 
function Chunk.getBiome(self,idx) 
    return if typeof(self.BiomeMap) =='buffer' then buffer.readu16(self.BiomeMap, (idx-1)*2) else self.BiomeMap
end

function Chunk.getBiomeAt(self,x,z)
    local idx = to1dXZ[x//1][z//1]
    return if typeof(self.BiomeMap) =='buffer' then buffer.readu16(self.BiomeMap, (idx-1)*2) else self.BiomeMap
end

--// THESE ARE LOCAL POSITIONS
function Chunk.insertBlock(self,idx,block)
    self.Changes[idx] = block
    buffer.writeu32(self.Blocks, (idx-1)*4, block)
end 

if IS_CLIENT then
    local function getTransparency(block)
        return if block == 0 then 1 else 0
    end
    local function UpdateTransparency(self,idx,block)
        local tBuffer = self.TransparencyBuffer
        buffer.writeu8(tBuffer, idx-1, getTransparency(block))
    end
    function Chunk.insertBlock(self,idx,block)
        self.Changes[idx] = block
        buffer.writeu32(self.Blocks, (idx-1)*4, block)
        UpdateTransparency(self,idx,block)
    end 
end
local insertBlock =  Chunk.insertBlock

function Chunk.insertBlockAt(self,x,y,z,block)
    insertBlock(self, to1d[x//1][y//1][z//1], block)
end

function Chunk.getBlock(self,idx)
   return buffer.readu32(self.Blocks, (idx-1)*4)
end
local getBlock = Chunk.getBlock
function Chunk.getBlockAt(self,x,y,z)
    return getBlock(self, to1d[x//1][y//1][z//1])
end
return table.freeze(Chunk)