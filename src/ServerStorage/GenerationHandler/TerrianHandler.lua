local ServerStorage = game:GetService("ServerStorage")
local settings = require(game.ReplicatedStorage.GameSettings)
local terrian = {}
local chunksize = settings.ChunkSize
local sizexn = chunksize.X-1
local GM = require(ServerStorage.Deepslate)
local mathutils = require(ServerStorage.Deepslate.math.Utils)
local chunk = require(game.ReplicatedStorage.Chunk)
local RandomState,MappedRouter,Visitor
local storage =GM.Storage
local BiomeHandler = require(script.Parent.BiomeHandler)
local SharedService = require(game.ServerStorage.ServerStuff.SharedService)
function terrian:Init(RS,MR,V)
    RandomState = RS
    MappedRouter = MR
end
local once = false 
local w = 4
local h = 8
local ysize =chunksize.Y
local xsizel = chunksize.X/4
local ysizel = chunksize.Y/h
local ysize2 = chunksize.Y/4
local farea = xsizel*ysizel
local function to1dLocal(x,y,z)
    return x + y * xsizel + z *farea+1
end
local function to1dLocalXZ(x,z)
    return x + z *xsizel + 1
end
local farea2 = xsizel*chunksize.Y/4
local function to1dLocalY4(x,y,z)
    return x + y * xsizel + z *farea2+1
end
terrian.to1d = to1dLocal
local baseheight = 0.25 ---.558
function terrian.ComputeBaseHeight(x,y,z)
    return MappedRouter.initialDensityWithoutJaggedness:compute(Vector3.new(x,y,z))
end
function terrian.ComputeChunk(cx,cz)
    debug.profilebegin("ComputeChunk")
    local data = {}
    local other = {}
    local ox,oz = settings.getoffset(cx,cz)
    local base 
    local biomes = {}
     local climate2d = {}
     local climate3d = {}
    local bi 
    for x = 0, chunksize.X-1,4 do
        local rx = ox +x
        for z = 0, chunksize.X-1,4  do
            local rz = oz +z
            for _,df in MappedRouter.xzOrder or {} do
                df:compute(Vector3.new(rx,0,rz))
            end
           local c,e,w = BiomeHandler.get2DNoiseValues(rx,rz)
           local lx,lz = x/4,z/4
          climate2d[to1dLocalXZ(lx,lz)] = Vector3.new(c,e,w) 
            local yidx = 8
            for y = 0,chunksize.Y-1,h do
                local ly = y/8
                -- if yidx == h  then
                -- yidx = 0
                local idx = to1dLocal(lx,ly,lz)--settings.to1D(x,y,z)--to1dLocal(x/4,y/4,z/4)
                data[idx] = MappedRouter.finalDensity:compute(Vector3.new(rx,y,rz))
                local temperature,humidity,depth = BiomeHandler.get3DNoiseValues(rx,y,rz)
               climate3d[idx] = Vector3.new(temperature,humidity,depth) 
               local biome = BiomeHandler.getBiomeFromParams(c,e,w,temperature,humidity,depth)
               biome = tostring(biome)
               if bi == nil then
                bi = biome
               elseif bi then
                if bi ~= biome then
                    bi = false
                end
               end
               biomes[idx] =biome
                -- end
                -- yidx += 4
            end
            if not base then
                for y= chunksize.Y-1,0,-2 do
                    if not base then
                        local y = y
                        local sd = terrian.ComputeBaseHeight(ox,y,oz)
                        base = baseheight<sd and y+5
                    else
                        break
                    end
                end
            end
        end
    end
    base = base or 60
    debug.profileend()
    return {data,base,bi or biomes,climate2d,climate3d}
end
local lerp2 = mathutils.lerp2
function terrian.LerpXZ2D(cx,cz,quadx,quadz)
    debug.profilebegin("lerping base")
	local current = (SharedService:Get(`{cx},{cz}`))
    local cs = current[2]
   -- local cc = current[2]
	local found = {}
	local t ={}
    local ccc = {}
	local function get(x,z,c)
		local str = `{x},{z}`
        if not found[str] then
            found[str] = SharedService:Get(str)
        end
        local ca = found[str]
		return  ca[2] 
	end
    local w = 8
	for qx =0,4-1 do
		local x = qx+4*quadx
		local xx = ((x % w + w) % w) / w
		for qz  =0,4-1 do
			local z = qz+4*quadz
			local zz = ((z % w + w) % w) / w
			local level00 = cs
            local level10 = get(cx+1,cz)
            local level01 = get(cx,cz+1)
            local level11 = get(cx+1,cz+1)
            local level = math.floor(lerp2(xx,zz,level00,level10,level01,level11))
            table.insert(t,Vector2int16.new(settings.to1DXZ(x,z),level))

		end
	end
    debug.profileend()
	return t,ccc
end
local lerp3 = mathutils.lerp3
local farea3 = (9)*(257) 
function to1Dstore(x,y,z)
    return x + y * 9 + z *farea3+1
end
function terrian.LerpFinalDXZ(cx,cz,quadx,quadz)
    debug.profilebegin("lerping final")
	local noise000,noise001,noise010,noise011,noise100,noise101,noise110,noise111
	local current = (SharedService:Get(`{cx},{cz}`)[1])
	local found = {}
	local t ={}
    local store = {}
    local preofx = {
        [0] = {
            [1] = `{cx+0},{cz+1}`
        },
        [1] = {
            [0] = `{cx+1},{cz+0}`,
            [1] = `{cx+1},{cz+1}`
        }
    }
	local function get(x,y,z)
        local abc = to1Dstore(x,y,z)
        if store[abc] then return store[abc] end 
		local id,ofx,ofz = GetData(x,y,z)
		if ofx ==0 and ofz ==0 then store[abc] = current[id] return current[id] end
		local str = preofx[ofx][ofz]
        if not found[str] then
            found[str] = SharedService:Get(str)[1]
        end
        local f =  found[str]
        store[abc] = f[id]
		return f[id]
	end
	local fy
	for qx =0,w-1 do
		local x = qx+4*quadx
		local xx = ((x % w + w) % w) / w
		for qz  =0,w-1 do
			local z = qz+4*quadz
			local zz = ((z % w + w) % w) / w
            
			for y =0,ysize-1 do
				local yy = ((y % h + h) % h) / h
                local firstY = math.floor(y / h) 
				if fy ~= firstY then
                    fy = firstY
                    noise000 = get(quadx,firstY,quadz)
					noise001 = get(quadx,firstY,quadz+1)
					noise010 = get(quadx,firstY+1,quadz)
					noise011 = get(quadx,firstY+1,quadz+1)
					noise100 = get(quadx+1,firstY,quadz)
					noise101 = get(quadx+1,firstY,quadz+1)
					noise110= get(quadx+1,firstY+1,quadz)
					noise111 = get(quadx+1,firstY+1,quadz+1)
                end
				local density =  lerp3(xx, yy, zz, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)
               -- local biomevalues = lerp3(xx,yy,zz,b000,b001,b010,b011,b100,b101,b110,b111)
                local a = settings.to1D(x,y,z)
				table.insert(t,Vector2.new(a,density))
              --  t2[a] = biomevalues
			end
		end
	end
    debug.profileend()
	return t
end
function terrian.LerpBiomes(cx,cz,height)
    debug.profilebegin("BIOME LERP")
    local ofx,ofz = settings.getoffset(cx,cz)
    local found = {}
    local biomekey = {}
    local current = SharedService:Get(`{cx},{cz}`)
    local function getnearby(lx,ly,lz)
        local id,ofx,ofz = GetData(lx,ly,lz)
		if ofx ==0 and ofz ==0 then return current[5][id] end
		local str = `{cx+ofx},{cz+ofz}`
        if not found[str] then
            found[str] = SharedService:Get(str)
        end
        local f =  found[str]
		return current[5][id]
    end
    local function getnearby2(lx,lz)
        local id,ofx,ofz = GetData2(lx,lz)
		if ofx ==0 and ofz ==0 then return current[4][id] end
		local str = `{cx+ofx},{cz+ofz}`
        if not found[str] then
            found[str] = SharedService:Get(str)
        end
        local f =  found[str]
		return f[4][id]
    end
    local function getbiome(lx,ly,lz)
        local id,ofx,ofz = GetData(lx,ly,lz)
		if ofx ==0 and ofz ==0 then return type(current[3]) == "table" and current[3][id] or current[3]end
		local str = `{cx+ofx},{cz+ofz}`
        if not found[str] then
            found[str] = SharedService:Get(str)
        end
        local f =  found[str][3]
		return type(f) == "table" and f[id] or f
    end
    local layouts = {}
    local function canLerp(lx,ly,lz)
        local m,l,r,t,b = getbiome(lx,ly,lz) , getbiome(lx+1,ly,lz),getbiome(lx,ly,lz+1), getbiome(lx+1,ly,lz+1) 
        return m ~=l~=r~=t~=b, `{m}{l}{r}{t}{b}`
    end
    local fx,fy,fz
    local noise000,noise001,noise010,noise011,noise100,noise101,noise110,noise111
    local newbiomes = {}
    
    for x =0,7 do
        local xx = ((x % w + w) % w) / w
        local firstX = math.floor(x / w) 
        for z =0,7 do
            local zz = ((z % w + w) % w) / w
            local firstZ = math.floor(z / w) 
            local level00 
            local level10
            local level01 
            local level11 
            local lerp 
            local function calcy(y)
                local yy = ((y % h + h) % h) / h
                local firstY = math.floor(y / h) 
                local t,str = canLerp(firstX,firstY,firstZ)
                if not t then return end 
                layouts[str] = layouts[str] or {}
                local b = layouts[str][settings.to1DXZ(x,z)] 
                if   b  then table.insert(newbiomes,Vector2int16.new(settings.to1D(x,firstY*8,z),b)) return end 
                if fx ~= firstX or fy ~= firstY or fz ~= fz then
                    fx = firstX
                    fy = firstY
                    fz = firstZ
                    noise000 = getnearby(firstX,firstY,firstZ)
                    noise001 = getnearby(firstX,firstY,firstZ+1)
                    --noise010 = getnearby(firstX,firstY+1,firstZ)
                   -- noise011 = getnearby(firstX,firstY+1,firstZ+1)
                    noise100 = getnearby(firstX+1,firstY,firstZ)
                    noise101 = getnearby(firstX+1,firstY,firstZ+1)
                  --  noise110 = getnearby(firstX+1,firstY+1,firstZ)
                   -- noise111 = getnearby(firstX+1,firstY+1,firstZ+1)
                end
                if not lerp then 
                    level00 = getnearby2(firstX,firstZ)
                    level10 = getnearby2(firstX+1,firstZ)

                    level01 = getnearby2(firstX,firstZ+1)

                    level11 = getnearby2(firstX+1,firstZ+1)
                    -- if not pcall(function()
                    --     lerp2(xx,zz,level00,level10,level01,level11) 
                    -- end) then
                    --     print(level00,level10,level01,level11)
                    --     print(firstX,firstZ)
                    --     print( GetData2(firstX,firstZ+1))
                    --     print(current[4])
                    -- end
                    lerp = lerp2(xx,zz,level00,level10,level01,level11) --Vector3.new( BiomeHandler.get2DNoiseValues(ofx+x,ofz+z))--lerp2(xx,zz,level00,level10,level01,level11) 
                end  -- cew
              --  local climate3dv =  lerp3(xx, yy, zz, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)--thd
              local climate3dv =  lerp2(xx, zz, noise000, noise100, noise001, noise101)--thd
                local biome = BiomeHandler.getBiomeFromParams(lerp.X,lerp.Y,lerp.Z,climate3dv.X,climate3dv.Y,climate3dv.Z)
                biome = tostring(biome)
                if not table.find(biomekey,biome) then
                    table.insert(biomekey,biome)
                end
                local idx = table.find(biomekey,biome)
                layouts[str][settings.to1DXZ(x,z)] = idx
                table.insert(newbiomes,Vector2int16.new(settings.to1D(x,firstY*8,z),idx))
            end
            calcy(height[settings.to1DXZ(x,z)]+4)
            for y =0,255,8 do
                calcy(y)
            end
        end
    end
    debug.profileend()
    return {newbiomes,biomekey}
end
local sizexnl = xsizel-1
function  GetData(x,y,z)
    local xx,zz = 0,0
    if y > ysizel-1 then
        y = ysizel-1
    end
    if x>sizexnl then
        xx += 1
        x = x-xsizel
    end
    if z>sizexnl then
        zz += 1
        z = z-xsizel
    end
    return to1dLocal(x,y,z),xx,zz
end
function  GetData2(x,z)
    local xx,zz = 0,0
    if x>sizexnl then
        xx += 1
        x = x-xsizel
    end
    if z>sizexnl then
        zz += 1
        z = z-xsizel
    end
    return to1dLocalXZ(x,z),xx,zz
end
function  terrian.InterpolateDensity(cx,cz,data)
    local offset ={
        { -- x == 1
        data[`{cx},{cz}`], -- z==1
        data[ `{cx},{cz+1}`], -- z==2
        },
        { -- x == 2
        data[ `{cx+1},{cz}`], -- z==1
        data[  `{cx+1},{cz+1}`], -- z==1
        },

    }
    local function getnearby(x,y,z)
        local xx,zz = 1,1
        x,y,z = x/4,y/h,z/4
        if y > ysizel-1 then
            y = ysizel-1
        end
        if x>sizexnl then
            xx += 1
            x = x-xsizel
        end
        if z>sizexnl then
            zz += 1
            z = z-xsizel
        end
        local loc = offset[xx][zz]
        return loc[to1dLocal(x,y,z)] 
    end
    local ndata = {}    
    local iter = 0
    local fx,fy,fz 
    local noise000
    local noise001
    local noise010
    local noise011
    local noise100
    local noise101
    local noise110
    local noise111
    for x = 0, chunksize.X-1 do
        local xx = ((x % w + w) % w) / w
        local firstX = math.floor(x / w) * w
        for z = 0, chunksize.X-1  do
            local zz = ((z % w + w) % w) / w
            local firstZ = math.floor(z / w) * w
            for y = 0,chunksize.Y-1 do
                iter +=1
                local yy = ((y % h + h) % h) / h
                local firstY = math.floor(y / h) * h
                if fx ~= firstX or fy ~= firstY or fz ~= fz then
                    fx = firstX
                    fy = firstY
                    fz = firstZ
                    noise000 = getnearby(firstX,firstY,firstZ)
                    noise001 = getnearby(firstX,firstY,firstZ+w)
                    noise010 = getnearby(firstX,firstY+h,firstZ)
                    noise011 = getnearby(firstX,firstY+h,firstZ+w)
                    noise100 = getnearby(firstX+w,firstY,firstZ)
                    noise101 = getnearby(firstX+w,firstY,firstZ+w)
                    noise110 = getnearby(firstX+w,firstY+h,firstZ)
                    noise111 = getnearby(firstX+w,firstY+h,firstZ+w)
                end
            --[[  if  not pcall(function()
                    mathutils.lerp3(xx, yy, zz, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)
                end) then
                    print(data,cx,cz)
                    print(firstX,
                    firstY,
                    firstZ)
                    print(to1dLocal((firstX+4)/4,(firstY+4)/4,(firstZ+4)/4))
                    print(noise000,
                    noise001,
                    noise010,
                    noise011,
                    noise100,
                    noise101,
                    noise110,
                    noise111)
                    error("a")
                end]]
                local density =  mathutils.lerp3(xx, yy, zz, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)
                ndata[settings.to1D(x,y,z)] = density>0 and true or false--density
            end
        end
        end
     return chunk:CompressVoxels(ndata,true) 
end




return terrian