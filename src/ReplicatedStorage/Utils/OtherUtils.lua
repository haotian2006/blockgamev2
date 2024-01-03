local Utils = {}

function Utils.chunkDictToArray(dict,center)
    local array = table.create(100)
    local idx =0
    for i,v in dict do
        idx +=1
        array[idx] = {i,(i-center).Magnitude}
    end
    table.sort(array,function(a,b)
        return a[2] < b[2]
    end)
    for i,b in array do
        array[i] = b[1]
    end
    return array
end
return Utils