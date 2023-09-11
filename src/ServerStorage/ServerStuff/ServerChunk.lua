local terrainh = require(game.ServerStorage.GenerationHandler)
local qF = require(game.ReplicatedStorage.QuickFunctions)
local settings = require(game.ReplicatedStorage.GameSettings)
local debris = require(game.ReplicatedStorage.Libarys.Debris)
local multihandler = require(game.ReplicatedStorage.MultiHandler)
local Chunk = require(game.ReplicatedStorage.Chunk)
local BlockSaver = require(game.ServerStorage.DataStores.BlockSaver)
local datahandler = require(game.ReplicatedStorage.DataHandler)
local gh = require(game.ServerStorage.GenerationHandler)
local multigh = require(game.ServerStorage.GenerationMultiHandler)
local PGC = debris.CreateFolder("PREGENERATEDCHUNKS")
local ServerStorage = game:GetService("ServerStorage")
local sharedregirsty = game:GetService("SharedTableRegistry")
local SharedT = sharedregirsty:GetSharedTable("SharedT")
local Signal = require(game.ReplicatedStorage.Libarys.Signal)
-- PGC.__remove = function(key)
--     SharedT[key] = nil
-- end
local sharedservice = require(ServerStorage.ServerStuff.SharedService)
function Chunk:LoadToLoad()
    for i,v in self.ToLoad do
        self:AddBlock(i,v)
        self.Changed = true
    end
    
end
function Chunk:AddToLoad(stuff,special)
    self.Changed = true
    if  self:StateIsDone("Terrian") and not special then
        for i,v in stuff do
            if tonumber(i) <=0 then continue end  
            self:AddBlock(i,v)
        end
    else
        for i,v in stuff do
            self.ToLoad[i] = v
        end
    end
end
local v2 = function(x,y)
    return `{x},{y}`
end

function Chunk:LerpValues()
    local data,surface = multigh:InterpolateDensity(self())
    self.Holes = data
    self.Surface = surface
end
function Chunk:LerpBiome()
    local cx,cz = self()
    local secondarybiomes = multigh:LerpBiomes(cx,cz,self.Surface)
    self.Biome = secondarybiomes
end
function Chunk:Color()
    local colors = multigh:Color( self.Holes,self.Surface,self.Biome)
    debug.profilebegin("BulkAdd")
    self.Holes = nil
    self:BulkAdd(colors)
    debug.profileend()
    debug.profilebegin("bedrock")
    for i,v in terrainh.CreateBedrock(self.Chunk.X,self.Chunk.Y,{}) do
        self:InsertBlock(i.X,i.Y,i.Z,v)
    end
    debug.profileend()
end
function Chunk:GenerateNoiseValues()
    if self.PreValues then return end 
    self.PreValues =  multigh:ComputeChunkS(self:GetNTuple())
    self.States = {}
    self.Biome =  self.PreValues[3]
    self.States.PreCompute = true
    return self.PreValues
end
function Chunk:GetUploadData()
    return tostring(self),self.PreValues
end

function Chunk.Create(x,y,ndata)
    local data = nil--BlockSaver.GetChunk(x,y)
    if data then
        data = multihandler.DeCompress({data})[1]
        local newdata = {Settings = {}}
        local settings = newdata.Settings
        local c,g,b,l,cl = table.unpack(data)
        settings.GeneratedOthers = (not c) and true 
        settings.Generated = (not g) and true
        settings.GeneratedStates = cl 
        newdata.ToLoad = l and l
        newdata.Blocks = b and Chunk.DeCompressVoxels(b)
        newdata.Changed = false
        return Chunk.new(x,y,newdata)
    else
       return Chunk.new(x,y,ndata)
    end
end
function Chunk:Compress()
    self.Saving = true
    self:WaitForGeneration()
    if not self.Changed then return   end 
    local settings = qF.deepCopy(self.Settings)
    local ToLoad = self.ToLoad or false
    local Blocks = #self:GetAllBlocks() >0 and self:CompressVoxels() or false
    local tosave = {
         (not settings.GeneratedOthers) and 1 or false,
         (not settings.Generated) and 1 or false,
         Blocks,
         ToLoad,
         not settings.Generated and settings.GeneratedStates
    }
    self.Changed = false
    self.Saving = false 
    if not next(tosave) then      return  end

    local data = multihandler.Compress({tosave})[1]
    if #data > 209715 then
        warn(tostring(self),'Is Over the max blocks limit of 209715:',#data,'And has a chance of not saving')
    end
    
    return data
end
return {} 