local Chunk = {}
Chunk.__index = Chunk
local qF = require(game.ReplicatedStorage.QuickFunctions)
local runservice = game:GetService("RunService")
--block example: Name|Cubic:Grass
function Chunk.new(cx,cz,data)
    if not cx or not cz then
        warn("Unable to create chunk")
        return nil
    end
    local ch = {}
    setmetatable(ch,Chunk)
    ch.RegionData = {}
    ch.Entitys = {}
    ch.Setttings = data and data.Setttings or {}
    ch.Blocks = data and data.Blocks or {}
    ch.Chunk = {cx,cz}
    return ch
end
function Chunk:GetBlock(x,y,z)--realpos
    return self.Blocks[qF.Realto1DBlock(x,y,z)]
end
function Chunk:GetBlocks()
    return self.Blocks
end
function Chunk:InsertBlock(data,x,y,z)
    local cc = qF.Realto1DBlock(x,y,z)
    self.Blocks[cc] = data
    return self.Blocks[cc]
end
function Chunk:GetNString():string
    return self.Chunk[1].."x"..self.Chunk[2]
end
function Chunk:GetNTuple():IntValue|IntValue
    return self.Chunk[1],self.Chunk[2]
end
function Chunk:Destroy()
    setmetatable(self, nil)
end
if runservice:IsClient() then return Chunk end
--server only functions
function Chunk:Generate()
    
end

return Chunk