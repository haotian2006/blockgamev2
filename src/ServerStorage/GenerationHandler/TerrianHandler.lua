local ServerStorage = game:GetService("ServerStorage")
local settings = require(game.ReplicatedStorage.GameSettings)
local terrian = {}
local chunksize = settings.ChunkSize
local sizexn = chunksize.X-1
local GM = require(ServerStorage.GenerationManager)
local mathutils = require(ServerStorage.GenerationManager.math.Utils)
local RandomState,MappedRouter,finalDensityWithoutInterpolation,Visitor
local storage =GM.Storage
function terrian:Init(RS,MR,V)
    RandomState = RS
    MappedRouter = MR
    finalDensityWithoutInterpolation = MR.finalDensityWithoutInterpolation
    Visitor = V
end
local once = false 
local xsizel = chunksize.X/4
local ysizel = chunksize.Y/4
local farea = xsizel*ysizel
local function to1dLocal(x,y,z)
    return x + y * xsizel + z *farea+1
end
function terrian.ComputeChunk(cx,cz)
    do
      --  return {}
    end
    local data = {}
    local ox,oz = settings.getoffset(cx,cz)
    for x = 0, chunksize.X-1,4 do
        for z = 0, chunksize.X-1,4  do
            for _,df in MappedRouter.xzOrder or {} do
                df:compute(Vector3.new(x+ox,0,z+oz))
            end
            for y = 0,chunksize.Y-1,4 do
                local idx = settings.to1D(x,y,z)--to1dLocal(x/4,y/4,z/4)
                data[idx] = MappedRouter.initalDensity:compute(Vector3.new(x+ox,y,z+oz))
                data[idx] =  data[idx] >0 and true or false
            end
        end
    end
    return data
end
local sizexnl = xsizel-1
local function getnearby(x,y,z,cx,cz,data)
    x,y,z = x/4,y/4,z/4
	if x <0 then
		x = xsizel-x
		cx -= 1
	elseif x>sizexnl then
		cx += 1
		x = x-xsizel
	end
	if z <0 then
		z = xsizel-z
		cz -= 1
	elseif z>sizexnl then
		cz += 1
		z = z-xsizel
	end
	return data[cx..','..cz][to1dLocal(x,y,z)] 
end
local w = 8
local h = 4
function  terrian.InterpolateDensity(cx,cz,data)
    local ndata = {}
    for x = 0, chunksize.X-1 do
        for z = 0, chunksize.X-1  do
            for y = chunksize.Y-1,0,-1 do
                local xx = ((x % w + w) % w) / w
                local yy = ((y % h + h) % h) / h
                local zz = ((z % w + w) % w) / w
                
                local firstX = math.floor(x / w) * w
                local firstY = math.floor(y / h) * h
                local firstZ = math.floor(z / w) * w
                local noise000 = getnearby(firstX,firstY,firstZ,cx,cz,data)
                local noise001 = getnearby(firstX,firstY,firstZ+w,cx,cz,data)
                local noise010 = getnearby(firstX,firstY+h,firstZ,cx,cz,data)
                local noise011 = getnearby(firstX,firstY+h,firstZ+w,cx,cz,data)
                local noise100 = getnearby(firstX+w,firstY,firstZ,cx,cz,data)
                local noise101 = getnearby(firstX+w,firstY,firstZ+w,cx,cz,data)
                local noise110 = getnearby(firstX+w,firstY+h,firstZ,cx,cz,data)
                local noise111 = getnearby(firstX+w,firstY+h,firstZ+w,cx,cz,data)
                --[[
                if  not pcall(function()
                    mathutils.lerp3(xx, yy, zz, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)
                end) then
                    print(data,cx,cz)
                    print(firstX,
                    firstY,
                    firstZ)
                    print(to1dLocal((firstX+8)/4,firstY/4,firstZ/4))
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
     return ndata
end
return terrian