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
    local xx = 0
    for dist = 0, r do
        for x = -dist, dist do
            local zBound = math.floor(math.sqrt(r * r - x * x)) -- Bound for 'z' within the circle
            for z = -zBound, zBound do
                if table.find(precomputed,Vector3.new(x,0,z)) then continue end 
                table.insert(precomputed,Vector3.new(x,0,z))
                xx+=1
            end
        end
    end
    allSquare[r] = precomputed
    return precomputed
end
return Utils