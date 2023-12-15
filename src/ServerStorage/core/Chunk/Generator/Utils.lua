local Utils = {}
function Utils.BiomeBufferToTableOLD(biomes,key)
    local biomeMap = table.create(64)
    for i =0,buffer.len(biomes)/12-1 do
        local v = (buffer.readu16(biomes,i*12))
        local repeatAmt = bit32.rshift(v, 6)+1
        local value = key[bit32.band(v, 63)+1]
        for i = 1,repeatAmt do
            biomeMap[#biomeMap+1] = value
        end
    end
    return biomeMap
end
function Utils.BiomeBufferToTable(b,key)
    local biomeMap = table.create(64)
    for i =0,63 do
        local value = buffer.readf32(b, i*6)
        biomeMap[i+1] = key[value]
    end
    return biomeMap
end
return Utils