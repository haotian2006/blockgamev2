local Tasks = {}
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
IndexUtils.preCompute()

local Width,Height = GameSettings.getChunkSize()

local function CreateBorder(lx,lz)
    return {
        lx+1 >= Width,
        lx-1 <= -1,
        lz+1 >= Width ,
        lz-1 <= -1
    },`{lx+1 >= Width},{lx-1 <= -1},{lz+1 >= Width},{lz-1 <= -1}`
end
local borders = {}
do
    local temp = {}
    for x =0,Width-1 do
        for z = 0,Width-1 do
            local id = x + z *Width + 1
            local info,str = CreateBorder(x,z)
            borders[id] = temp[str] or info
            temp[str] = info
        end
    end
end
local function GetBorders(lx,lz)
    return borders[lx + lz *Width + 1]
end

local Greedy = require(script.Parent.GreedyMesh)
function Tasks.cull(chunk,center,north,east,south,west )
    local cache ={
        [center] = table.create(8*8*256),
        [north] = {},
        [east] = {},
        [south] = {},
        [west] = {},
    }
    local function get(id,chunk)
        local cache = cache[chunk]
        if cache[id] then return cache[id] end 
        local data = buffer.readi8(chunk or center, id-1)
        cache[id] = data
        return data
    end
    local function checkBlock(x,y,z,chunk)
        local id = IndexUtils.to1D[x][y][z]
        return get(id,chunk or center) == 1
    end
    local b1,b2,b3,b4
    local function cull(x,y,z)
        local num = 0
        if b1 then
            if checkBlock(0,y,z,north) then num +=1 end 
        else
            if checkBlock(x+1,y,z) then num +=1 end 
        end
        if b2 then
            if checkBlock(7,y,z,south) then num +=2 end 
        else
            if checkBlock(x-1,y,z) then num +=2 end 
        end
        if y ~= 255 and checkBlock(x,y+1,z) then num +=4 end 
        if y ~= 0 and checkBlock(x,y-1,z) then num +=8 end 
        if b3 then
            if checkBlock(x,y,0,east) then num +=16 end 
        else
            if checkBlock(x,y,z+1) then num +=16  end 
        end
        if b4 then
            if checkBlock(x,y,7,west) then num +=32 end 
        else
            if checkBlock(x,y,z-1) then num +=32  end 
        end
        return num == 63,num
    end
    local loc = {}
    local count = 1

    debug.profilebegin("cull")
    for x = 0,7 do
        for z = 0,7 do
            b1,b2,b3,b4 = unpack(GetBorders(x,z))
            for y = 0,255 do
                local idx = IndexUtils.to1D[x][y][z]
                if get(idx, center) == 0 then continue end 
                local can,i = cull(x,y,z)
                if not can then
                    loc[idx] = true
                end
            end
        end
    end
    debug.profileend()
    debug.profilebegin("MeshBlocks")
    local meshed = Greedy.meshtable(loc)
    debug.profileend()
    task.synchronize()
    debug.profilebegin("build")
    local model = Instance.new("Model")
    model.Name = "3213131213321"
    for key,data in meshed do
        local p = Instance.new("Part",model)
        p.Size = data.size*3
        p.Position = (data.midPoint+chunk*8)*3
        p.Anchored = true
    end
    model.Parent = workspace
    debug.profileend()
    --return loc
end


return Tasks