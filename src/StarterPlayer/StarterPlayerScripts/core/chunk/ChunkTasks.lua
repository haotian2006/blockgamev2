local tasks = {}

local function getTransparency(block)
    return if block == 0 then 1 else 0
end

function tasks.deCompress(blocks)
    debug.profilebegin("client Decompress")
    local toUse = buffer.create(8*8*256*4)
    local transparencyBuffer = buffer.create(8*8*256)
    buffer.fill(transparencyBuffer,0,255,8*8*256)
    local idx = 0
    local pointer = 1
    for i =0, buffer.len(blocks)//6-1 do
        i*=6
        local bData = buffer.readu32(blocks,i)
        local times = buffer.readu16(blocks, i+4)
        pointer+=times
        if bData == 0 then
            idx+=times 
            continue 
        end 
        local transparency = getTransparency(bData)
        for i = 1,times do
            buffer.writeu32(toUse, idx*4, bData)
            buffer.writeu8(transparencyBuffer, idx, transparency*255)
            idx+=1
        end
    end
    return toUse,transparencyBuffer
end


function tasks.createTransparencyMap(data)
    local transparencyBuffer = buffer.create(8*8*256)
    for i =0,8*8*256-1 do
        local blockAt = buffer.readu32(data, i*4)
        local transparency = getTransparency(blockAt)
        if transparency == 0 then continue end 
        buffer.writeu8(transparencyBuffer, i, transparency*255)
    end
    return transparencyBuffer
end


return tasks