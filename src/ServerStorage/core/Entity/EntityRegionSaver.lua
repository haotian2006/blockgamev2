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
local communicator = require(Generator.Communicator)

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

local Recieved = {}
local function createBaseRegionData(region)
    local s = Signal.new()
    local Chunks = {
        Signal = s,
        LastSave = 0,
    }
    task.spawn(function()
       
        local d = Recieved[region]
        if not d then
            --print("requested ",region)
            d = Signal.new()
            Recieved[region] = d
            local Id = RegionHelper.getIndexFromRegion(region.X,region.Z)
            communicator.sendMessageToId(Id, "GetEntitiesInRegion",region)
            d = d:Wait()
        end
       -- print("Recieved",region,#d)
        Chunks.CompressedString = d
        Chunks.Signal = nil
        s:Fire()
        Recieved[region] = nil

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
    local s = os.clock()
    for i,v in chunks do
        local ChunkData = Data.getChunkFrom(v)
        local idx = RTo1d[RegionHelper.localizeChunk(v)]
        if not ChunkData then 
            local rawBuffer =Saver.getrawEntitiesBuffer(v)
            if not rawBuffer then continue end 

            allChunks[idx] = rawBuffer
            totalSize += buffer.len(rawBuffer)

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
        buffer.writeu16(eBuffer, 0, length)
        for i,v in ChunkT do
            local len =  buffer.len(v)
            buffer.copy(eBuffer, cursor, v)
            cursor += len
        end
       -- print(#ChunkT,buffer.len(eBuffer))
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
   -- print((os.clock()-s)*1000,"ms",#json)

    if json ==  Data.CompressedString  then 
        if deload then
            ActorRegionData:remove(Region)
            Regions_Loaded[Region] = nil
        end
        return  Data.CompressedString
     end 
    Data.CompressedString = json
    ActorRegionData:remove(Region)
    -- ToSave[Region] = json

    -- task.spawn(function()
    --     AttempToSaveBlock(Region,deload)
    -- end)
    if deload then
        Regions_Loaded[Region] = nil
    end
    return json,true
end

function Saver.addChunk(chunk)
    local Region = RegionHelper.getRegion(chunk)
    if not Regions_Loaded[Region] then
        Regions_Loaded[Region] = awaitRegion(Region) or createBaseRegionData(Region)
    end
end



function Saver.getEntitiesFromChunk(chunk)
    EntityParser = EntityParser or ByteNet.wrap(ByteNet.Types.entity)
    Saver.addChunk(chunk)
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
    local maxLength = buffer.readu16(LargerEntityBuffer, cursor)
    local Entities = {}
    local rawCursor = 0
    cursor+=2
    debug.profilebegin("UnpackEntities")

    while rawCursor < maxLength do
        local entityLength = buffer.readu16(LargerEntityBuffer, cursor) 

        local b = buffer.create(entityLength)
        buffer.copy(b, 0, LargerEntityBuffer,cursor,entityLength)
        local e = EntityParser.desterilize(b)
        cursor +=entityLength
        rawCursor+=entityLength
        table.insert(Entities,EntityHandler.fromData(e))
    end
    debug.profileend()
    return Entities
end
function Saver.getrawEntitiesBuffer(chunk)
    EntityParser = EntityParser or ByteNet.wrap(ByteNet.Types.entity)
    Saver.addChunk(chunk)
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
    local maxLength = buffer.readu16(LargerEntityBuffer, cursor)+2

    local temp = buffer.create(maxLength)
    buffer.copy(temp, 0, LargerEntityBuffer,cursor,maxLength)
    return temp
end

Generator.Event.Event:Connect(function(type,Region,Entity)
    if type ~= "EntityData" then return end 
    if Recieved[Region] then
        Recieved[Region]:Fire(Entity)
    else
        Recieved[Region] = Entity
    end
end)


return Saver