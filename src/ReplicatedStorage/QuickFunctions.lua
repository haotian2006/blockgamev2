local qf = {}
local settings = require(game.ReplicatedStorage.GameSettings)
function  qf.to1DBlock(x,y,z)
    local dx,dy = settings.ChunkSize.X,settings.ChunkSize.Y
    return (z * dx * dy) + (y * dx) + x
end
function qf.to3DBlcok(index)
    local dx,dy = settings.ChunkSize.X,settings.ChunkSize.Y
    local z = math.floor(index / (dx * dy))
	index -= (z * dx * dy)
	local y = math.floor(index / dx)
	local x = index % dx
    return Vector3.new(x,y,z)
end
function  qf.to1DChunk(x,y)
    local dx = settings.GroupChunk
    return x+y*dx
end
function  qf.to2DChunk(index)
    local dx = settings.GroupChunk
	local y = index/dx
	local x = index%dx
    return Vector2.new(x,math.floor(y))
end
function  qf.ConvertString(str:string)
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