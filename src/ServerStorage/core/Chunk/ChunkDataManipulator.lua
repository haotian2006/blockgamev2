local Data = {}
local Settings = require(script.Parent.Generator.Config)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local RegionSize = Settings.RegionSize
--  ChunkData {4b: Offset 4b: length,128b:biome}

local BIOME_BUFFER_BIT = 0x80000000
local BLOCK_LENGTH_MASK = 0x7FFFFFFF
local InfoOffset = 128+4+4
local CHUNK_INFO_LENGTH = (InfoOffset)*RegionSize*RegionSize


function Data.createChunkInfoBuffer()
    return buffer.create(CHUNK_INFO_LENGTH)
end

function Data.extractDataFromInfo(info,ChunkId)
    local offset = InfoOffset*(ChunkId-1)
    local blockOffset = buffer.readu32(info, offset) 
    if blockOffset == 0 then return end 
    local secondPart =  buffer.readu32(info, offset+4) 

    local Isnumber = bit32.band(secondPart, BIOME_BUFFER_BIT) == BIOME_BUFFER_BIT
    local blockLength = bit32.band(secondPart, BLOCK_LENGTH_MASK)

    local Biomes 
    if Isnumber then
        --Biomes = buffer.readu32(info, offset+8) 
    else
        Biomes = buffer.create(128)
       -- buffer.copy(Biomes, 0, info,offset+8,128)
    end
    return blockOffset-1,blockLength,Biomes
end

function Data.getBlockOffset(info,ChunkId)
    local offset = InfoOffset*(ChunkId-1)
    local blockOffset = buffer.readu32(info, offset) 
    if blockOffset == 0 then return end 
    return blockOffset-1
end

function Data.setBlockOffset(info,ChunkId,value)
    local offset = InfoOffset*(ChunkId-1)
    buffer.writeu32(info, offset,value+1) 
end

function Data.updateLoc(info,ChunkId,blockOffset,length)
    local offset = InfoOffset*(ChunkId-1)
    local secondPart =  buffer.readu32(info, offset+4) 
    local Isnumber = bit32.band(secondPart, BIOME_BUFFER_BIT) == BIOME_BUFFER_BIT
    local SecondPart = (Isnumber and BIOME_BUFFER_BIT or 0) + (length % (BLOCK_LENGTH_MASK + 1))

    buffer.writeu32(info, offset, blockOffset+1)
    buffer.writeu32(info, offset + 4, SecondPart)
end

function Data.getLoc(info,ChunkId)
    local offset = InfoOffset*(ChunkId-1)
    local blockOffset = buffer.readu32(info, offset) 
    if blockOffset == 0 then return end 
    local secondPart =  buffer.readu32(info, offset+4) 
    local blockLength = bit32.band(secondPart, BLOCK_LENGTH_MASK)
    return blockOffset-1,blockLength
end

function Data.writeDataToInfo(info, ChunkId, blockOffset, blockLength, Biomes)
    local offset = InfoOffset * (ChunkId - 1)
    
    local isNumber = type(Biomes) == "number"

    local SecondPart = (isNumber and BIOME_BUFFER_BIT or 0) + (blockLength % (BLOCK_LENGTH_MASK + 1))

    buffer.writeu32(info, offset, blockOffset+1)
    buffer.writeu32(info, offset + 4, SecondPart)

    if isNumber then
        --buffer.writeu32(info, offset + 8, Biomes)
    else
      --  buffer.copy(info, offset + 8, Biomes)
    end
end

function Data.getChunkInfo(info,blocksBuffer,ChunkId,Decompressed)
    local blockOffset,blockLength,Biomes = Data.extractDataFromInfo(info,ChunkId)
    if not blockOffset then return end 
    local Offset = blockOffset
    local tempBuffer
    if not Decompressed then
        tempBuffer = buffer.create(blockLength)
        buffer.copy(tempBuffer, 0, blocksBuffer, Offset,blockLength)
    else
        tempBuffer = Data.decompressBlockBufferFromSource(blocksBuffer,Offset,blockLength)
    end 
    return tempBuffer,Biomes
end

function Data.SeparateData(b)
    local len = buffer.len(b)-CHUNK_INFO_LENGTH
    local Info = buffer.create(CHUNK_INFO_LENGTH)
    local Data = buffer.create(len)
    buffer.copy(Info, 0, b,0,CHUNK_INFO_LENGTH)
    buffer.copy(Data, 0, b,CHUNK_INFO_LENGTH,len)
    return Info,Data
end

function Data.CombineData(info,blockData,size)
    size = size or buffer.len(blockData)
    local newBuffer = buffer.create(CHUNK_INFO_LENGTH+size)
    buffer.copy(newBuffer, 0, info)
    buffer.copy(newBuffer, CHUNK_INFO_LENGTH, blockData,0,size)
    return newBuffer
end

local compressTempTable = {}
function Data.compressBlockBuffer(b)
    table.clear(compressTempTable)
    local current
    local idx = 0
    local length = 0
    debug.profilebegin("compress")
    
    for i =0,8*8*256-1 do
        local value = buffer.readu32(b, i*4)
        if value ~= current then
            if current ~= nil then  
                compressTempTable[idx] = Vector3.new(current,length)
            end
            current = value 
            length = 0
            idx+=1
        end
        length+=1
    end

    if  compressTempTable[idx-1] and compressTempTable[idx-1].X == current then
        compressTempTable[idx-1]+=Vector3.new(0,length)
    else
        compressTempTable[idx] = Vector3.new(current,length)
    end

    local cBuffer = buffer.create(#compressTempTable*6)
    for i,v in compressTempTable do
        local idx_ = (i-1)*6
        buffer.writeu32(cBuffer,idx_, v.X)
        buffer.writeu16(cBuffer,idx_+4, v.Y)
    end
    debug.profileend()
    return cBuffer
end

function Data.decompressBlockBufferFromSource(blocks,Offset,Length)
    debug.profilebegin("decompress BlockBuffer from source")
    local toUse = buffer.create(8*8*256*4)
    local idx = 0
    local t = {}
    for i =0, Length//6-1 do
        i*=6
        i +=Offset
        local bData = buffer.readu32(blocks,i)
        local times = buffer.readu16(blocks, i+4)
        table.insert(t,{bData,times})
        if bData == 0 then
            idx+=times 
            continue 
        end 
        for _ = 1,times do
    
            buffer.writeu32(toUse, idx*4, bData)

            idx+=1
        end
    end
    debug.profileend()
    return toUse
end

function Data.decompressBlockBuffer(blocks)
    debug.profilebegin("Decompress BlockBuffer")
    local toUse = buffer.create(8*8*256*4)
    local idx = 0
    for i =0, buffer.len(blocks)//6-1 do
        i*=6
        local bData = buffer.readu32(blocks,i)
        local times = buffer.readu16(blocks, i+4)
        if bData == 0 then
            idx+=times 
            continue 
        end 
        for i = 1,times do
            buffer.writeu32(toUse, idx*4, bData)
            idx+=1
        end
    end
    debug.profileend()
    return toUse
end


return Data