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
local blockd = settings.GridSize
local chunkd = settings.ChunkSize.X
-- Real : Real Position 
-- Grid : Real/BlockSize
-- Chunk : Uses Grid
-- CHGrid : Basicly the the Real coord inside the chunk EX: 17 --> 1

--other
function qf.SortTables(position,tables)
    position = Vector2.new(position.X,position.Z)
    local new = {}
    for i,v in tables do
        if type(i) == "number" then i = v end
        local cx,cz = unpack(string.split(i,","))
        local vp = qf.convertchgridtoreal(cx,cz,gridS,0,gridS)
        vp = Vector2.new(vp.X,vp.Z)
        table.insert(new,{i,(position-vp).Magnitude})
    end
    table.sort(new,function(a,b)
        return a[2] < b[2]
    end)
    return new
end
function qf.tonumbertableindex(tabl)
    local tt = {}
    for i,v in tabl do
        tt[tonumber(i)] = v
    end
    return tt
end
function qf.divide(original,times,destroy)
	local tables = {}
	for i =1,times do
		table.insert(tables,{})
	end
	local length = 0
	for i,v in pairs(original)do
		length +=1
		for t =times,1,-1 do
			if length%t ==0 then
				tables[t][i] = v
				break
			end
		end
		if  destroy then
			original[i] = nil
		end
	end
	return tables
end
function qf.EditVector3(vector3:Vector3,position:number,Changeto:number):Vector3
   -- position = position:lower()
    if position == 'x' then
        return Vector3.new(Changeto,vector3.Y,vector3.Z)
    elseif position =='y' then
        return Vector3.new(vector3.X,Changeto,vector3.Z)
    elseif position == 'z' then
        return Vector3.new(vector3.X,vector3.Y,Changeto)
    end
    return vector3
end
--block/chunk
function qf.GetChunkfromReal(x,y,z,blockinstead)
    if not blockinstead then
        x,y,z = qf.GetBlockCoordsFromReal(x,y,z)
    end
	local cx =	tonumber(math.floor((x)/chunkd))
	local cz= 	tonumber(math.floor((z)/chunkd))
	return cx,cz
end
function qf.convertchgridtoreal(cx,cz,x,y,z,toblockinstead):Vector3
    do
        return Vector3.new((x+settings.ChunkSize.X*cx),y,(z+settings.ChunkSize.X*cz)) *(not toblockinstead and settings.GridSize or 1)
    end
    local dirx,dirz =1,1
    if cx < 0 then x+=1 dirx = -1 cx-=cx*2+1 end if cz < 0 then z+=1 dirz = -1 cz-=cz*2+1 end
    return Vector3.new((x+settings.ChunkSize.X*cx)*dirx,y,(z+settings.ChunkSize.X*cz)*dirz) *settings.GridSize
end
function qf.GetBlockCoordsFromReal(x,y,z)
	local x = math.floor((0 + x)/blockd)
	local z = math.floor((0 + z)/blockd)
	local y = math.floor((0 + y)/blockd)
	return x,y,z
end
function qf.GetSurroundingChunk(cx,cz,render)
	local coords ={cx..","..cz}
	for i = 1,render,1 do
		for x = cx-i,cx+i do
			for z = cz-i,cz+i do
				local combined = x..","..z
				if not table.find(coords,combined) then
					table.insert(coords,combined)
				end
			end
		end
	end
	return coords
end
--Converting Data types
function  qf.Realto1DBlock(x,y,z,fromblockinstead):number
    --if x < 0 then x *=-1 x -=1 end if y < 0 then y *=-1 y -=1  end if z < 0 then z *=-1 z -=1 end
    local dx,dy = settings.ChunkSize.X,settings.ChunkSize.Y
    if not fromblockinstead then
        x *=settings.GridSize y*=settings.GridSize z*=settings.GridSize
    end
    x,y,z = x%dx,y%dy,z%dx
    return (z * dx * dy) + (y * dx) + x +1
end
function qf.to3DBlock(index):Vector3
    index = tonumber(index)-1
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
        return Vector3.new((x*settings.GridSize+settings.ChunkSize.X*cx)*dirx,y*gridS,(z*settings.GridSize+settings.ChunkSize.X*cz)*dirz) 
    end
end
function qf.cbt(From,To,...) --ConvertBlockType
    From = From:lower()
    To = To:lower()
    local x,y,z,z2,z3
    local x = ...
    if From == "grid" or  From == "real" or  From == "chgrid" or From == "1d" then
         x,y,z,z2,z3= unpack({...})
    end
    if From == "real" and To == "grid" then
        return Vector3.new(qf.GetBlockCoordsFromReal(x,y,z))
    elseif From == "grid" and To == "real" then
        return Vector3.new(x*settings.GridSize,y*settings.GridSize,z*settings.GridSize)
    elseif From == "real" and To == "1d" then
        return qf.Realto1DBlock(x,y,z)
    elseif From == "grid" and To == "1d" then
        return qf.Realto1DBlock(x,y,z,true)
    elseif From == "1d" and To == "grid" then
        return qf.from1DToReal(x,y,z,true)--x == cx,y == cz z == index
    elseif From == "1d" and To == "real" then
        return qf.from1DToReal(x,y,z)
    elseif From == "1d" and To == "chgrid" then
        return qf.to3DBlock(x)
    elseif From == "chgrid" and To == "grid" then
        return qf.convertchgridtoreal(x,y,z,z2,z3,true)
    elseif From == "chgrid" and To == "real" then
        return qf.convertchgridtoreal(x,y,z,z2,z3)
    elseif From == "grid" and To == "chgrid" then
        return Vector3.new(x%chunkS.X,y,z%chunkS.X)
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
    elseif typea == "vector3" or typea == "cframe" or value["X"] then
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
function qf.cv2type(typeto,...)-- ConvertVector2Type
    local typeto = string.lower(typeto)
    local x,y
    local typea = typeof(...)
    typea = string.lower(typea)
    local checkfortup = {...}
    local value = ...
    if  checkfortup[2] then
        x,y = ...
    elseif typea == "string" then
        x,y = unpack(string.split(value,","))
    elseif typea == "vector3" or typea == "cframe" or value["X"] then
        x,y = value.X,value.Y
    elseif typea == "table" then
        x,y = unpack(value)
    end
    if not x or not y then return end 
    x,y = tonumber(x),tonumber(y)
    local ret
    if typeto == "string" then
        ret = x..","..y
    elseif typeto == "table" then
        ret = {x,y}
     elseif typeto =="vector2" then
        ret = Vector3.new(x,y)
	elseif typeto =="cframe" then
		ret = CFrame.new(x,y)
	elseif typeto == "tuple" then
		return x,y
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
function qf.GridIsInChunk(cx,cz,x,y,z,UseRealInstead)
    if false and UseRealInstead then
        x,y,z = qf.cv3type("tuple",qf.cbt("real","grid",x,y,z))
    end
    local dx,dz = math.sign(cx),math.sign(cz)
    dx = dx == 0 and 1 or dx dz = dz == 0 and 1 or dz
    local sx,ex = 0,chunkS.X-1 if dx == -1 then sx = -1 ex = -chunkS.X cx+=1 end
    local sz,ez = 0,chunkS.X-1 if dz == -1 then sz = -1 ez = -chunkS.X cz+=1 end
    sx,ex = sx+cx*chunkS.X,ex+cx*chunkS.X
    sz,ez = sz+cz*chunkS.X,ez+cz*chunkS.X
    if UseRealInstead then print(sx,ex,sz,ez) end
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
function qf.combinetostring(...)
    local c = ""
    local a =  {...}
    for i,v in a do
        c ..=v
        if i ~= #a then c ..=',' end 
    end
    return c
end
--Compression
--{a = {b = {},c = 1}}
-- t%a = {}
function qf.ConvertSubTablesToStr(tab:table):string
    local str = ""
    for i,v in tab do
        if type(v) == "table" then
            
        end
    end
end
function qf.ConvertString(str:string)
    local Sign,strr = unpack(str:split('%'))
    if not strr then strr = Sign Sign = "s" end
    if Sign == "s" then
        return tostring(strr)
    elseif Sign == "t"  then
        if strr:match("=") then
            local tablea = {}
            for i,v in strr:split(',') do
                local index,value = unpack(v:split("="))
                if not value then
                    value = index
                    index = i
                end
                tablea[index] = value
            end
            return tablea
        else
            return (strr == '' and {}) or strr:split(',')
        end
    elseif Sign == "n"  then
        return tonumber(strr)
    elseif Sign == "v3" then
        local c = strr:split(',')
        return Vector3.new(c[1],c[2],c[3])
    else
        warn("Sign",Sign,"Is not a valid Sign")
    end
    return strr
end
function qf.CompressBlockData(data:table)
    local currentcompressed = ""
    for key,value in data do
        local typea = typeof(value)
        currentcompressed..= key.."|"
        local valuestr = ""
        if typea =="string" then
            valuestr..='s%'..value
        elseif typea == "number" then
            valuestr..='n%'..value
        elseif typea == "table" then
            valuestr..='t%'
            for i,v in value do
                if type(i) ~= "number" then
                    valuestr..=i..'='
                end
                valuestr..=v
                if next(value,i) then
                    valuestr..=","
                end
            end
        elseif typea == "Vector3" then
            valuestr..='v3%'..value.X..','..value.Y..','..value.Z
        end
        currentcompressed..=valuestr
        if next(data,key) then 
            currentcompressed..="/"
        end
    end
    return currentcompressed
end
function qf.DecompressBlockData(data:string,specificitems:table|string):table|ValueBase
    if type(data) ~= "string" then return data end  
    --EX: 'Name|s%Cubic:dirt/Orientation|t%0,0,0/Position|0,0,0'
    --(s) = string, (t) = table, (n) = number ,(v3) = vector3
    -- (/) is like a comma (|) is the equal key in index = value (%) determines the type of the value, default is string
    local is1 = false local spi = nil if type(specificitems) == "string" then spi = {} table.insert(spi,specificitems) is1 = true
    else spi = specificitems end if spi then local spi2 ={} for i,v in spi do spi2[v] = i end spi = spi2 end
    if not data then warn("There Is No Data To Convert") return end  local seperated = data:split('/') local newdata = {}
    for i,v in seperated do local index,value = unpack(v:split('|')) if not value then value = index index = #newdata+1 end
        if spi and not spi[index] then continue end if spi and next(spi) == nil  then break end
        newdata[index] = qf.ConvertString(value) if spi then spi[index] = nil end 
    end
    return is1 and newdata[next(newdata)] or newdata
end
return qf 