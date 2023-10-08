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
local sharedservice = require(ServerStorage.ServerStuff.SharedService):Listen()
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
local function smoothSurface(cx,cy)
    local loc  = {v2(cx,cy),v2(cx+1,cy),v2(cx,cy+1),v2(cx+1,cy+1)
    }
    local thread =coroutine.running()
    local finished = 0
    local climate 
    local s 
    for i,v in loc do
       task.spawn(function()
        local data = PGC:GetItemData(v)
        if data then
            if data.Loading then
                data.Event:Wait()
            end
        else
            data = {Loading = true}
            data.Event = Signal.new()
            PGC:AddItem(v,data,5)
            local x,y = v:split(',')
            x,y = x[1],x[2]
            local ndata = multigh:ComputeChunkS(x,y)
            data.Data = ndata[3]
            --ndata[3] = type( ndata[3]) == "table" and i or  ndata[3]
            --SharedDensitiys[v] = ndata[1]
            debug.profilebegin("Upload")
            data.Loading = nil
            sharedservice:Upload(v,ndata)
            data.Event:Fire()
            data.Event:DisconnectAll()
            data.Event = nil
            debug.profileend()
        end
        if i == 1 then
            climate = data.Data
        end
        if s == nil then s = data.Data end
        if s and s ~= data.Data then
            s = false
        end
        finished +=1
        if finished == #loc then
            coroutine.resume(thread)
        end
       end)
    end
    if finished ~= #loc then
        coroutine.yield()
    end
    local data,surface = multigh:InterpolateDensity(cx,cy)
    local newb 
    if not s then
        newb = multigh:LerpBiomes(cx,cy,surface)
        debug.profileend()
    end
    return data,surface,climate,newb
end

function Chunk:GenerateTerrian()
    if self:StateIsDone("Terrian") or self:StateIsDone("GTerrian",true) then   return end
    self:SetState("GTerrian",true)
   -- local terrian = smoothNearby(self.Chunk.X,self.Chunk.Y)
    local terrian,surface,climate,newb = smoothSurface(self.Chunk.X,self.Chunk.Y)--smoothSurface(self:GetNTuple())--multigh:ComputeChunk(self.Chunk.X,self.Chunk.Y)--self:Surface()--multigh:CreateTerrain(self.Chunk.X,self.Chunk.Y)
    --debug.profileend()
    debug.profilebegin("beforecolor")

    debug.profileend()
    local terrian = multigh:Color(terrian,surface,climate,newb)
    self.Biome = climate
--  terrian = gh.Color(self,terrian,surface,newb) 
  debug.profilebegin("addblock")
  self:BulkAdd(terrian)
    -- for i:Vector3,v in terrian do 
    --     self:AddBlock(i,v)
    -- end
    debug.profileend()
    self.Changed = true
    self:SetState("GTerrian")
    self:SetState("Terrian",true)
end
function Chunk:DoCaves()
    self:StateIsDone("GTerrian",true) 
    if self:StateIsDone("Caves") or self:StateIsDone("GCaves",true) then return end
    self:SetState("GCaves",true)

    local stuff  --multigh:GenerateCaves(self:GetNTuple())
    for i,v in stuff or {} do
        if i  == self:GetNString() then
            self:AddToLoad(v)
        else
            local cx,cz = qF.cv2type("tuple",i)
           local c= datahandler.AddToLoad(cx,cz,v) --game.ReplicatedStorage.DataHandler.DoFunc:Invoke("AddToLoad",cx,cz,v)
        end
    end

    self.Changed = true
    self:SetState("GCaves")
    self:SetState("Caves",true)

end
function Chunk:GenerateStructures()
    self:StateIsDone("GTerrian",true) 
    self:StateIsDone("GCaves",true)
    if self:StateIsDone("Structures") or self:StateIsDone("GStructures",true) then return end
    self:LoadToLoad()
    self:SetState("GStructures",true) 
    local start,endd = self:GetCorners2D()
    local x = start.X
    local z = start.Y
    local xhastree = 1
    local zhastree = 1 
    --[[
    while  x <= endd.X do
        z = start.Y
        while z <= endd.Y do
            for y = settings.ChunkSize.Y-1,0,-1 do
                local b = self:GetBlockGrid(x,y,z)
                if type(b) == "table" and b:IsA("c:GrassBlock") then

                    local noise = Random.new((x*y*z*settings.Seed+settings.Seed+self.Chunk.X+self.Chunk.Y+x+y+z)/100):NextNumber()
                    if noise <= .2 and false then
                        local t = {
                            [Vector3.new(x,y+1,z)] = "T|s%c:Wood/O|s%1,0,0",
                            [Vector3.new(x,y+2,z)] ="T|s%c:Wood/O|s%1,0,0",
                            [Vector3.new(x,y+3,z)] = "T|s%c:Wood/O|s%1,0,0",
                            [Vector3.new(x,y+4,z)] = "T|s%c:Leaf",
                            [Vector3.new(x+1,y+4,z)] = "T|s%c:Leaf",
                            [Vector3.new(x-1,y+4,z)] = "T|s%c:Leaf",
                            [Vector3.new(x,y+4,z+1)] = "T|s%c:Leaf",
                            [Vector3.new(x,y+4,z-1)] = "T|s%c:Leaf",
                            [Vector3.new(x,y+5,z)] = "T|s%c:Leaf",
                        }
                        local a = {}
                        for v,i in t do
                            local cx,cz,x,y,z = qF.GetChunkAndLocal(v.X,v.Y,v.Z)
                            local d = self.to1D(x,y,z)
                            local ab = Vector2.new(cx,cz)
                            a[ab] = a[ab]  or {}
                            a[ab][d] = i
                        end
                        for i,v in a do
                            datahandler.AddToLoad(i.X,i.Y,v)
                        end
                        xhastree = 4
                        zhastree = 4
                    end
                    break
                end
            end
            z += zhastree
            zhastree = 1
        end
        x += xhastree
        xhastree = 1
    end
]]
    self.Changed = true
    self:SetState("GStructures")
    self:SetState("Structures",true)
end

local GenerationOrder = {"DoCaves","GenerateStructures"}
function Chunk:GenerateOthers(x)
    if  self:StateIsDone("GeneratingOther",true) or self.Settings.GeneratedOthers  then return end 
    self.Changed = true
    self:SetState("GeneratingOther",true) 
    self.Settings.GeneratedOthers = true

    -- self:DoCaves()
    -- self:GenerateStructures()

    self:SetState("GeneratingOther",false) 
end
local once = false
function Chunk:GenerateNearByChunks()
    local cx,cz =self:GetNTuple()
    local a = qF.GetSurroundingChunk(cx,cz,3)
    local times,count = 1,0
    local stuff = {}
    local thread = coroutine.running()
    for ci,chunk in pairs(a) do
        local cx1,cz1 = unpack(chunk:split(','))
        cx1 ,cz1 = tonumber(cx1),tonumber(cz1)
        local chunk = datahandler.GetChunk(cx1,cz1,true)
        if not chunk.Settings.Generated then
            table.insert(stuff,Vector2.new(cx1,cz1))
        else
            continue
        end
        if cx1 == cx and cz1 == cz then continue end
        task.spawn(function()
            chunk:GenerateTerrian()
            times +=2
            if times == #stuff+count then
                coroutine.resume(thread)
            end
        end)
        count+=1
    end
    if times ~= #stuff+count then 
        coroutine.yield(thread)
    end
   for i,v in GenerationOrder do
    local times = 1
    for ci,chunk in pairs(stuff) do
        local cx1,cz1 = chunk.X,chunk.Y
        if cx1 == cx and cz1 == cz then continue end
        task.spawn(function()
            local chunk = datahandler.GetChunk(cx1,cz1,true)
            if i == 1  then chunk:StateIsDone("GeneratingOther",true)  end 
            if not chunk.Settings.GeneratedOthers then
                if i == 1 then chunk:SetState("GeneratingOther",true)  end 
                chunk[v](chunk)
                if i == #GenerationOrder then
                    chunk:SetState("GeneratingOther",false) 
                    chunk.Settings.GeneratedOthers = true
                end
            end
            times+=1
            if times == #stuff then
                coroutine.resume(thread)
            end
        end)
    end
    if times ~= #stuff then 
        coroutine.yield(thread)
    end
   end
end

function Chunk:IsGenerating()
    if self.Generating then
        self.GeneratingEvent:Wait()
    end
    return self.Generating or self.Settings.Generated
end
function Chunk:SetState(state,value)
    self.Settings.States = self.Settings.States or {}
    self.Settings.States[state] = self.Settings.States[state] or Signal.new()
    self.Settings.GeneratedStates = self.Settings.GeneratedStates or {}
    if state then
        self.Settings.GeneratedStates[state] = value
        if not value then 
            self.Settings.States[state]:Fire(value)     
        end
    else
        self.Settings.GeneratedStates[state] = nil
        self.Settings.States[state]:Fire(false)
    end
end
function Chunk:StateIsDone(state,wait)
    if self.Settings.Generated then return true end 
    local states = ( self.Settings.GeneratedStates or {})
    if not wait then return states[state] end
    if states[state] then 
       repeat
       until not self.Settings.States[state]:Wait()
        return true
    end
    return false
end
function Chunk:Generate()
    if self.Saving  then
        repeat
            task.wait()
        until not self.Saving 
    end
    if self.Settings.Generated then return end
    self.Settings.States = self.Settings.States or {}
    if self.Generating then
        return self.GeneratingEvent:Wait()
    end
    self.Generating = true
    self.GeneratingEvent = Signal.new()
    self:GenerateTerrian()
    --self:GenerateOthers()
 --   self:GenerateNearByChunks()
    self:LoadToLoad()
    debug.profilebegin("createbd")
    for i,v in terrainh.CreateBedrock(self.Chunk.X,self.Chunk.Y,{}) do
        self:InsertBlock(i.X,i.Y,i.Z,v)
    end
    debug.profileend()
    self.Generating = false
    self.Changed = true
    self.Settings.Generated = true
    self.GeneratingEvent:Fire()
    for i,v in  self.Settings.States or {} do
        v:Fire(false)
        v:DisconnectAll()
    end
    self.GeneratingEvent:DisconnectAll()
    self.GeneratingEvent = nil
    self.Settings.States = nil
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