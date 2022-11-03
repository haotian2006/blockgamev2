local Chunk = {}
local qF = require(game.ReplicatedStorage.QuickFunctions)
local Players = game:GetService("Players")
local runservice = game:GetService("RunService")
local multihandler = require(game.ReplicatedStorage.MultiHandler)
Chunk.__index = Chunk
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
    ch.ToLoad = data and data.ToLoad or {}
    ch.Chunk = {cx,cz}
    ch.Generating = false
    return ch
end
function Chunk:AddToLoad(stuff)
    for i,v in stuff do
        self.ToLoad[i] = v
    end
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
function Chunk:SetData(which,data)
    self[which] = data
end
function Chunk:Destroy()
    setmetatable(self, nil)
end
if runservice:IsClient() then return Chunk end
--server only functions
function Chunk:DoCaves()
    
end
function Chunk:Generate()
    if self.Setttings.Generated then return end
    if self.Generating then
        repeat task.wait()until self.Generating == false
        return
    end
    self.Generating = true
    self.Blocks = multihandler.GetTerrain(self.Chunk[1],self.Chunk[2],20)
    if self.Setttings.GeneratedCaves == false then
        
    end
    self.Setttings.GeneratedCaves = true
    self.Generating = false
    self.Setttings.Generated = true
end

return Chunk