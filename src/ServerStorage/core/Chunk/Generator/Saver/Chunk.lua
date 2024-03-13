local Chunk = {}
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local LargePalletBuffer = buffer.create(100_000)
local LargeBlockBuffer = buffer.create(100_000)
local bitBuffer = require(game.ReplicatedStorage.Libarys.bitBuffer)
local Https = game:GetService("HttpService")
local TO1DVector = IndexUtils.to1DVector
local SECTION_HEIGHT = 16 --No touchy pls
local MAX_SECTIONS = 256/SECTION_HEIGHT
local MAXBITS = 9
local WRITTERS = {
    [0] = function() end ,
}
local READERS = {
    [0] = function() return 0 end ,
}
do
    local sample = bitBuffer.writer(buffer.create(0))
    local sampleR = bitBuffer.reader(buffer.create(0))
    for i = 1,MAXBITS do
        local str = `UInt{i}`
        WRITTERS[i] = sample[str]
        READERS[i] = sampleR[str]
    end
end
local SECTION_ITER = {}
local ITER_FOR_SECTION = {}
for y = 1,SECTION_HEIGHT do
    for x = 1,8 do
        for z = 1,8 do
            table.insert(SECTION_ITER,Vector3.new(x,y,z))
        end
    end
end
for i =0,MAX_SECTIONS-1 do
    local startY = SECTION_HEIGHT*i
    local baseVector = Vector3.new(0,startY,0)
    local t = {}
    ITER_FOR_SECTION[i+1] = t
    for i,offset in SECTION_ITER do
        local pos = baseVector + offset
        local idx = TO1DVector[pos]
        t[i] = idx-1
    end
end


local function getBits(x)
    if x == 0 then return 0 end 
    return math.floor(math.log(x,2)+1)
end

local palletTable = table.create(#SECTION_ITER)
local blockTable = table.create(#SECTION_ITER)

local function SterSectionHelper(SizeOfPallet)
    if SizeOfPallet == 1 and palletTable[1] then
        return 0
    end
    local bitsNeed = getBits(SizeOfPallet-1)
    if bitsNeed > MAXBITS then
        local b = buffer.create(8*8*SECTION_HEIGHT*4)

        for i,v in blockTable do
            buffer.writeu32(b, (i-1)*4,  buffer.readu32(LargePalletBuffer, (v)*4))
        end
        return 1,b
    end
    local palletBuffer = buffer.create(SizeOfPallet*4)
    buffer.copy(palletBuffer, 0, LargePalletBuffer,0,SizeOfPallet*4)
    local writterObj = bitBuffer.writer(LargeBlockBuffer)
    local fx = WRITTERS[bitsNeed]
    debug.profilebegin("writter")
    for i,v in blockTable do
        fx(writterObj,v)
    end
    debug.profileend()
    local Cursor = writterObj.byte + (writterObj.bit > 0 and 1 or 0)
    local blockBuffer = buffer.create(Cursor)
    buffer.copy(blockBuffer, 0, LargeBlockBuffer,0,Cursor)
    buffer.fill(LargeBlockBuffer, 0, 0,Cursor)
    return 2,bitsNeed,palletBuffer,blockBuffer
end
--section will range from [0,x]

function Chunk.SterSection(blocks,section)
    table.clear(palletTable)
    table.clear(blockTable)

    local SizeOfPallet = 0
    local checkedAir = false
    debug.profilebegin("writePallet")
    for i,idx in ITER_FOR_SECTION[section] do
        local blockAt = buffer.readu32(blocks, (idx)*4)
        if blockAt == 0  and checkedAir then 
            blockTable[i] = checkedAir
        end 
        local lx = blockAt+1
        local location = palletTable[lx]
        if not location then
            buffer.writeu32(LargePalletBuffer, SizeOfPallet*4, blockAt)
            SizeOfPallet+=1
            palletTable[lx] = SizeOfPallet-1
            location = SizeOfPallet-1
            if blockAt == 0 then 
                checkedAir =location
            end
        end
        blockTable[i] = location
    end
    debug.profileend()
    local op,bits,palletb,blockb = SterSectionHelper(SizeOfPallet)
    return op,bits,palletb,blockb
end

function Chunk.DesSection(blockBuffer,cursor,bits,pallet,section,offset)
    local Reader = READERS[bits]

    local readerObj = bitBuffer.reader(section)
    readerObj.byte = cursor
    local t = {}
    for i,idx in ITER_FOR_SECTION[offset] do
        local BlockIdx = Reader(readerObj)
        local Block = buffer.readu32(pallet, BlockIdx*4)
        if Block ~= 0 then
            buffer.writeu32(blockBuffer, (idx)*4 , Block)
            t[idx] = Block
        end
    end
    local length = readerObj.byte + (readerObj.bit > 0 and 1 or 0)
    return length-cursor
end
local total = 0 

local ENDPOINT = 2^16-1
local LightBufferSize =( 8*8*256)/2
local LightBuffer = buffer.create(LightBufferSize)
function Chunk.Ster(blocks,biome)
    local sections = {}
    local pallets = {}
    local biomeBuffer
    if typeof (biome) == "buffer" then
       biomeBuffer = biome
    else
        biomeBuffer = buffer.create(4)
        buffer.writeu16(biomeBuffer, 0, ENDPOINT)
        buffer.writeu16(biomeBuffer, 2, biome)
    end
    debug.profilebegin('SterSection')
    for i =1,MAX_SECTIONS do
        local m,bits,pallet,blockb = Chunk.SterSection(blocks, i)
        if m == 0 then --empty
            sections[i] = ""
            pallets[i] = ""
        elseif m == 1 then--full
            sections[i] = bits
            pallets[i] = ""
        else--normal
            sections[i] = blockb
            pallets[i] = {bits,pallet}
        end
    end
    debug.profileend()
    debug.profilebegin("Write Section")
    local cursor = 0
    for i =1,MAX_SECTIONS do --These two cannot be combines because the way LargeBuffer Is Used between
        local sec = sections[i]
        local pallet = pallets[i]
        if sec == "" and pallet == "" then
            buffer.writeu8(LargeBlockBuffer, cursor, 254)
            cursor+=1
            continue
        end


        if pallet == "" then
            buffer.writeu8(LargeBlockBuffer, cursor, 255)
            cursor+=1
        else
            buffer.writeu8(LargeBlockBuffer, cursor, pallet[1])
            cursor+=1
            local l = buffer.len(pallet[2])
            buffer.writeu16(LargeBlockBuffer, cursor, l)
            cursor+=2
            buffer.copy(LargeBlockBuffer, cursor, pallet[2])
            cursor+= l
        end
        if sec == "" then

        else
            local l = buffer.len(sec)
            buffer.copy(LargeBlockBuffer, cursor, sec)
            cursor+=l
        end
    end
    --buffer.writeu8(LightBuffer, math.random(0,1024), math.random(0,255))
    local Lightlength = 0--#compressedLight+2
    local BiomeLength = buffer.len(biomeBuffer)
    local BlockData = buffer.create(cursor+BiomeLength+2+Lightlength)
    buffer.copy(BlockData,0,biomeBuffer)
    buffer.writeu16(BlockData,BiomeLength,Lightlength)
   -- buffer.writestring(BlockData,BiomeLength+2,compressedLight)
    buffer.copy(BlockData, BiomeLength+2+Lightlength, LargeBlockBuffer,0,cursor)
    debug.profileend()
    return BlockData

end


local biomeLength = 2*8*8
function Chunk.Des(b,cursor)
    local Cursor = cursor or 0
    local Biome = buffer.readu16(b, Cursor)
    local blockBuffer = buffer.create(8*8*256*4)
    local start = Cursor
    if Biome == ENDPOINT then
        Cursor+=2
        Biome = buffer.readu16(b, Cursor)
        Cursor+=2
    else
        Biome = buffer.create(biomeLength)
        buffer.copy(Biome, 0, b,Cursor,biomeLength)
        Cursor+=biomeLength
    end
    local lightBufferLength = buffer.readu16(b, Cursor)
    Cursor+=2
    Cursor+=lightBufferLength
    local a = Cursor
    for i =1,MAX_SECTIONS do 
        local bits = buffer.readu8(b, Cursor)
        Cursor+=1
        local Pallet
        if bits == 254 then
            continue
        elseif bits == 255 then
            Pallet = false
        else
            local length = buffer.readu16(b, Cursor)
            Cursor+=2
            Pallet = buffer.create(length)
            buffer.copy(Pallet, 0, b,Cursor,length)
            Cursor+=length
        end  
        if not Pallet then
            for i,idx in ITER_FOR_SECTION[i] do
                local Block = buffer.readu32(b, Cursor)
                if Block ~= 0 then
                    buffer.writeu32(blockBuffer, (idx)*4 , Block)
                end
                Cursor+=4
            end
            continue
        end
        --print(i,bits,buffer.len(Pallet))
        local blockLength = Chunk.DesSection(blockBuffer,Cursor, bits, Pallet, b, i)
        Cursor+=blockLength
       -- print(i,Cursor-a)
    end
    return Biome,blockBuffer,Cursor - start  
end
return Chunk 