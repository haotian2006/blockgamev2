local Chunk = {}
local qF = require(game.ReplicatedStorage.QuickFunctions)
local settings = require(game.ReplicatedStorage.GameSettings)
local chunksize = settings.ChunkSize
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
    ch.Entities = {}
    ch.Setttings = data and data.Setttings or {}
    ch.Blocks = data and data.Blocks or {}
    ch.ToLoad = data and data.ToLoad or {}
    ch.Chunk = Vector2.new(cx,cz)
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
function  Chunk:GetEdge(dir)
    local new = {}
    if dir == "x" then
        local x = 0
        for y = 0, chunksize.Y-1 do
            for z =0,chunksize.X-1 do
                local str= x..','..y..','..z
                new[str] = self.Blocks[str]
            end
        end
    elseif dir == "x-1" then
        local x = chunksize.X-1
        for y = 0, chunksize.Y-1 do
            for z =0,chunksize.X-1 do
                local str= x..','..y..','..z
                new[str] = self.Blocks[str]
            end
        end
    elseif dir == "z" then
        local z = 0
        for y = 0, chunksize.Y-1 do
            for x =0,chunksize.X-1 do
                local str= x..','..y..','..z
                new[str] = self.Blocks[str]
            end
        end
    else
        local z = chunksize.X-1
        for y = 0, chunksize.Y-1 do
            for x =0,chunksize.X-1 do
                local str= x..','..y..','..z
                new[str] = self.Blocks[str]
            end
        end
    end
    return new
end
function Chunk:GetNString():string
    return self.Chunk.X..","..self.Chunk.Y
end
function Chunk:GetNTuple():IntValue|IntValue
    return self.Chunk.X,self.Chunk.Y
end
function Chunk:SetData(which,data)
    self[which] = data
end
function Chunk:Destroy()
    setmetatable(self, nil) self = nil
end
if runservice:IsClient() then return Chunk end
local terrainh = require(game.ServerStorage.GenerationHandler)
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
    local stuff = multihandler.GenerateWorms(self.Chunk.X,self.Chunk.Y)
    local chunks = {}
    for i,v in stuff do
        for positon,data in v do
            local x,y,z = unpack(positon:split(','))
            local a,b = qF.GetChunkfromReal(x,y,z,true)
            local chunk = qF.combinetostring(a,b)
            chunks[chunk] = chunks[chunk] or {}
            local c = qF.cbt("grid","chgrid",x,y,z)
            x,y,z = c.X,c.Y,c.Z
            chunks[chunk][qF.combinetostring(x,y,z)] = data
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
function Chunk:IsGenerating()
    if self.Generating then
        repeat task.wait()until self.Generating == false
    end
    return self.Generating or self.Setttings.Generated
end
function Chunk:Generate()
    if self.Setttings.Generated then return end
    local generationhand = require(game.ServerStorage.GenerationHandler)
    self.Setttings.Generated = true
    self.Setttings.GeneratedCaves = self.Setttings.GeneratedCaves or false
    if self.Generating then
        repeat task.wait()until self.Generating == false
        return
    end
    self.Generating = true
    local t = multihandler.GetTerrain(self.Chunk.X,self.Chunk.Y,16)
   --local t = generationhand.GenerateTerrain(self.Chunk.X,self.Chunk.Y)
    self.Blocks = terrainh.Color(self.Chunk.X,self.Chunk.Y,t) 
    if not self.Setttings.GeneratedCaves  then
      self:DoCaves()
    end
  self:GenerateCavesNearBy()
   task.wait()
   self:LoadToLoad()
   self.Blocks = terrainh.CreateBedrock(self.Chunk.X,self.Chunk.Y,self.Blocks)
    self.Generating = false
end
return Chunk