local Chunk = {}
Chunk.Width = 16
Chunk.Height = 256

local IndexConverter = require(game.ReplicatedStorage.Utils.IndexUtils)
local BlockPool = require(game.ReplicatedStorage.Block.BlockPool)
function Chunk.new(x,z,data:{any:any}?)
    local self = {
        X = x;
        Z =z;
    } 
    self.Entities = {} 
    self.Blocks = data or table.create(Chunk.Width^2 *Chunk.Height,false)
    self.BiomeMap = {} 
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

--// THESE ARE LOCAL POSITIONS
function Chunk.insertBlock(self,idx,block)
    self.Blocks[idx] = block
end 
function Chunk.insertBlockAt(self,x,y,z,block)
    self.Blocks[IndexConverter.to1D[x][y][z]] = block
end
function Chunk.getblock(self,idx)
    return self.Blocks[idx]
end
function Chunk.getBlockAt(self,x,y,z)
    return self.Blocks[IndexConverter.to1D[x][y][z]] 
end
return table.freeze(Chunk)