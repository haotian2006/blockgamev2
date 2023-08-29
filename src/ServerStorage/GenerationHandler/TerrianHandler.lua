local ServerStorage = game:GetService("ServerStorage")
local settings = require(game.ReplicatedStorage.GameSettings)
local terrian = {}
local chunksize = settings.ChunkSize
local sizexn = chunksize.X-1
local GM = require(ServerStorage.Deepslate)
local mathutils = require(ServerStorage.Deepslate.math.Utils)
local chunk = require(game.ReplicatedStorage.Chunk)
local RandomState,MappedRouter,finalDensityWithoutInterpolation,Visitor
local storage =GM.Storage
local BiomeHandler = require(script.Parent.BiomeHandler)
function terrian:Init(RS,MR,V)
    RandomState = RS
    MappedRouter = MR
    finalDensityWithoutInterpolation = MR.finalDensityWithoutInterpolation
    Visitor = V
end
local once = false 
local w = 4
local h = 8
local xsizel = chunksize.X/4
local ysizel = chunksize.Y/h
local farea = xsizel*ysizel
local function to1dLocal(x,y,z)
    return x + y * xsizel + z *farea+1
end
local farea2 = xsizel*chunksize.Y/4
local function to1dLocalY4(x,y,z)
    return x + y * xsizel + z *farea2+1
end
function terrian.ComputeChunk(cx,cz)
    local data = {}
    local biomedata = {}
    local ox,oz = settings.getoffset(cx,cz)
    for x = 0, chunksize.X-1,4 do
        local rx = ox +x
        for z = 0, chunksize.X-1,4  do
            local rz = oz +z
            for _,df in MappedRouter.xzOrder or {} do
                df:compute(Vector3.new(rx,0,rz))
            end
            local continents,erosion,weirdness = BiomeHandler.get2DNoiseValues(rx,rz)
            local yidx = 8
            for y = 0,chunksize.Y-1,4 do
                local lx,ly,lz = x/4,y/4,z/4
                if yidx == h  then
                yidx = 0
                local idx = to1dLocal(lx,ly/2,lz)--settings.to1D(x,y,z)--to1dLocal(x/4,y/4,z/4)
                data[idx] = MappedRouter.finalDensity:compute(Vector3.new(rx,y,rz))
                end
                yidx += 4
               
                local temperature,humidity,depth = BiomeHandler.get3DNoiseValues(rx,y,rz)
                local bd = BiomeHandler.newTarget(temperature,humidity,continents,erosion,depth,weirdness)
                biomedata[to1dLocalY4(lx,ly,lz)] = bd
            end
        end
    end
    return {data,biomedata}
end
local sizexnl = xsizel-1
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
                if iter%1500 ==0 then
                    task.wait()
                end
            end
        end
        end
     return chunk:CompressVoxels(ndata,true) 
end




return terrian