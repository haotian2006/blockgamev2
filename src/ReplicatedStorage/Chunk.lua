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
game.Players.PlayerAdded:Connect(function(x)
    
end)
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
    return self.Chunk[1]..","..self.Chunk[2]
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
function Chunk:LoadToLoad()
    for i,v in self.ToLoad do
        self.Blocks[i] = v~=false and v or nil
    end
end
function Chunk:DoCaves()
    if self.GeneratingCaves then
        repeat
            task.wait()
        until not self.GeneratingCaves
        return
    end
    if self.Setttings.GeneratedCaves then
        return
    end
    self.GeneratingCaves = true
    self.Setttings.GeneratedCaves = true
    local stuff = multihandler.GenerateWorms(self.Chunk[1],self.Chunk[2])
    local chunks = {}
    for i,v in stuff do
        for positon,data in v do
            local x,y,z = qF.cv3type("tuple",positon)
            local chunk = qF.cv2type("string",qF.GetChunkfromReal(x,y,z,true))
            chunks[chunk] = chunks[chunk] or {}
            chunks[chunk][qF.cv3type('string',qF.cbt("grid","chgrid",x,y,z))] = data
        end    
    end
    for i,v in chunks do
        if i  == self:GetNString() then
            self:AddToLoad(v)
        else
            local cx,cz = qF.cv2type("tuple",i)
           local c= game.ReplicatedStorage.DataHandler.DoFunc:Invoke("AddToLoad",cx,cz,v)
        end
    end
    self.GeneratingCaves = false
end
function Chunk:GenerateCavesNearBy()
    local cx,cz =self:GetNTuple()
    local stuff = qF.GetSurroundingChunk(cx,cz,5)
    local times =0
    for i,chunk in stuff do
        local cx1,cz1 = qF.cv2type("tuple",chunk)
        if cx1 == cx and cz1 == cz then continue end
        task.spawn(function()
            local a = game.ReplicatedStorage.DataHandler.DoFunc:Invoke("DoCaves",cx1,cz1)
            times+=1
        end)
    end
    repeat
        task.wait()
    until times == #stuff-1
end
function Chunk:Generate()
    if self.Setttings.Generated then return end
    self.Setttings.Generated = true
    self.Setttings.GeneratedCaves = self.Setttings.GeneratedCaves or false
    if self.Generating then
        repeat task.wait()until self.Generating == false
        return
    end
    self.Generating = true
    self.Blocks = multihandler.GetTerrain(self.Chunk[1],self.Chunk[2],92)
    if not self.Setttings.GeneratedCaves  then
       self:DoCaves()
    end
   self:GenerateCavesNearBy()
   task.wait()
   self:LoadToLoad()
    self.Generating = false
end

return Chunk