local LChunk = {}
local qF = require(game.ReplicatedStorage.QuickFunctions)
local Players = game:GetService("Players")
local runservice = game:GetService("RunService")
local multihandler = require(game.ReplicatedStorage.MultiHandler)
LChunk.__index = LChunk
function LChunk.new(cx,cz,data)
    if not cx or not cz then
        warn("Unable to create chunk")
        return nil
    end
    local ch = {}
    setmetatable(ch,LChunk)
    ch.RegionData = {}
    ch.Entitys = {}
    ch.Settings = data and data.Settings or {}
    ch.Blocks = data and data.Blocks or {}
    ch.Chunk = {cx,cz}
    ch.Generating = false
    return ch
end
function LChunk:GetBlock(x,y,z)--realpos
    return self.Blocks[qF.Realto1DBlock(x,y,z)]
end
function LChunk:GetBlocks()
    return self.Blocks
end
function LChunk:InsertBlock(data,x,y,z)
    local cc = qF.Realto1DBlock(x,y,z)
    self.Blocks[cc] = data
    return self.Blocks[cc]
end
function LChunk:GetNString():string
    return self.Chunk.X.."x"..self.Chunk.Y
end
function LChunk:GetNTuple():IntValue|IntValue
    return self.Chunk.X,self.Chunk.Y
end
function LChunk:SetData(which,data)
    self[which] = data
end
function LChunk:Destroy()
    setmetatable(self, nil)
end
function LChunk:Generate()
    if self.Generating then
        repeat task.wait()until self.Generating == false
        return
    end
    self.Generating = true
    self.Blocks = multihandler.GetTerrain(self.Chunk.X,self.Chunk.Y,20)
    self.Generating = false
end

return LChunk