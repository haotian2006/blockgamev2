local block = {}
local Blocks = {
    'c:grass',
    'c:dirt'
}
local Cache = {}
function block.getBlockId(str)
    if Cache[str] then
        return Cache[str]
    end
    local loc = table.find(Blocks, str)
    if loc == -1 then
        error(`'{str}' is not a valid block`)
    end
    Cache[str] = loc-1
    return loc-1
end
function block.getBlock(id)
    return Blocks[id+1]
end
return block