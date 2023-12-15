local greedy = {}
local gs = require(game.ReplicatedStorage.GameSettings)

local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)

local function findintable(tab,x,y,z)
   if tab[x] and tab[x][y] and tab[x][y][z]   then
       return tab[x][y][z] 
   end
end
local function addtotabl(tab,data,x,y,z)
   tab[x] = tab[x] or {}
   tab[x][y] = tab[x][y] or {} 
   tab[x][y][z] = data
end
local function decombine(str)
   return str:split(",")
end
greedy.Blocks = {}
function greedy.createblock(sx,ex,sz,ez,sy,ey,data)
    local l = math.sqrt((sx-ex)^2)
    local midpointx = (sx+ex )/2
    l += l ~= -1 and 1 or 0
    local w = math.sqrt((sz-ez)^2)
    local midpointz = (sz+ez )/2
    w += w ~= -1 and 1 or 0
    local h = math.sqrt((sy-ey)^2)
    local midpointy = (sy+ey )/2
    h += h ~= -1 and 1 or 0
    return {data = data ,startx = sx,endx = ex,startz = sz,endz = ez,starty = sy,endy = ey,h=h,l=l,w=w,real = Vector3.new(midpointx,midpointy,midpointz)},`{midpointx},{midpointy},{midpointz}`
end
function greedy.createblock2(startPos,endPos,data)
    local midpoint = (startPos+endPos)/2
    local dif = startPos-endPos
    local l = math.sqrt(dif.X^2)
    l += l ~= -1 and 1 or 0
    local w = math.sqrt(dif.Z^2)
    w += w ~= -1 and 1 or 0
    local h = math.sqrt(dif.Y^2)
    h += h ~= -1 and 1 or 0
    return {data = data ,startPos = startPos,endPos = endPos,size = Vector3.new(l,h,w),midPoint = midpoint},midpoint
end
function  greedy.meshtable(meshtable)
    local startx,endx,startz,endz,starty,endy
    local data = {}
    local checked = {}
    local old = 0
    local c = 0
    if next(meshtable) == nil then return{} end
    local unabletomeshblocks = {}
    for i,v in meshtable do
        old+=1
        local Vector = IndexUtils.to3D[i]
        local x,y,z = Vector.X,Vector.Y,Vector.Z
        if startx == nil then
            startx = Vector.X
            starty = Vector.Y
            startz = Vector.Z
            endx = startx
            endy = starty
            endz = startz
        end
        if x >=endx then
            endx = x
        end
        if z >=endz then
            endz = z
        end
        if y >=endy then
            endy = y
        end
        if x <=startx then
            startx = x
        end
        if z <=startz then
            startz = z
        end
        if y <=starty then
            starty = y
        end
        data[Vector] = v

    end
    local currentz = startz
    local currenty = starty
    local currentx = startx
    local ssx,ssz,ssy = startx,startz,starty
    local new,total = {},0
    local lastV = false
    local StartV = false
    local function compare(v1:Vector3,v2:Vector3)
            local d1 = data[v1]
            local d2 = data[v2]
            -- end
            if d1 and d2 then
                return d1 == d2
            end
            return true
    end
    while currentz <= endz+1 do
        while currentx <= endx+1 do
            while currenty <= endy+1 do
                local currentV = Vector3.new(currentx,currenty,currentz)
                if data[currentV] and not checked[currentV] and compare(lastV, currentV)  then
                    if not data[lastV]  then
                         StartV = currentV
                    end
                    checked[currentV] = true
                elseif (not data[currentV] or not compare(lastV, currentV))and data[StartV] and StartV and lastV then
                    local bData,index = greedy.createblock2(StartV,lastV,data[lastV])
                    new[index] = bData
                    if not compare(lastV,currentV) then
                        StartV = currentV
                    else
                        StartV = false
                    end
                end
                lastV = currentV
                currenty +=1
            end
            currenty = ssy 
            currentx+=1
        end
        currentx = ssx
        lastV = Vector3.new(lastV.X,lastV.Y,currentz)
        currentz+=1
    end
    local function dosmt(key,dir)
        local oVector = key
        local rVector = key
        local info = new[key]
        local StartVector,EndVector = info.startPos,info.endPos
        local Size = info.size -- lhw
        local involved = {key}
        local function move(goback)
            if dir == 'x' then
                rVector += Vector3.new(Size.X)*(goback and -1 or 1)
            elseif  dir == 'z' then
                rVector+= Vector3.new(0,0,Size.Z)*(goback and -1 or 1)
            elseif  dir == 'y' then
                rVector += Vector3.new(0,Size.Y,0)*(goback and -1 or 1)
            end
        end
        local currentdir = -1
        while true do
            move(currentdir ==-1 and true or nil)
            local c = new[rVector]
            if c and c.size == Size and c.data == info.data  then 
                if currentdir == -1 then
                    StartVector = c.startPos
                else
                    EndVector = c.endPos
                end
                table.insert(involved,rVector)
            elseif currentdir == -1 then
                currentdir = 1
                rVector = oVector
                continue
            else
                break
            end
        end
        return involved,greedy.createblock2(StartVector,EndVector,info.data)
    end
    local cc ={}
    for key,value in (table.clone(new)) do
        if not new[key] then continue end
        local inv,bData,newkey = dosmt(key,"x")
        cc[newkey] = bData
        for i,v in inv do
            new[v] = nil
        end
    end
    new = cc
    cc ={}
    for key,value in (table.clone(new)) do
        if not new[key] then continue end
        local inv,bData,newkey = dosmt(key,"z")
        cc[newkey] = bData
        for i,v in inv do
            new[v] = nil
        end
    end
    return cc
end
return greedy