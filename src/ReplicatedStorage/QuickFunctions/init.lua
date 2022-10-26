local qf = {}
local found,settings = pcall(require,game.ReplicatedStorage.GameSettings)
local otherlibs
function qf.ADDSETTINGS(libs)
    settings = libs.GameSettings
    otherlibs = libs
end
repeat
    task.wait()
until settings
local gridS = settings.GridSize
local chunkS = settings.ChunkSize
local blockmuti = 1/settings.GridSize
local chunkmuti = 1/settings.ChunkSize.X
-- Real : Real Position 
-- Grid : Real/BlockSize
-- Chunk : Uses Grid
-- CHGrid : Basicly the the Real coord inside the chunk EX: 17 --> 1
function  qf.Realto1DBlock(x,y,z):number
    if x < 0 then x *=-1 x -=1 end if y < 0 then y *=-1 y -=1  end if z < 0 then z *=-1 z -=1 end
    local dx,dy = settings.ChunkSize.X,settings.ChunkSize.Y
    x,y,z = x%dx,y%dy,z%dx
    return (z * dx * dy) + (y * dx) + x
end
function qf.to3DBlock(index):Vector3
    local dx,dy = settings.ChunkSize.X,settings.ChunkSize.Y
    local z = math.floor(index / (dx * dy))
	index -= (z * dx * dy)
	local y = math.floor(index / dx)
	local x = index % dx
    return Vector3.new(x,y,z)
end
function qf.from1DToReal(cx,cz,index,toblockinstead)
    local coord = qf.to3DBlock(index) local x,y,z = coord.X,coord.Y,coord.Z
    local dirx,dirz =1,1
    do
        return Vector3.new((x+settings.ChunkSize.X*cx),y,(z+settings.ChunkSize.X*cz)) *(not toblockinstead and settings.GridSize or 1)
    end
    if cx < 0 then x+=1 dirx = -1 cx-=cx*2+1 end if cz < 0 then z+=1 dirz = -1 cz-=cz*2+1 end
    if toblockinstead then
        return Vector3.new((x+settings.ChunkSize.X*cx)*dirx,y,(z+settings.ChunkSize.X*cz)*dirz)
    else
        return Vector3.new((x*settings.GridSize+settings.ChunkSize.X*cx)*dirx,y*4,(z*settings.GridSize+settings.ChunkSize.X*cz)*dirz) 
    end
end
function qf.cbt(From,To,...) --ConvertBlockType
    From = From:lower()
    To = To:lower()
    local x,y,z
    if From == "grid" or  From == "real" or  From == "chgrid" or From == "1d" then
         x,y,z = qf.CV3Type("tuple",...)
    end
    if From == "real" and To == "grid" then
        return Vector3.new(qf.GetBlockCoordsFromReal(x,y,z))
    elseif From == "grid" and To == "real" then
        return Vector3.new(x*settings.GridSize,y*settings.GridSize,z*settings.GridSize)
    elseif From == "real" and To == "1d" then
        return qf.Realto1DBlock(x,y,z)
    elseif From == "grid" and To == "1d" then
        return qf.Realto1DBlock(x*settings.GridSize,y*settings.GridSize,z*settings.GridSize)
    elseif From == "1d" and To == "block" then
        return qf.from1DToReal(x,y,z,true)
    elseif From == "1d" and To == "Real" then
        return qf.from1DToReal(x,y,z)
    end
end
function qf.cv3type(typeto,...)-- ConvertVector3Type
    local typeto = string.lower(typeto)
    local x,y,z 
    local typea = typeof(...)
    typea = string.lower(typea)
    local checkfortup = {...}
    local value = ...
    if  checkfortup[3] then
        x,y,z  = ...
    elseif typea == "string" then
        x,y,z = unpack(string.split(value,","))
    elseif typea == "vector3" or typea == "cframe" or value.X then
        x,y,z = value.X,value.Y,value.Z
    elseif typea == "table" then
        x,y,z = unpack(value)
    end
    if not x or not y or not z then return end 
    x,y,z = tonumber(x),tonumber(y),tonumber(z)
    local ret
    if typeto == "string" then
        ret = x..","..y..","..z
    elseif typeto == "table" then
        ret = {x,y,z}
     elseif typeto =="vector3" then
        ret = Vector3.new(x,y,z)
	elseif typeto =="cframe" then
		ret = CFrame.new(x,y,z)
	elseif typeto == "tuple" then
		return x,y,z
    end
    return ret
end
function qf.to1DChunk(x,y)
    local dx = settings.GroupChunk
    return x+y*dx
end
function qf.to2DChunk(index)
    local dx = settings.GroupChunk local y = index/dx local x = index%dx
    return Vector2.new(x,math.floor(y))
end
function qf.GridIsInChunk(cx,cz,x,y,z)
    local dx,dz = math.sign(cx),math.sign(cz)
    dx = dx == 0 and 1 or dx dz = dz == 0 and 1 or dz
    local sx,ex = 0,15 if dx == -1 then sx = -1 ex = -16 cx+=1 end
    local sz,ez = 0,15 if dz == -1 then sz = -1 ez = -16 cz+=1 end
    sx,ex = sx+cx*chunkS.X,ex+cx*chunkS.X
    sz,ez = sz+cz*chunkS.X,ez+cz*chunkS.X
    local flagx,flagz 
    if dx == -1 then
        flagx = sx>=x and ex<= x
    else
        flagx = ex >= x and sx <= x
    end
    if dz == -1 then
        flagz = sz>=z and ez<= z
    else
        flagz = ez >= z and sz <= z
    end
    return flagx and flagz
end
function qf.ConvertString(str:string)
    local Sign,strr = unpack(str:split('%'))
    if not strr then strr = Sign Sign = "s" end
    if Sign == "s" then
        return tostring(strr)
    elseif Sign == "t"  then
        return strr:split(',')
    elseif Sign == "n"  then
        return tonumber(strr)
    else
        warn("Sign",Sign,"Is not a valid Sign")
    end
    return strr
end
function qf.convertchgridtoreal(cx,cz,x,y,z)
    do
        return Vector3.new((x+settings.ChunkSize.X*cx),y,(z+settings.ChunkSize.X*cz)) *settings.GridSize
    end
    local dirx,dirz =1,1
    if cx < 0 then x+=1 dirx = -1 cx-=cx*2+1 end if cz < 0 then z+=1 dirz = -1 cz-=cz*2+1 end
    return Vector3.new((x+settings.ChunkSize.X*cx)*dirx,y,(z+settings.ChunkSize.X*cz)*dirz) *settings.GridSize
end
function qf.xzcorners(x,y)
	local cx,cz = tonumber(x),tonumber(y)
	local coord0chunkoffset =  Vector3.new(cx*4*16,0,cz*4*16)
	local coord0chunk = Vector3.new(0,0,0) + coord0chunkoffset
	local Cornerx,Cornerz =Vector2.new(-32+cx*64,-32+cz*64) ,Vector2.new(28+cx*64,28+cz*64)
	local pos = {}
	for x = Cornerx.X, Cornerz.X,4 do
		for z = Cornerx.Y,Cornerz.Y,4 do
			table.insert(pos,x.."x"..z)
		end
	end
	return pos
end
function qf.GetBlockCoordsFromReal(x,y,z)
	local x = math.floor((0 + x)*blockmuti)
	local z = math.floor((0 + z)*blockmuti)
	local y = math.floor((0 + y)*blockmuti)
	return x,y,z
end
function qf.GetChunkfromReal(x,y,z)
    x,y,z = qf.GetBlockCoordsFromReal(x,y,z)
	local cx =	tonumber(math.floor((x-0)*chunkmuti))
	local cz= 	tonumber(math.floor((z-0)*chunkmuti))
	return cx,cz
end

function qf.CompressBlockData(data:table)
    local currentcompressed = ""
    for key,value in data do
        local typea = type(value)
        currentcompressed..= key.."|"
        local valuestr = ""
        if typea =="string" then
            valuestr..='s%'..value
        elseif typea == "number" then
            valuestr..='n%'..value
        elseif typea == "table" then
            valuestr..='t%'
            for i,v in value do
                valuestr..=v
                if next(value,i) then
                    valuestr..=","
                end
            end
        end
        currentcompressed..=valuestr
        if next(data,key) then 
            currentcompressed..="/"
        end
    end
    return currentcompressed
end
function qf.DecompressBlockData(data:string,specificitems:table|string)
    --EX: 'Name|s%Cubic:dirt/Orientation|t%0,0,0/Position|0,0,0'
    --(s) = string, (t) = table, (n) = number 
    -- (/) is like a comma (|) is the equal key in index = value (%) determines the type of the value, default is string
    local is1 = false local spi = nil if type(specificitems) == "string" then spi = {}table.insert(spi,specificitems) is1 = true
    else spi = specificitems end if spi then local spi2 ={} for i,v in spi do spi2[v] = i end spi = spi2 end
    if not data then warn("There Is No Data To Convert") return end
    local seperated = data:split('/') local newdata = {}
    for i,v in ipairs(seperated) do
        local index,value = unpack(v:split('|'))
        if not value then value = index index = #newdata+1 end
        if spi and not spi[index] then continue end
        if spi and next(spi) == nil  then break end
        newdata[index] = qf.ConvertString(value)
        if spi then spi[index] = nil end
    end
    return is1 and newdata[next(newdata)] or newdata
end
return qf 