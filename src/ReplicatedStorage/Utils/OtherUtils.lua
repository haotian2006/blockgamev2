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

local allSquare = {}
function Utils.preComputeSquare(r)
    if allSquare[r] then return allSquare[r] end 
    local precomputed = {}
    for x = -r, r do
        for z = -r, r do
            local vector = Vector3.new(x,0,z)
            local mag = vector.Magnitude
          -- if mag-.1 >=r then continue end 
            table.insert(precomputed,vector+Vector3.new(0,mag))
            
        end
    end
    table.sort(precomputed,function(a,b)
        return a.Y<b.Y
    end)
    local remove = Vector3.new(1,0,1)
    for i = 1, #precomputed do
        precomputed[i] *= remove
    end
    allSquare[r] = precomputed
    return precomputed
end

local allCircle = {}
function Utils.preComputeCircle(r)
    if allCircle[r] then return allCircle[r] end 
    local precomputed = {}
    for x = -r, r do
        for z = -r, r do
            local vector = Vector3.new(x,0,z)
            local mag = vector.Magnitude
            if mag >=r then continue end 
            table.insert(precomputed,vector+Vector3.new(0,mag))
            
        end
    end
    table.sort(precomputed,function(a,b)
        return a.Y<b.Y
    end)
    local remove = Vector3.new(1,0,1)
    for i = 1, #precomputed do
        precomputed[i] *= remove
    end
    allCircle[r] = precomputed
    return precomputed
end

--(WARNIN THIS METHOD IS ACUTALLY SLOWER FOR LARGER TABLES)
function Utils.chunkDictToArrayV2(dict, center)
    local sortedKeys = {}

    for key, _ in dict do
        local index = 1
        local toInsert = {key,(center-key).Magnitude}
        local current =  sortedKeys[index]
        while index <= #sortedKeys and toInsert[2] > current[2] do
            index = index + 1
        end

        table.insert(sortedKeys, index, toInsert)
    end

    for i,v in sortedKeys do
        sortedKeys[i] = v[1]
    end

    return sortedKeys
end

function Utils.findKeyDiffrences(old,new)
    local ToRemove = {}
    local ToAdd = {}
    local same = {}

    for key in old do
        if not new[key] then
            ToRemove[key] = true
        else
            same[key] = true
        end
    end

    for key in new do
        if not old[key] then
            ToAdd[key] = true
        end
    end
    return ToAdd,ToRemove,same
end

return Utils