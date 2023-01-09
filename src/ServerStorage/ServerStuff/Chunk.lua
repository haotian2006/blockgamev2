local terrainh = require(game.ServerStorage.GenerationHandler)
local qF = require(game.ReplicatedStorage.QuickFunctions)
local settings = require(game.ReplicatedStorage.GameSettings)
local chunksize = settings.ChunkSize
local Players = game:GetService("Players")
local runservice = game:GetService("RunService")
local multihandler = require(game.ReplicatedStorage.MultiHandler)
local Chunk = require(game.ReplicatedStorage.Chunk)
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
return {}