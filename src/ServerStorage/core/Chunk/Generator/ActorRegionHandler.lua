local Https = game:GetService("HttpService")

local RegionHelper = require(script.Parent.RegionHelper)
local Communicator = require(script.Parent.Communicator)
local DataManipulator = require(script.Parent.Parent.ChunkDataManipulator)
local Config = require(script.Parent.Config)
local Debirs = require(game.ReplicatedStorage.Libarys.Debris)
local Signal = require(game.ReplicatedStorage.Libarys.Signal)
local Runner = Communicator.getRunner()

local ActorRegionData = Debirs.getFolder("ActorRegionData", 15)

local Options = Instance.new("DataStoreGetOptions")
Options.UseCache = false
local dss = game:GetService("DataStoreService"):GetDataStore("test232")

local _,regionNum = Communicator.getActor()
local REGION_SIZE = Config.RegionSize

local Region = {}
local Regions = {}



--[[
    {
        compressedBuffer,
        ChunkData {2b:chunkId,128b:biome, 4b: Offset 4b: length}
    }
    --Saved State:
    ChunkData..CompressedBuffer
]]
local getLoc = DataManipulator.getLoc
local getOffset = DataManipulator.getBlockOffset
local writeOffset = DataManipulator.setBlockOffset
local nonAmt = 0
local aa = 0
local function createBaseRegionData(region)
    local s = Signal.new()
    local Chunks = {
        NewChunks = {},
        Changed = {},
        Signal = s,
        LastSave = 0,
    }
    task.spawn(function()
        local Compressed = nil--dss:GetAsync(tostring(region),Options)
        Chunks.CompressedString = Compressed
        Chunks.Signal = nil
        s:Fire()

    end)
    return  Chunks
end

local function awaitRegion(region)
    local Data = Regions[region]
    if not Data then return end 
    if Data.Signal then
        Data.Signal:Wait()
    end
    return Data
end

local TempBuffer = buffer.create(2_500_000)
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

local ToSave = {}

local OnCloseSave = {}

local function AttempToSaveBlock(region,toRemove)
    local data =  ToSave[region]
    if data == 1 or not data then return end 
    ToSave[region] = 1
    local rdata = Regions[region]
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
            ToSave[region] = nil 
            local sus,err = pcall(function(...)  
                dss:SetAsync(tostring(region),data)
            end)
            print("SAVED REGION",region,"|",regionNum,Config.OnClose)
            if not sus then
                warn(err)
            end
        end)
        if toRemove then
            Regions[region] = nil
        end
    else
        ToSave[region] = data
    end

end


local function UpdateRegion(region,toRemove)
    local start = os.clock()
    local Data = Regions[region]
    local NewChunks = Data.NewChunks
    local Info,bdata = Region.getData(region)
    if not Info then
        Info,bdata = DataManipulator.createChunkInfoBuffer(),buffer.create(0)
    end
    local newInfo = {}
    local Changed = Data.Changed
    debug.profilebegin("Adding Changes")
    for Chunk,Rest in Changed do
        local Localized = RegionHelper.localizeChunk(Chunk)
        local Rid = RegionHelper.To1DVector[Localized]
        local ToDecomp,Biome,compressed 
        local newData = NewChunks[Chunk]
        if newData then
            aa += buffer.len(newData[1])
            nonAmt +=  #Https:JSONEncode(newData[1])
            if #Rest ~= 0 then 
                ToDecomp = DataManipulator.decompressBlockBuffer(newData[1])
            else
                compressed = newData[1]
            end
            Biome = newData[2]
        else 
            local offset,length = DataManipulator.getLoc(Info,Rid)
            --print(offset,length,buffer.len(bdata)) 
            ToDecomp =  DataManipulator.decompressBlockBufferFromSource(bdata, offset, length)
        end
        for _,v2 in Rest do
            local idx,value = v2.X-1,v2.Y
            buffer.writeu32(ToDecomp, idx*4, value)
        end
        if ToDecomp then
            compressed = DataManipulator.compressBlockBuffer(ToDecomp)
        end
        table.insert(newInfo,{Rid,compressed,Biome})
    end
    debug.profileend()

    table.clear(Changed)
    table.clear(NewChunks)
    if #newInfo == 0 then 
        return 
    end 
    local size = buffer.len(bdata)
    buffer.copy(TempBuffer, 0, bdata)
    --Removes And Resizes the buffer
    debug.profilebegin("resize")
    for _,v in newInfo do
        local id = v[1]
        local OldOffset,OldLength = DataManipulator.getLoc(Info,id)
        if OldOffset then
            RemoveAndShift(Info,OldOffset,OldLength,size)
            size-= OldLength
        end
    end
    debug.profileend()
    --InsertsnewData
    debug.profilebegin("Write new Location")
    for _,v in newInfo do
        local id,compressed,biomes = v[1],v[2],v[3]
        local length = buffer.len(compressed)
        buffer.copy(TempBuffer, size, compressed)
        if biomes then
            DataManipulator.writeDataToInfo(Info, id, size, length, biomes)
        else
            DataManipulator.updateLoc(Info, id, size, length)
        end
        size+= length
    end
    debug.profileend()
    ActorRegionData:remove(region)
    debug.profilebegin("Encode")
    local combined = DataManipulator.CombineData(Info,TempBuffer,size)
    local Enocded = Https:JSONEncode(combined)
    Data.CompressedString = Enocded
    debug.profileend()
    --print("TOOK", (os.clock()-start)*1000,"ms")
    local amt = 0
    for idx in RegionHelper.to2D do
        local of = getOffset(Info,idx)
        if not of  then continue end 
        amt +=1
    end
    --#Enocded,size,buffer.len(combined),buffer.len(bdata),amt
    print(`\nRegion: {region}\nEncodedSize: {#Enocded}\n BufferSize: {buffer.len(combined)} \n Chunks In Region: {amt}\n ChunkTotal: {aa} \n ChunkTotalCompressed: {nonAmt}`)
    ToSave[region] = Enocded
    task.spawn(function()
        --AttempToSaveBlock(region,toRemove)
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
        local chunk,info = DataManipulator.SeparateData(decompressed)
        ActorRegionData:set(region,{chunk,info})
        return chunk,info
    end
    return
end


function Region.addChunk(chunk,compressedData,biomes)
    local region = RegionHelper.getRegion(chunk)
    local Data = awaitRegion(region)
    if not Data then return end 
    Data.NewChunks[chunk] = {compressedData,biomes}
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
    local shape,biome = DataManipulator.getChunkInfo(info, block, id, false)
    if not shape then return end 
    local decompre = DataManipulator.decompressBlockBuffer(shape)

    return  decompre,shape,biome
end

local ToUpdate = {}

function Region.saveLoop()
    local start = os.clock()
    local Saved = false
    for i,v in ToUpdate do
        if os.clock()-start >=0.014 then break end 
        Saved = true
        UpdateRegion(i,v==1)  
        ToUpdate[i] = nil
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
    ToUpdate[region] = toRemove and 1 or 2
end)

Communicator.bindToMessage("AddRegion",function(from,region)
    Regions[region] = awaitRegion(region) or createBaseRegionData(region)
end)

Communicator.bindToMessage("RemoveRegion",function(from,region)
    Regions[region] = nil
end)

game:BindToClose(function()
    Config.OnClose = true
    task.wait(1)
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
            print("BINDTOCLOSE SAVED REGION",i,"|",regionNum,Config.OnClose)
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