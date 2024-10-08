local Tasks = {}
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)

IndexUtils.preCompute(true)

local Width = GameSettings.getChunkSize()
local to1D = IndexUtils.to1D

local function CreateBorder(lx,lz)
    return {
        lx+1 >= Width+1,
        lx-1 <= 0,
        lz+1 >= Width +1,
        lz-1 <= 0,
    },`{lx+1 >= Width+1},{lx-1 <= 0},{lz+1 >= Width+1},{lz-1 <= 0}`
end


local borders = {}
local preComputedLoop = {}

do
    local temp = {}
    for x =1,Width do
        for z = 1,Width do
            local id = (x-1) + (z-1) *Width + 1
            local info,str = CreateBorder(x,z)
            borders[id] = temp[str] or info
            temp[str] = info
        end
    end 

end

local function GetBorders(lx,lz)
    return borders[(lx-1) + (lz-1) *Width + 1]
end

do
    for x = 1,8 do
        for z = 1,8 do
            preComputedLoop[Vector3.new(x,0,z)] = GetBorders(x,z)
        end
    end
end

function Tasks.cull(chunk,centerBlockData,center,north,east,south,west,sections )
    local function checkBlock(x,y,z,chunk)
        local id = to1D[x][y][z]
        return buffer.readu8(chunk or center, (id-1)) == 0
    end
    local b1,b2,b3,b4
    local function cull(x,y,z)
        local num = 0
        if b1 then
            if checkBlock(1,y,z,north) then num +=1 end 
        else
            if checkBlock(x+1,y,z) then num +=1 end 
        end
        if b2 then
            if checkBlock(8,y,z,south) then num +=2 end 
        else
            if checkBlock(x-1,y,z) then num +=2 end 
        end
        if y ~= 256 and checkBlock(x,y+1,z) then num +=4 end 
        if y ~= 1 and checkBlock(x,y-1,z) then num +=8 end 
        if b3 then
            if checkBlock(x,y,1,east) then num +=16 end 
        else
            if checkBlock(x,y,z+1) then num +=16  end 
        end 
        if b4 then
            if checkBlock(x,y,8,west) then num +=32 end 
        else
            if checkBlock(x,y,z-1) then num +=32  end 
        end
        return num == 63,num
    end
    local loc = {}

    debug.profilebegin("cull")
    for pos,borders in preComputedLoop do
        local x,z = pos.X,pos.Z
        b1,b2,b3,b4 = unpack(borders)
        for ly =0,31 do
            local val = buffer.readu8(sections, ly)
            if val == 0 then continue end 
            for oy = 0,7 do
                local y = ly*8+oy+1
                local idx = IndexUtils.to1D[x][y][z]
                local v = buffer.readu8( center, (idx-1)) 
                if v ~= 0 then continue end 
                local can,i = cull(x,y,z)
                if not can then
                    local real = buffer.readu32(centerBlockData, (idx-1)*4)
                    loc[idx] = Vector3.new(real,i)
                end
            end
        end
    end
    debug.profileend()
    return loc
end


return Tasks