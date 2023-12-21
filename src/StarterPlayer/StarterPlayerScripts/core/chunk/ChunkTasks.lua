local tasks = {}
function tasks.deCompress(blocks)
    debug.profilebegin("clien Compress")
    local toUse = buffer.create(8*8*256*4)
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
        for i = 1,times do
                buffer.writeu32(toUse, idx*4, bData)
                idx+=1
        end
    end
    return toUse
end
return tasks