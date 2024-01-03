local Chunk = {}
Chunk.Width = 16
Chunk.Height = 256

local IndexConverter = require(game.ReplicatedStorage.Utils.IndexUtils)
local BlockPool = require(game.ReplicatedStorage.Block.BlockPool)
function Chunk.new(x,z,Block:buffer?,biomes:nil|buffer|number)
    local self = {
        X = x;
        Z =z;
    } 
    self.Entities = {} 
    self.Blocks = Block or buffer.create(8*8*256*4)
    self.BiomeMap = biomes
    self.Status = {
        Version = 0; 
    }
    self.Cache = {}
    return table.freeze(self)
end

function Chunk.getStatus(self,key)
    return self.Status[key]
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
    local idx = IndexConverter.to1DXZ[x][z]
    return if typeof(self.BiomeMap) =='buffer' then buffer.readu16(self.BiomeMap, (idx-1)*2) else self.BiomeMap
end

--// THESE ARE LOCAL POSITIONS
function Chunk.insertBlock(self,idx,block)
    buffer.writeu32(self.Blocks, (idx-1)*4, block)
end 
function Chunk.insertBlockAt(self,x,y,z,block)
    Chunk.insertBlock(self, IndexConverter.to1D[x][y][z], block)
end
function Chunk.getblock(self,idx)
   return buffer.readu32(self.Blocks, (idx-1)*4)
end
function Chunk.getBlockAt(self,x,y,z)
    return Chunk.getblock(self, IndexConverter.to1D[x][y][z])
end
return table.freeze(Chunk)