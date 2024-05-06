local Carver = {}
local Generator = game.ServerStorage.core.Chunk.Generator
local Storage = unpack( require(Generator.ChunkAndStorage))
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local NoiseHandler = require(script.Parent.noise)
local to1d = IndexUtils.to1D
local gridToLocalAndChunk = ConversionUtils.gridToLocalAndChunk

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

function Carver.getCarveBuffer(chunkX,chunkZ)
    return Storage.getCarvedBuffer(Vector3.new(chunkX,0,chunkZ))
end

function Carver.getFeatureBuffer(chunkX,chunkZ)
    return Storage.getFeatureBuffer(Vector3.new(chunkX,0,chunkZ))
end


function Carver.sphere(startX,y,startZ,Block,radius,useU16,Checked)
    local sphere = precomputeSphere(radius)
    local writter = useU16 and buffer.writeu16 or buffer.writeu32
    local mul = useU16 and 2 or 4
    local Center = Vector3.new(startX,y,startZ)

    local Lcx,Lcz = gridToLocalAndChunk(startX,y,startZ)
    local currentBuffer = Storage.getOrCreate(Vector3.new(Lcx,0,Lcz))
    currentBuffer = useU16 and currentBuffer.Carved 
    for i,offset in sphere do
        local new = Center+offset
        if Checked[new] then continue end 
        Checked[new] = true
        local ncx,ncz,lx,ly,lz = gridToLocalAndChunk(new.X, new.Y, new.Z)
        if ly > 256 or ly <1 then continue end 
        if ncx ~= Lcx or ncz ~= Lcz then
            currentBuffer = Storage.getCarvedBuffer(Vector3.new(ncx,0,ncz))
            Lcx,Lcz = ncx,ncz
        end
        local to1d = to1d[lx][ly][lz]
        writter(currentBuffer, (to1d-1)*mul, 0)
    end
    return Checked
end

function Carver.addStructure(cx,cz,x,y,z,shape,key)
    local currentV = Vector3.new(x+cx*8-1,y,z+cz*8-1)
    
    local currentBuffer = Storage.getFeatureBuffer(Vector3.new(cx,0,cz))

    local ChunkData = Storage.getChunkData(Vector3.new(cx,0,cz))

    local currentBlocks = ChunkData.Shape
    
    local writter = buffer.writeu32
    for offset,block in shape do
        local current = offset+currentV
        local ncx,ncz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(current.X, current.Y, current.Z)
        if ly > 256 or ly <1 then continue end 
        if ncx ~= cx or ncz ~= cz then
            local c = Vector3.new(ncx,0,ncz)
            currentBuffer = Storage.getFeatureBuffer(c)
            currentBlocks = Storage.getChunkData(c).Shape
            cx,cz = ncx,ncz
        end
        local to1d = to1d[lx][ly][lz]
        if block == -1 then
            local idx_ = (to1d-1)*4
            if not currentBlocks then continue end 
            writter(currentBuffer, idx_,buffer.readu32(currentBlocks, idx_))
        else
            writter(currentBuffer, (to1d-1)*4, key[block])
        end
    end
end

function Carver.noiseSphere(cx,cz,lx,ly,lz,block,carverTable,noise,scale,minR,maxR,UseCarveBuffer)
    local rx,ry,rz = cx*8+lx-1,ly,lz+cz*8-1
    local r =  minR + (maxR - minR)
 
    local getter = UseCarveBuffer and Storage.getCarvedBuffer or Storage.getFeatureBuffer
    local currentBuffer = getter(Vector3.new(cx,0,cz))
    local ChunkData = Storage.getChunkData(Vector3.new(cx,0,cz))

    local currentBlocks = ChunkData.Shape
    
    local writter = buffer.writeu32

    for x = -maxR, maxR do
        local xx = rx+x
        local xSq = x*x
        for y = -maxR, maxR do
            local yy = ry+y
            local ySq = y*y
            for z = -maxR, maxR do
                local zz = rz+z
                if yy <1 or yy >256 then continue end 
                local distanceFromCenter = math.sqrt(xSq+ySq+z*z)
                local noiseValue =NoiseHandler.sample(noise,xx/scale,yy/scale,zz/scale)
                local normalized = (noiseValue + 1) / 2
                local radius = r* normalized
                if distanceFromCenter <= radius then
                    local ncx,ncz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(xx, yy, zz)
                    if ncx ~= cx or ncz ~= cz then
                        local c = Vector3.new(ncx,0,ncz)
                        currentBuffer = getter(c)
                        currentBlocks = Storage.getChunkData(c).Shape
                        cx,cz = ncx,ncz
                    end
                    local to1d = to1d[lx][ly][lz]
                    if not currentBlocks or buffer.readu32(currentBlocks,(to1d-1)*4) == 0 then continue end 
                    writter(currentBuffer, (to1d-1)*4,block)
                end
            end
        end
    end
end
return Carver