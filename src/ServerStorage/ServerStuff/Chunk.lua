local terrainh = require(game.ServerStorage.GenerationHandler)
local qF = require(game.ReplicatedStorage.QuickFunctions)
local settings = require(game.ReplicatedStorage.GameSettings)
local chunksize = settings.ChunkSize
local Players = game:GetService("Players")
local runservice = game:GetService("RunService")
local multihandler = require(game.ReplicatedStorage.MultiHandler)
local compresser = require(game.ReplicatedStorage.Libarys.compressor)
local Chunk = require(game.ReplicatedStorage.Chunk)
local BlockSaver = require(game.ServerStorage.DataStores.BlockSaver)
function Chunk:LoadToLoad()
    for i,v in self.ToLoad do
        self.Blocks[i] = v~=false and v or nil
        self.Changed = true
    end
    
end
function Chunk:DoCaves()
    if self.Saving  then
        repeat
            task.wait()
        until not self.Saving 
    end
    -- if tostring(self) == '-11,12' then
    --     print(self.GeneratingCaves)
    --     print( self.Setttings.GeneratedCaves)
    -- end
    if self.GeneratingCaves then
        repeat
            task.wait()
        until not self.GeneratingCaves
        return
    end
    if self.Setttings.GeneratedCaves then
        return
    end
    self.Changed = true
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
           local c= require(game.ReplicatedStorage.DataHandler).AddToLoad(cx,cz,v) --game.ReplicatedStorage.DataHandler.DoFunc:Invoke("AddToLoad",cx,cz,v)
        end
    end
    self.GeneratingCaves = false
end

function Chunk:GenerateCavesNearBy()
    if self.Saving  then
        repeat
            task.wait()
        until not self.Saving 
    end
    local cx,cz =self:GetNTuple()
    local stuff = qF.GetSurroundingChunk(cx,cz,3)
    local times =0
    for i,chunk in pairs(stuff) do
        local cx1,cz1 = unpack(chunk:split(','))
    --     if  tostring(self) == '-7,7' and chunk == '-11,12' then
    --         print("fired3213123123")
    --    end
        if cx1 == cx and cz1 == cz then continue end
        task.spawn(function()
            -- if  tostring(self) == '-7,7' and chunk == '-11,12' then
            --      print("fired")
            -- end
            local a = require(game.ReplicatedStorage.DataHandler).DoCaves(cx1,cz1,tostring(self))--game.ReplicatedStorage.DataHandler.DoFunc:Invoke("DoCaves",cx1,cz1,tostring(self))
            times+=1
            stuff[i] = nil
        --     if  tostring(self) == '-7,7' and chunk == '-11,12' then
        --         print("removed")
        --    end
        end)
    end
    repeat
        task.wait()
        -- if tostring(self) == '-7,7' then
        --     task.wait(2)
        --     print(stuff)
        -- end 
    until  not next(stuff)
end
function Chunk:IsGenerating()
    if self.Generating then
        repeat task.wait()until self.Generating == false
    end
    return self.Generating or self.Setttings.Generated
end
function Chunk:Generate()
    if self.Saving  then
        repeat
            task.wait()
        until not self.Saving 
    end
    if self.Setttings.Generated then return end
   -- local generationhand = require(game.ServerStorage.GenerationHandler)
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
  self:LoadToLoad()
--   if tostring(self) == '-7,7' then print("abcdef") end 
   task.wait()
   self.Blocks = terrainh.CreateBedrock(self.Chunk.X,self.Chunk.Y,self.Blocks)
    self.Generating = false
    self.Changed = true
end
--[[
{
    
}

]]
function Chunk.Create(x,y,ndata)
    local data = BlockSaver.GetChunk(x,y)
    if data then
        data = multihandler.DeCompress({data})[1]
        local newdata = {Setttings = {}}
        local settings = newdata.Setttings
        local c,g,b,l = data.c,data.g,data.b,data.l
        settings.GeneratedCaves = (not c) and true 
        settings.Generated = (not g) and true
        --if not settings.Generated then print(x,y) end 
        newdata.ToLoad = l 
        newdata.Blocks = b 
        newdata.Changed = false
        return Chunk.new(x,y,newdata)
    else
        return Chunk.new(x,y,ndata)
    end
end
function Chunk:Compress()
    self.Saving = true
    if not self.Changed then return   end 
    print(self)
    local settings = qF.deepCopy(self.Setttings)
    local ToLoad = self.ToLoad or {}
    local Blocks = self.Blocks or {}
    local tosave = {
        c = (not settings.GeneratedCaves) and 1 or nil,
        g = (not settings.Generated) and 1 or nil,
        b = Blocks,
        l = ToLoad
    }
    self.Changed = false
    -- local data = {}
    -- if next(Blocks) then table.insert(data,Blocks)  end
    -- if next(ToLoad) then table.insert(data,ToLoad) end
    -- data = multihandler.Compress(data)
    -- if next(Blocks) then
    --     tosave['b'] = data[1]
    --     tosave['l'] = data[2]
    -- elseif next(ToLoad) then
    --     tosave['l'] = data[1]
    -- end
    self.Saving = false 
    if not next(tosave) then      return  end

    local data = multihandler.Compress({tosave})[1]
    if #data > 209715 then
        warn(tostring(self),'Is Over the max blocks limit of 209715:',#data,'And has a chance of not saving')
    end
    
    return data

end
return {} 