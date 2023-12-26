local carver = {}
local NoiseHandler = require(script.Parent.noise)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local to1D = IndexUtils.to1D
local direactions = {
    Vector3.new(-1,0,0),
    Vector3.new(1,0,0),
    Vector3.new(0,1,0),
    Vector3.new(0,-1,0),
    Vector3.new(0,0,1),
    Vector3.new(0,0,-1)

}
local function addBlock(t,cx,cz,x,y,z,block)
    if y < 0 or y >255 then return end 
    local strC = `{cx},{cz}`
    local tt = t[strC]
    if not tt then
        tt = {}
        t[strC] = tt
    end
    tt[(to1D[x][y][z])] = block
end
function carver.new(type,settings)
    
end
function carver.parse(settings)
    
end
function carver.carve(self,cx,cz,lx,ly,lz,t)
    
end
function carver.sphere(cx,cz,lx,ly,lz,block,Table,radius)
    local ofx,ofz = cx*8,cz*8
    Table = Table or {}
    for x = -radius,radius do
        for y = -radius,radius do
            for z = -radius,radius do
                if x*x + y*y +z*z >radius then continue end 
                local chunkX,chunkZ = cx,cz
                local xx,yy,zz = x+lx,y+ly,z+lz
                if yy < 0 or yy >255 then continue end 
                if not ConversionUtils.isWithIn(xx, 0, zz) then
                    chunkX,chunkZ,xx,yy,zz = ConversionUtils.gridToLocalAndChunk(xx+ofx, yy, z+ofz)
                end
                addBlock(Table, chunkX, chunkZ, xx, yy, zz, block)
            end
        end
    end
    return Table
end
function carver.noise(cx,cz,lx,ly,lz,block,carverTable,Noise,DensityRange)
    local checked = {}
    local function helper(x,y,z)
        local vector = Vector3.new(x,y,z)
        if  checked[vector] or y >255 or y <0 or (NoiseHandler.sample(Noise, x, y, z)<= DensityRange) then
            return 
        end
        checked[vector] = true
        local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
        local strC = `{cx},{cz}`
        local chunkT = carverTable[strC]
        if not chunkT then
            chunkT = {}
            carverTable[strC] = chunkT
        end
        chunkT[(to1D[lx][ly][lz])] = block
        for i,dir in direactions do
            helper(x+dir.X, y+dir.Y, z+dir.z)
        end
    end
    helper(cx*8+lx,ly,cz*8+lz)
    return carverTable
end
function carver.toArray(t)
    local new = {}
    for Chunk,blocks in t do
        local blocksT = new[Chunk]
        new[Chunk] = blocksT
        local count = 0
        for i,v in blocks do
            count +=1
            blocksT[count] = Vector3.new(i,v)
        end
    end
    return new
end
return carver 