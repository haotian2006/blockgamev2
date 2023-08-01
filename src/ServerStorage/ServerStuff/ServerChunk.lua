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
local datahandler = require(game.ReplicatedStorage.DataHandler)
local gh = require(game.ServerStorage.GenerationHandler)
function Chunk:LoadToLoad()
    for i,v in self.ToLoad do
        self:AddBlock(i,v)
        self.Changed = true
    end
    
end
function Chunk:GenerateTerrian()
    if self:StateIsDone("Terrian") or self:StateIsDone("GTerrian",true) then   return end
    self:SetState("GTerrian",true)
    
    local terrain = multihandler.GetTerrain(self.Chunk.X,self.Chunk.Y,16)
    local color = terrainh.Color(self.Chunk.X,self.Chunk.Y,terrain) 
    for i:Vector3,v in color do 
        self:AddBlock(i,v)
    end

    self.Changed = true
    self:SetState("GTerrian")
    self:SetState("Terrian",true)
end
function Chunk:DoCaves()
    if self:StateIsDone("Caves") or self:StateIsDone("GCaves",true) then return end
    self:SetState("GCaves",true)

    local stuff = gh.CreateWorms(self.Chunk.X,self.Chunk.Y)--multihandler.GenerateWorms(self.Chunk.X,self.Chunk.Y)
    for i,v in stuff do
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
    if self:StateIsDone("Structures") or self:StateIsDone("GStructures",true) then return end
    self:SetState("GStructures",true)
    local start,endd = self:GetCorners2D()
    for x = start.X,endd.X,2 do
        for z = start.Y,endd.Y,2 do
            for y = settings.ChunkSize.Y-1,0,-1 do
                local b = self:GetBlockGrid(x,y,z)
                if type(b) == "table" and b:IsA("C:Grass") then
                --if not gh.IsAir(x,y,z) then
                    local noise = math.noise(x*2/10,z*y/10,settings.Seed)
                    if noise <-.1 then
                        self:InsertBlockGrid(x,y+1,z,"T|s%C:Wood")
                    end
                    break
                end
            end
        end
    end

    self.Changed = true
    self:SetState("GStructures")
    self:SetState("Structures",true)
end

local GenerationOrder = {"DoCaves","GenerateStructures"}
function Chunk:GenerateOthers(x)
    if self:WaitForOther() then return end 
    self.Changed = true
    self.GeneratingOther = true 
    self.Settings.GeneratedOthers = true

    self:DoCaves()
    self:GenerateStructures()

    self.GeneratingOther = false
end
local once = false
function Chunk:GenerateNearByChunks()
    if  once then  return end 
    once = true
    local cx,cz =self:GetNTuple()
    local a = qF.GetSurroundingChunk(cx,cz,3)
    local times = 1
    local stuff = {}
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
        -- task.spawn(function()

        --     if cx1 == -1 and cz1 == 0 then print("a") end 
        --     chunk:GenerateTerrian()
        --     if cx1 == -1 and cz1 == 0 then print("b") end 
        --     times +=1
        -- end)
    end
    -- while times ~= #stuff do
    --     task.wait(.05)
    -- end
   for i,v in GenerationOrder do
    local times = 1
    for ci,chunk in pairs(stuff) do
        local cx1,cz1 = chunk.X,chunk.Y
        if cx1 == cx and cz1 == cz then continue end
        task.spawn(function()
            local chunk = datahandler.GetChunk(cx1,cz1,true)
            if i == 1 and chunk.GeneratingOther then chunk:WaitForOther() end 
            if not chunk.Settings.GeneratedOthers then
                if i == 1 then chunk.GeneratingOther = true end 
                chunk[v](chunk)
                if i == #GenerationOrder then
                    chunk.GeneratingOther = false
                    chunk.Settings.GeneratedOthers = true
                end
            end
            times+=1
        end)
    end
    while times ~= #stuff do
        task.wait()
    end
   end
end
function Chunk:WaitForOther()
    if self.GeneratingOther then
        repeat
            task.wait()
        until not self.GeneratingOther
        return true
    end
    if self.Settings.GeneratedOthers then
        return true
    end
    return false
end
function Chunk:IsGenerating()
    if self.Generating then
        repeat task.wait()until self.Generating == false
    end
    return self.Generating or self.Settings.Generated
end
function Chunk:WaitForGeneration()
    if self.Generating or self.GeneratingOther then
        repeat task.wait()until not self.Generating  and not self.GeneratingOther 
    end
end
function Chunk:SetState(state,value)
    self.Settings.GeneratedStates = self.Settings.GeneratedStates or {}
    if state then
        self.Settings.GeneratedStates[state] = value
    else
        self.Settings.GeneratedStates[state] = nil
    end
end
function Chunk:StateIsDone(state,wait)
    if self.Settings.Generated then return true end 
    local states = ( self.Settings.GeneratedStates or {})
    if not wait then return states[state] end
    if states[state] then 
        while states[state] do
            task.wait()
        end
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
    if self.Generating then
        repeat task.wait()until self.Generating == false
        return
    end
    self.Generating = true
    self:GenerateTerrian()
    self:GenerateOthers()
    self:GenerateNearByChunks()
    self:LoadToLoad()
    task.wait()
    for i,v in terrainh.CreateBedrock(self.Chunk.X,self.Chunk.Y,{}) do
        self:InsertBlock(i.X,i.Y,i.Z,v)
    end
    self.Generating = false
    self.Changed = true
    self.Settings.Generated = true
end

function Chunk.Create(x,y,ndata)
    local data = BlockSaver.GetChunk(x,y)
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