
local self = {}
local f,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local settings = require(game.ReplicatedStorage.GameSettings)
local res = require(game.ReplicatedStorage.ResourceHandler)
local datahandler = require(game.ReplicatedStorage.DataHandler)
local chsiz:Vector2 = settings.ChunkSize
local bs = require(game.ReplicatedStorage.Libarys.Store)
local function CreateBorder(lx,lz)
    return {
        lx+1 >= chsiz.X,
        lx-1 <= -1,
        lz+1 >= chsiz.X ,
        lz-1 <= -1
    },`{lx+1 >= chsiz.X},{lx-1 <= -1},{lz+1 >= chsiz.X},{lz-1 <= -1}`
end
local borders = {}
local chx = settings.ChunkSize.X
local chy = settings.ChunkSize.Y
local nchx = chx-1

do
    local temp = {}
    for x =0,nchx do
        for z = 0,nchx do
            local id = x + z *chx + 1
            local info,str = CreateBorder(x,z)
            borders[id] = temp[str] or info
            temp[str] = info
        end
    end
    temp = nil
end
local function GetBorders(lx,lz)
    return borders[lx + lz *chx + 1]
end
local to1d = settings.to1D
function self.HideBlocks(chunks)
    local new = table.create(256*8*8)
    local i = 0
    local current = chunks[1]
    local function checkblockinch(wt,x,y,z)
        local combined = to1d(x,y,z)
        local a = chunks[wt][combined]
        local transparency = false
        if not a or not tostring(a) then return false end 
        local d = a:getData()
        local cb = d.Data
        if  d and cb then
            transparency = cb.Transparency
            if transparency and transparency ~= 0 then
            else
                transparency = false
            end 
        end
        if transparency then
            a = false
        end
        return a 
    end
    local b1,b2,b3,b4
    local function checksurroundingblocks(x,y,z)
        local sides = {}
        --/AirBlocks|t%
        local num = 0
        if (not b1 and checkblockinch(1,x+1,y,z)) or (b1 and checkblockinch(2,0,y,z))  then
            num += 1
        end 
        if (not b2 and checkblockinch(1,x-1,y,z)) or (b2 and checkblockinch(3,7,y,z))  then
            num += 2
        end
        if (checkblockinch(1,x,y+1,z)) then
            num += 4
        end
        if (checkblockinch(1,x,y-1,z))  then
            num += 8
        end
        if (not b3 and checkblockinch(1,x,y,z+1)) or (b3 and checkblockinch(4,x,y,0))  then
            num += 16
        end
        if (not b4 and checkblockinch(1,x,y,z-1)) or (b4 and checkblockinch(5,x,y,7))  then
            num += 32
         end
         return num == 63,num
    end
    for x = 0,nchx do
        for z = 0,nchx do
             b1,b2,b3,b4 = unpack(GetBorders(x,z))
            for y = 0,chy-1 do
                local idx = to1d(x,y,z)
                local data = current[idx] 
                if not data or not tostring(data) then continue end
                i+=1
              --  if i%1500 == 0 then task.wait() end 
                local cann,newstr = checksurroundingblocks(x,y,z)
                if not cann then
                    local newd = tostring(data)..","..newstr
                    new[idx] = newd
                else
                    new[idx] = nil
                end
            end
        end
    end
    return new
end
return self 
--[[ local function GetBorders(lx,lz)
    if (lx > 0 and lx < nchx) and (lz > 0 and lz < nchx) then 
        return borders[1]
    elseif lx == 0 and lz == 0 then
        return borders[2]
    elseif lx == nchx and lz == nchx then
        return borders[3]
    elseif lx == nchx and lz == 0 then
        return borders[4]
    elseif lx == 0 and lz == nchx then
        return borders[5]
    elseif lx == 0 and (lz > 0 and lz < nchx) then
        return borders[6]
    elseif (lx > 0 and lx < nchx) and lz == 0 then
        return borders[7]
    elseif lx == 7 and (lz > 0 and lz < nchx) then
        return borders[8]
    elseif (lx > 0 and lx < nchx) and lz == 7 then
        return borders[9]
    end
end
]]