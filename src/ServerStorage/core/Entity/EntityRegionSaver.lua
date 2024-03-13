local Saver = {}

local Https = game:GetService("HttpService")

local Generator = script.Parent.Parent.Chunk.Generator
local Config = require(Generator.Config)
local RegionHelper = require(Generator.RegionHelper)
local Data = require(game.ReplicatedStorage.Data)
local ByteNet = require(game.ReplicatedStorage.Core.ByteNet)
local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local Signal = require(game.ReplicatedStorage.Libarys.Signal)
local Runner  =require(game.ReplicatedStorage.Runner)
local Debirs = require(game.ReplicatedStorage.Libarys.Debris)

local ActorRegionData = Debirs.getFolder("ActorRegionData", 3)

local Options = Instance.new("DataStoreGetOptions")
Options.UseCache = false
local dss = game:GetService("DataStoreService"):GetDataStore("test21323",0987)

local EntityParser

local RegionSize = Config.RegionSize

local InfoOffset = 4
local CHUNK_INFO_LENGTH = (InfoOffset)*RegionSize*RegionSize

local ToSave = {}

local OnCloseSave = {}

local Regions_Loaded = {}

local function createBaseRegionData(region)
    local s = Signal.new()
    local Chunks = {
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
        Runner.run(function()
            if not ToSave[region] then return end 
            local sus,err = pcall(function(...)  
                dss:SetAsync(tostring(region),data)
            end)
            ToSave[region] = nil 
            print("SAVED ENTITIES IN REGION",region,"|",Config.OnClose,#data,"BYTES")
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

function Saver.getData(region)
    local data = ActorRegionData:get(region)
    if data then 
        return data
    end
    local Data = awaitRegion(region)
    if Data and Data.CompressedString then
        local decompressed = Https:JSONDecode(Data.CompressedString)
        ActorRegionData:set(region,decompressed)
        return data
    end
    return
end


local RTo1d = RegionHelper.To1DVector

function Saver.saveRegion(Region,chunks,deload)
    EntityParser = EntityParser or ByteNet.wrap(ByteNet.Types.entity)
    local allChunks = {}
    local totalSize = 0

    for i,v in chunks do
        local ChunkData = Data.getChunkFrom(v)
        local idx = RTo1d[RegionHelper.localizeChunk(v)]
        if not ChunkData then 
            continue 
        end 
        local ChunkT = {}
        local length = 0
        for _,entity in ChunkData.Entities do
            if EntityHandler.isType(entity, "Player") then continue end 
            local b = EntityParser.sterilize(entity)
            length+= buffer.len(b)
            table.insert(ChunkT,b)
            if deload then 
                Data.removeEntity(entity)
            end 
        end
        if #ChunkT == 0 then
            continue 
        end
        local eBuffer = buffer.create(length+2)
        local cursor = 2
        buffer.writeu16(eBuffer, 0, #ChunkT)
        for i,v in ChunkT do
            local len =  buffer.len(v)
            buffer.copy(eBuffer, cursor, v)
            cursor += len
        end
        allChunks[idx] = eBuffer
        totalSize += buffer.len(eBuffer)
    end

    local RegionBuffer = buffer.create(CHUNK_INFO_LENGTH+totalSize)
    local Entity_cursor = 0
    for i,v in allChunks do

        local len = buffer.len(v)
        buffer.writeu32(RegionBuffer,(i-1)*4,Entity_cursor+1)
        buffer.copy(RegionBuffer, CHUNK_INFO_LENGTH+Entity_cursor, v)
        Entity_cursor+=len
    end
    local Data = Regions_Loaded[Region]
    local json = Https:JSONEncode(RegionBuffer)
    if json ==  Data.CompressedString  then 
        if deload then
            ActorRegionData:remove(Region)
            Regions_Loaded[Region] = nil
        end
        return
     end 
    Data.CompressedString = json
    ActorRegionData:remove(Region)
    ToSave[Region] = json

    task.spawn(function()
        AttempToSaveBlock(Region,deload)
    end)
end

function Saver.addChunk(chunk)
    local Region = RegionHelper.getRegion(chunk)
    if not Regions_Loaded[Region] then
        Regions_Loaded[Region] = awaitRegion(Region) or createBaseRegionData(Region)
    end
end



function Saver.getEntitiesFromChunk(chunk)
    EntityParser = EntityParser or ByteNet.wrap(ByteNet.Types.entity)
    local region = RegionHelper.getRegion(chunk)
    local Data = awaitRegion(region)
    if not Data then return end 
  
    local LargerEntityBuffer = Saver.getData(region)
    if not LargerEntityBuffer then return end 
    local localized = RegionHelper.localizeChunk(chunk)
    local id = RegionHelper.To1DVector[localized]
    local offset = buffer.readu32(LargerEntityBuffer,(id-1)*4)
    if offset == 0 then return end 

    local cursor = CHUNK_INFO_LENGTH+offset-1
    -- print(chunk)
    -- print(cursor)
    -- print(buffer.len(LargerEntityBuffer))
    local numOfentities = buffer.readu16(LargerEntityBuffer, cursor)
    local Entities = {}
    cursor+=2
    while #Entities < numOfentities do
        local entityLength = buffer.readu16(LargerEntityBuffer, cursor) 

        local b = buffer.create(entityLength)
        buffer.copy(b, 0, LargerEntityBuffer,cursor,entityLength)
        local e = EntityParser.desterilize(b)
        cursor +=entityLength
        table.insert(Entities,EntityHandler.fromData(e))
        
    end
  --  print(Entities)
    return Entities
end

function Saver.SaveAll()
    for i,v in ToSave do
        if v == 1 then continue end 
        task.spawn(function()
            AttempToSaveBlock(i, true)
        end)
    end
end

function Saver.OnClose()
    Config.OnClose = true
    for i,v in ToSave do
        if v == 1 then continue end 
        task.spawn(function()
            AttempToSaveBlock(i, true)
        end)
    end
    while next(ToSave) do
        task.wait() 
    end
    for i,v in OnCloseSave do
        task.spawn(function()
            local sus,err = pcall(function(...)  
                dss:SetAsync(tostring(i),v)
            end)
            print("BINDTOCLOSE SAVED ENTITY",i,"|",#v,"BYTES")
            if not sus then
                warn(err)
            end
            OnCloseSave[i] = nil
        end)
    end
    while next(OnCloseSave) do
        task.wait()
    end
end

return Saver