local Region = {}
local Https = game:GetService("HttpService")

local ChunkCompresser = require(script.Parent.Chunk)
local RegionHelper = require(script.Parent.Parent.RegionHelper)
local RegionDataHandler = require(script.Parent.RegionDataHandler)
local Communicator = require(script.Parent.Parent.Communicator)
local Signal = require(game.ReplicatedStorage.Libarys.Signal)
local Debirs = require(game.ReplicatedStorage.Libarys.Debris)
local Queue = require(game.ReplicatedStorage.Libarys.DataStructures.Queue)
local ActorRegionData = Debirs.getFolder("ActorRegionData", 3)
local Config = require(script.Parent.Parent.Config)

local Options = Instance.new("DataStoreGetOptions")
Options.UseCache = false
local dss = game:GetService("DataStoreService"):GetDataStore("test232",91192)

local Runner = Communicator.getRunner()

local _,regionNum = Communicator.getActor()

local Regions_Loaded = {}

local function createBaseRegionData(region)
    local s = Signal.new()
    local Chunks = {
        NewChunks = {},
        Changed = {},
        Signal = s,
        LastSave = 0,
    }
    task.spawn(function()
        local err,Compressed = pcall(function(...)  
            return dss:GetAsync(tostring(region),Options)
        end)
        if not err then 
            warn(Compressed)
        end
        Chunks.CompressedString = Compressed
        Chunks.Signal = nil
        s:Fire()

    end)
    return  Chunks
end

local function awaitRegion(region)
    local Data = Regions_Loaded[region]
    if not Data then return end 
    if Data.Signal then
        Data.Signal:Wait()
    end
    return Data
end

local ToSave = {}

local OnCloseSave = {}

local function AttempToSaveBlock(region,toRemove)
    local data =  ToSave[region]
    if data == 1 or not data then return end 
    ToSave[region] = 1
    local rdata = Regions_Loaded[region]
    if not rdata then 
        ToSave[region] = nil 
        return 
    end 
    local LastSave = rdata.LastSave
    if os.time()-LastSave>=50 or Config.OnClose then
        if Config.OnClose then
            ToSave[region] = nil
            OnCloseSave[region] = data
            return
        end
        rdata.LastSave = os.time()
        Runner.Run(function()
            if not ToSave[region] then return end 
            local sus,err = pcall(function(...)  
                dss:SetAsync(tostring(region),data)
            end)
            ToSave[region] = nil 
            print("SAVED REGION",region,"|",regionNum,#data,"BYTES")
            if not sus then
                warn(err)
            end
        end)
        if toRemove then
            Regions_Loaded[region] = nil
        end
    else
        ToSave[region] = data
    end

end

local TempBuffer = buffer.create(2_500_000)
local getLoc = RegionDataHandler.getLoc
local getOffset = RegionDataHandler.getBlockOffset
local writeOffset = RegionDataHandler.setBlockOffset
local function RemoveAndShift(info,offset,amt,totalSize)
    local endOffset = offset + amt
    local bytesToShift = totalSize - endOffset 
    buffer.copy(TempBuffer, offset, TempBuffer,endOffset,bytesToShift)
    for idx in RegionHelper.to2D do
        local of = getOffset(info,idx)
        if not of or offset >= of then continue end 
        writeOffset(info,idx,of-amt)
    end
end

local CompressRegionsQueue = Queue.new(1000)
local CurrentlyUpdating = 0
local function UpdateChunk(region,toRemove)
    local start = os.clock()
    local Data = Regions_Loaded[region]
    local NewChunks = Data.NewChunks
    local Info,Bdata = Region.getData(region)
    if not Info then
        Info,Bdata = RegionDataHandler.createChunkInfoBuffer(),buffer.create(0)
    end
    local HadUpdates = false
    debug.profilebegin("CheckALl")
    local Changed = Data.Changed
    local ToCompress = {}
    for Chunk,rest in Changed do
        local Localized = RegionHelper.localizeChunk(Chunk)
        local Rid = RegionHelper.To1DVector[Localized]
        local BlockData,Biome 
        local newData = NewChunks[Chunk]
        if newData then
            BlockData = newData[1]
            Biome = newData[2]
        else 
            local offset = RegionDataHandler.getLoc(Info,Rid)
            if not offset then continue end 
            Biome,BlockData = ChunkCompresser.Des(Bdata, offset)
        end
        for _,v2 in rest do
            local idx,value = v2.X-1,v2.Y
            buffer.writeu32(BlockData, idx*4, value)
        end
        HadUpdates = true
        table.insert(ToCompress,{Rid,BlockData,Biome})
    end
    debug.profileend()
    table.clear(Changed)
    if not HadUpdates then 
        if toRemove then
            ActorRegionData:remove(region)
            Regions_Loaded[region] = nil
        end
        return 
    end 
    local NewData = {}
    local InfoToUse = {
        coroutine.running(),
        #ToCompress,
        NewData
    }
    for i,v in ToCompress do
        v[4] = InfoToUse
        Config.HasToCompress = true
        Queue.enqueue(CompressRegionsQueue, v)
    end
    CurrentlyUpdating+=1
    coroutine.yield()
    CurrentlyUpdating-=1
    local size = buffer.len(Bdata)

    buffer.copy(TempBuffer, 0, Bdata)
    for id,v in NewData do
        local OldOffset,OldLength = getLoc(Info,id)
        if OldOffset then
            RemoveAndShift(Info,OldOffset,OldLength,size)
            size-= OldLength
        end
    end
    debug.profilebegin("Write")
    for id,compressed in NewData do
        local length = buffer.len(compressed)
        buffer.copy(TempBuffer, size, compressed)
        RegionDataHandler.updateLoc(Info, id, size, length)
        size+= length
    end
    debug.profileend()
    local combined = RegionDataHandler.CombineData(Info, TempBuffer, size)
    local json = Https:JSONEncode(combined)
    -- print("combined")
    -- print(buffer.len(combined))
    -- print(#json)
    -- local e = os.clock()-start
    -- print(e*1000,"ms")
    -- print("Frames",e*60)
    Data.CompressedString = json
    ActorRegionData:remove(region)
    task.synchronize()
    ToSave[region] = json
    task.spawn(function()
        AttempToSaveBlock(region,toRemove)
    end)
end

function Region.getData(region)
    local data = ActorRegionData:get(region)
    if data then 
        return data[1],data[2]
    end
    local Data = awaitRegion(region)
    if Data and Data.CompressedString then
        local decompressed = Https:JSONDecode(Data.CompressedString)
        local chunk,info = RegionDataHandler.SeparateData(decompressed)
        ActorRegionData:set(region,{chunk,info})
        return chunk,info
    end
    return
end


function Region.addChunk(chunk,blocks,biomes)
    local region = RegionHelper.getRegion(chunk)
    local Data = awaitRegion(region)
    if not Data then return end 
    Data.NewChunks[chunk] = {blocks,biomes}
    Data.Changed[chunk] = {}
end

function Region.getChunkData(chunk)
    local region = RegionHelper.getRegion(chunk)
    local Data = awaitRegion(region)
    if not Data then return end 
  
    local info,block = Region.getData(region)
    if not info then return end 
    local localized = RegionHelper.localizeChunk(chunk)
    local id = RegionHelper.To1DVector[localized]
    local biome,shape = RegionDataHandler.getChunkInfo(info, block, id)
    if not shape then return end 
    return  shape,biome
end

local ToUpdate = {}

function Region.Loop()
    local start = os.clock()
    local Saved = true
    for i =1,50 do
        if os.clock()-start >=0.015 then break end 
        local nextItem = Queue.dequeue(CompressRegionsQueue)
        if not nextItem then 
            Config.HasToCompress = false 
            break 
        end
        Saved = false
        local b = ChunkCompresser.Ster(nextItem[2], nextItem[3])
        local other = nextItem[4]
        other[2] -=1
        other[3][nextItem[1]] = b
        if other[2] == 0 then
            task.spawn(other[1])
        end
    end
    return Saved
end

Communicator.bindToMessage("UpdateAllRegions",function(from)
    for i,v in ToSave do
        if v == 1 then continue end 
        task.spawn(function()
            AttempToSaveBlock(i, true)
        end)
    end
end)


Communicator.bindToMessage("UpdateRegion",function(from,region,Changed,toRemove)
    local Data = awaitRegion(region)
    if not Data then return end 
    local c = Data.Changed
    for i,v in Changed or {} do
        c[v[1]] = v[2]
    end
    UpdateChunk(region,toRemove)
end)

Communicator.bindToMessage("AddRegion",function(from,region)
    Regions_Loaded[region] = awaitRegion(region) or createBaseRegionData(region)
end)

Communicator.bindToMessage("RemoveRegion",function(from,region)
    Regions_Loaded[region] = nil
end)

game:BindToClose(function()
    Config.OnClose = true
    task.wait(.5)
    for i,v in ToSave do
        if v == 1 then continue end 
        task.spawn(function()
            AttempToSaveBlock(i, true)
        end)
    end
    while next(ToUpdate) or next(ToSave) do
        task.wait() 
    end
    for i,v in OnCloseSave do
        task.spawn(function()
            local sus,err = pcall(function(...)  
                dss:SetAsync(tostring(i),v)
            end)
            print("BINDTOCLOSE SAVED REGION",i,"|",regionNum,#v,"BYTES")
            if not sus then
                warn(err)
            end
            OnCloseSave[i] = nil
        end)
    end
    while next(OnCloseSave) do
        task.wait()
    end
    Communicator.sendMessageMain("OnClose",true)
end)




return Region