local Tasks = {}
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local subChunkHelper = require(script.Parent.SubChunkHelper)
ResourceHandler.loadComponet("Blocks")
IndexUtils.preCompute(true)
local chunkData ={}
local Width,Height = GameSettings.getChunkSize()
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
function Tasks.setSubChunkData(chunk,data)
    chunkData[chunk] = data
end
local Greedy = require(script.Parent.GreedyMesh)
function Tasks.sampleSection(section,chunk)
    local b =subChunkHelper.sampleSection(chunkData[chunk], section,chunk)


    return b
end
function Tasks.cull(chunk,center,north,east,south,west,sections )
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
        local data = buffer.readu16(chunk or center, (id-1)*4)
        cache[id] = data
        return data
    end
    local function checkBlock(x,y,z,chunk)
        local id = to1D[x][y][z]
        return get(id,chunk or center) ~= 0
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
    local count = 1

    debug.profilebegin("cull")
    for x = 1,8 do
        for z = 1,8 do
            b1,b2,b3,b4 = unpack(GetBorders(x,z))
            for ly =0,31 do
                local val = buffer.readu8(sections, ly)
                if val == 0 then continue end 
                for oy = 0,7 do
                    local y = ly*8+oy+1
                    local idx = IndexUtils.to1D[x][y][z]
                    local v = get(idx, center)
                    if v == 0 then continue end 
                    local can,i = cull(x,y,z)
                    if not can then
                        loc[idx] = Vector3.new(v,i)
                    end
                end 
            end
        end
    end
    debug.profileend()
    debug.profilebegin("MeshBlocks")
    local meshed = Greedy.meshtable(loc)
    debug.profileend()
    return meshed
end
color = {
    Color3.new(0.466667, 1.000000, 0.447059),
    Color3.new(0.443137, 0.823529, 1.000000),
    Color3.new(0.949020, 0.976471, 1.000000),
    Color3.new(0.309804, 0.305882, 0.325490),
    Color3.new(1.000000, 0.992157, 0.490196)
}

return Tasks