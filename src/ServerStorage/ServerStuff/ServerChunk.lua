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
local Signal = require(game.ReplicatedStorage.Libarys.Signal)
local blockPool = require(game.ReplicatedStorage.Libarys.BlockPool)
local bh = require(game.ReplicatedStorage.BehaviorHandler)
-- PGC.__remove = function(key)
--     SharedT[key] = nil
-- end
local sharedservice = require(ServerStorage.ServerStuff.SharedService)
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
function Chunk:BulkAdd(table)
    local found = {}
    local modified = {}
    for i,v in table do
        if v == false then continue end 
        if not found[v] then
            local x = blockPool:get(v)
            found[v] = x--v
            modified[v] = -1
        end
       self.Blocks[i] = found[v]
       modified[v] +=1
    end
    for i,v in  modified  do
        if not i then continue end 
        blockPool:doesExsist(i)[3] += v
    end
    self.Changed = true
end
local v2 = function(x,y)
    return `{x},{y}`
end

function Chunk:LerpValues()
    local alldata = multigh:InterpolateDensity(self())
    -- self.Holes = data
    -- self.Surface = surface
    self.alldata = alldata
end
function Chunk:LerpBiome()
    local cx,cz = self()
    local secondarybiomes = multigh:LerpBiomes(cx,cz)
    self.Biome = secondarybiomes
end 
function Chunk:ComputeFeatureNoises()
    local cx,cz = self()
    self.Fnoise = multigh:ComputeFeaturesNoise(cx,cz,self.Biome)
end
local function createidk(data,cx,cz)
    local model = Instance.new("Model")
    for x = 0,7 do
        model.Name = "123"
        for y = 0, 7 do
            local noiseValue = data[settings.to1DXZ(x,y)]
            local colorValue = noiseValue
            local color = Color3.new(colorValue, colorValue, colorValue)

            -- if noiseValue*multi >=min and noiseValue*multi <= max then
            --     color = Color3.new(0, 1, 0)
            -- end
            local part = Instance.new("Part")
            part.Reflectance = 0
            part.Size = Vector3.new(1, 1, 1)
            part.Position = Vector3.new(x + cx*8, noiseValue*30, y +cz*8) * 1
            part.Anchored = true
            part.BrickColor = BrickColor.White()
            part.Reflectance = 0
            part.Material = Enum.Material.SmoothPlastic
            part.Color = color
            part.Parent = model
        end
        task.wait()
    end
    model.Parent = workspace
end
function Chunk:LerpFeatureNoise()
    self.Fnoise = multigh:LerpFeatureNoise(self.Fnoise)
end
game.Workspace.Baseplate:Destroy()
local r = 1
local rqamt = 0
do
    for ofx_ = -r,r do
        for ofz_ = -r,r do
            rqamt+=1
        end
    end
end
local once = false
function Chunk:loadToLoad()
   -- if tostring(self) == "-40,-6" then print(self.toLoad)  end 
   debug.profilebegin("load to load")
    local pool = {}
    local blocks = {}
    for i,v in self.toLoad[1] do
        local current = self.Blocks[i]
        pool[current] = pool[current] or 0
        pool[current] -=1
        if not blocks[v] then blocks[v] = blockPool:getOrCreate(v) end
        local newB = blocks[v] 
        pool[newB] = pool[newB] or 0
        pool[newB] +=1
        self.Blocks[i] = newB
    end
    for i,v in self.toLoad[2] do
        if not self.Blocks[i]:isFalse() then continue end 
        if not blocks[v] then blocks[v] = blockPool:getOrCreate(v) end
        local newB = blocks[v] 
        pool[newB] = pool[newB] or 0
        pool[newB] +=1
        self.Blocks[i] = newB
    end
    for i,v in pool do
        i:bulkAdd(v)
    end
    debug.profileend()
    self.Changed = true
end
function Chunk:canLoadToLoad()
 return self.Loaded >=rqamt
end
local onsce = false
function Chunk:InsertFeatures()
    local once = false
    local biome,bd 
    debug.profilebegin("Insert Features")
    local cx,cz = self:GetNTuple()
    local xoff,yoff = settings.getoffset(cx,cz)
    for x = 0,7 do
        local rx = xoff +x
        for z = 0,7 do
            local rz = yoff +z
            local idx = settings.to1DXZ(x,z)
            local biomea = type(self.Biome) == "string" and self.Biome or self.Biome[idx]
            if biome ~= biomea then
                biome = biomea
                bd = bh.GetBiome(biomea)
            end
            if not bd.Features then continue end 
            for _,data in bd.Features do
                -- if not once then
                --     createidk(self.Fnoise[data.noiseSettings],self())
                --     once = true
                -- end
                local noise = self.Fnoise[data.noiseSettings][idx]
                local Range = data.noise_Range or {}
                local flag = false 
                for i,v in Range do
                    local value = noise * (v.multiplier or 1)
                    if v.min <= value and v.max >= value then
                        flag = true 
                        break
                    end
                end
                if flag then
                    local y,block= self:GetHighestBlock(x,z)
                    if block:getName() == "c:Water" then continue end 
                    for i,v in data.structure.layout do
                        if data.isFoilage then
                            local toLoad =  if(data.override ==false) then self.toLoad[2] else self.toLoad[1]
                           toLoad[settings.to1D(x,y+v[2],z)] = data.structure.key[v[4]]
                        else
                           -- self:InsertBlockGrid(rx+v[1],y+v[2],rz+v[3],data.structure.key[v[4]])
                            local ccx,ccz,lx,ly,lz  =qF.GetChunkAndLocal(rx+v[1],y+v[2],rz+v[3])
                            if ccx == cx and ccz == cz then
                                local toLoad =  if(data.override ==false) then self.toLoad[2] else self.toLoad[1]
                               toLoad[settings.to1D(lx,ly,lz)] = data.structure.key[v[4]]
                            else
                                local chunk = datahandler.GetChunk(ccx,ccz,true)
                                local toLoad =  if(data.override ==false) then chunk.toLoad[2] else chunk.toLoad[1]
                              toLoad[settings.to1D(lx,ly,lz)] = data.structure.key[v[4]]
                            end
                        end
                    end
                end
            end
        end
    end
    for ofx_ = -r,r do
        for ofz_ = -r,r do
           -- if ofx_ == ofz_ and ofx_ == 0 then continue end 
          --  local str = `{cx+ ofx_},{cz+ofz_}`
            local chunk = datahandler.GetChunk(cx+ ofx_,cz+ofz_,true)
            chunk.Loaded +=1
        end
    end
    debug.profileend()
    self.Fnoise = nil
end
function Chunk:Color() 
    debug.profilebegin("Before Color")
    debug.profileend()
    local colors = multigh:Color( self.alldata,self.Biome)
    debug.profilebegin("BulkAdd")
    self.alldata = nil
    self:BulkAdd(colors)
    debug.profileend()
    debug.profilebegin("bedrock")
    for i,v in terrainh.CreateBedrock(self.Chunk.X,self.Chunk.Y,{}) do
        self:InsertBlock(i.X,i.Y,i.Z,v)
    end
    debug.profileend()
end
function Chunk:GenerateNoiseValues()
    if  self.preGen then return false end 
    if self.PreValues then return self.PreValues end 
    self.preGen = true
    self.PreValues =  multigh:ComputeChunkS(self:GetNTuple())
    self.preGen  = nil
    self.Biome =  self.Biome or self.PreValues[3]
    return self.PreValues
end
function Chunk:GetUploadData()
    return tostring(self),self.PreValues
end
function Chunk:Finish()
    self.generated = true
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
        newdata.toLoad = l and l
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