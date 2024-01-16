local Carver = {}
local Generator = game.ServerStorage.core.Chunk.Generator
local Storage = require(Generator.ChunkDataLocal)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local ConverstionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local to1d = IndexUtils.to1D
local gridtoChunkandL = ConverstionUtils.gridToLocalAndChunk

local spherePrecomputed = {}

function Carver.getCoordData(x,y,z)
    local cx,cz = (x+0.5)//8, (z+0.5)//8
    local lx,ly,lz = x%8,y,z%8
    return cx,cz,lx,ly,lz
end

function Carver.getChunkData(chunk)
    return Storage.get(chunk)
end

function Carver.checkBounds(lx,ly,lz)
    if ly >=255 or ly<0 then
        return 2
    end
    return (lx <= 7 and lx >=0 and lz <= 7 and lz >=0) and 1 or false 
end

local function precomputeSphere(radius)
    if  spherePrecomputed[radius] then return spherePrecomputed[radius] end 
    local t = {}
    spherePrecomputed[radius] = t
    local c = 0
    for x = -radius,radius do
        for y = -radius,radius do
            for z = -radius,radius do
                if x*x + y*y +z*z >radius*radius-.1 then continue end 
                c+=1
                t[c] = Vector3.new(x,y,z)
            end
        end
    end 
    return t
end

function Carver.getSphere(radius)
    return precomputeSphere(radius)
end
function Carver.sphere(startX,y,startZ,Block,radius,useU16,Checked)
    local sphere = precomputeSphere(radius)
    local writter = useU16 and buffer.writeu16 or buffer.writeu32
    local mul = useU16 and 2 or 4
    local Center = Vector3.new(startX,y,startZ)

    local Lcx,Lcz = gridtoChunkandL.gridToLocalAndChunk(startX,y,startZ)
    local currentBuffer = Storage.rawGetOrCreate(Vector3.new(Lcx,0,Lcz)).Carved
    for i,offset in sphere do
        local new = Center+offset
        if Checked[new] then continue end 
        Checked[new] = true
        local ncx,ncz,lx,ly,lz = gridtoChunkandL.gridToLocalAndChunk(new.X, new.Y, new.Z)
        if ly > 255 or ly <0 then continue end 
        if ncx ~= Lcx or ncz ~= Lcz then
            currentBuffer = Storage.rawGetOrCreate(Vector3.new(ncx,0,ncz)).Carved
            Lcx,Lcz = ncx,ncz
        end
        local to1d = to1d[lx][ly][lz]
        writter(currentBuffer, (to1d-1)*mul, 0)
    end
    return Checked
end

return Carver