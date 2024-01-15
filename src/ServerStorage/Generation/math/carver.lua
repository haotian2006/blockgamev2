local carver = {}
local NoiseHandler = require(script.Parent.noise)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
IndexUtils.preCompute()
local to1D = IndexUtils.to1D
local direactions = {
    Vector3.new(-1,0,0),
    Vector3.new(1,0,0),
    Vector3.new(0,1,0),
    Vector3.new(0,-1,0),
    Vector3.new(0,0,1),
    Vector3.new(0,0,-1)

}
--[[
    carvingType:
    0 = replaceAllExceptAir,
    1 = replaceALl
    2,  ReplaceOnlyAir
]]
local function addBlock(t,cx,cz,x,y,z,block,carvingType)
    if y < 0 or y >255 then return end 
    local strC = Vector3.new(cx,0,cz)
    local tt = t[strC]
    if not tt then
        tt = {}
        t[strC] = tt
    end
    tt[(to1D[x][y][z])] = {block,carvingType}
end
local function addBlockAtChunk(t,chunk,x,y,z,block,carvingType)
    if y < 0 or y >255 then return end 
    local tt = t[chunk]
    if not tt then
        tt = {}
        t[chunk] = tt
    end
    tt[(to1D[x][y][z])] = {block,carvingType}
end
carver.addBlockAtChunk = addBlockAtChunk
carver.addBlock = addBlock
function carver.addBlockAt(t,x,y,z,block,carvingType)
    local chunkX,chunkZ,xx,yy,zz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    addBlock(t, chunkX, chunkZ, xx,yy,zz,block,carvingType)
end
function carver.checkPointInRange(x,z,center,range)
    local cx,cz = ConversionUtils.getChunk(x,0, z)
    return (Vector3.new(cx,0,cz)-center).Magnitude <= range
end
local checkPointInRange = carver.checkPointInRange
function carver.checkBoundsInRange(startX,StartZ,sizeX,sizeZ,center,range)
    return (
        checkPointInRange(startX,StartZ,center,range) and
        checkPointInRange(startX,StartZ+sizeZ,center,range) and 
        checkPointInRange(startX+sizeX,StartZ+sizeZ,center,range) and 
        checkPointInRange(startX+sizeX,StartZ,center,range)
        )
end
function carver.fill(startX,startY,startZ,sizeX,sizeY,sizeZ,block,table,mode)
    for ox = 0,sizeX do
        local x = ox + startX
        for oy = 0,sizeY do
            local y = oy +startY
            for oz = 0,sizeZ do
                local z = oz + startZ
                local chunkX,chunkZ,xx,yy,zz = ConversionUtils.gridToLocalAndChunk(x, y, z)
                addBlock(table, chunkX, chunkZ, xx,yy,zz,block,mode)
            end
        end
    end
    return table
end
function carver.addStructure(cx,cz,lx,ly,lz,shape,key,mode,Table)
    local currentV = Vector3.new(lx+cx*8,ly,lz+cz*8)
    for offset,block in shape do
        local chx = cx
        local chz = cz
        local current = offset+currentV
        local xx,yy,zz = current.X,current.Y,current.Z
        if yy < 0 or yy >255 then continue end 
        if not ConversionUtils.isWithIn(xx, 0, zz) then
            chx,chz,xx,_,zz = ConversionUtils.gridToLocalAndChunk(xx, yy, zz)
        end
       addBlock(Table, chx, chz, xx,yy,zz,key[block],mode)
    end
end
function carver.new(type,settings)
    
end 
function carver.parse(settings)
    
end
function carver.carve(self,cx,cz,lx,ly,lz,t)
     
end
local spherePrecomputed = {}
local function precomputeSphere(upto)
    for radius = 1,upto do
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
    end
end
precomputeSphere(5)
local function doSpherePreComputed(cx,cz,lx,ly,lz,block,Table,radius,checked)
    local t = spherePrecomputed[radius]
    Table = Table or {}
    local ofx,ofz = cx*8,cz*8
    local vectorLocal = Vector3.new(lx,ly,lz)
    for i,v in t do
        local chunkX,chunkZ = cx,cz
        local add = v+vectorLocal
        local xx,yy,zz = add.X,add.Y,add.Z

        -- local str = add
        -- if checked[str] then continue end 
        -- checked[str] = true

        -- if yy < 0 or yy >255 then continue end 
        -- if not ConversionUtils.isWithIn(xx, 0, zz) then
        --     chunkX,chunkZ,xx,yy,zz = ConversionUtils.gridToLocalAndChunk(xx+ofx, yy, zz+ofz)
        -- end
        --  addBlock(Table, chunkX, chunkZ, xx, yy, zz, block)
    end
    return Table
end
function carver.sphere(cx,cz,lx,ly,lz,block,Table,radius,checked)
    if radius <= #spherePrecomputed then
        return doSpherePreComputed(cx,cz,lx,ly,lz,block,Table,5,checked)
    end
    local ofx,ofz = cx*8,cz*8
    checked = checked or {}
    Table = Table or {}
    for x = -radius,radius do
        for y = -radius,radius do
            for z = -radius,radius do
                if x*x + y*y +z*z >radius then continue end 
                local chunkX,chunkZ = cx,cz
                local xx,yy,zz = x+lx,y+ly,z+lz
                local str = `{xx},{yy},{zz}`
                if checked[str] then continue end 
                if yy < 0 or yy >255 then continue end 
                checked[str] = true
                if not ConversionUtils.isWithIn(xx, 0, zz) then
                    chunkX,chunkZ,xx,yy,zz = ConversionUtils.gridToLocalAndChunk(xx+ofx, yy, zz+ofz)
                end
                addBlock(Table, chunkX, chunkZ, xx, yy, zz, block)
            end
        end
    end
    return Table
end
function carver.noiseSphere(cx,cz,lx,ly,lz,block,carverTable,noise,scale,minR,maxR)
    local rx,ry,rz = cx*8+lx,ly,lz+cz*8
    local r =  minR + (maxR - minR)
    for x = -maxR, maxR do
        local xx = rx+x
        local xSq = x*x
        for y = -maxR, maxR do
            local yy = ry+y
            local ySq = y*y
            for z = -maxR, maxR do
                local zz = rz+z
                if yy <0 or yy >255 then continue end 
                local distanceFromCenter = math.sqrt(xSq+ySq+z*z)
                local noiseValue =NoiseHandler.sample(noise,xx/scale,yy/scale,zz/scale)
                local normalized = (noiseValue + 1) / 2
                local radius = r* normalized
                if distanceFromCenter <= radius then
                   local  chunkX,chunkZ,xx,yy,zz = ConversionUtils.gridToLocalAndChunk(xx,yy, zz)
                   local chunkLoc = Vector3.new(chunkX,0,chunkZ)
                   local chunkT = carverTable[chunkLoc]
                   if not chunkT then
                       chunkT = {}
                       carverTable[chunkLoc] = chunkT
                   end
                   chunkT[(to1D[xx][yy][zz])] = block
                end
            end
        end
    end
end
function carver.noise(cx,cz,lx,ly,lz,block,carverTable,Noise,DensityRange)
    local checked = {}
    local function helper(x,y,z)
        local vector = Vector3.new(x,y,z)
       -- print(NoiseHandler.sample(Noise, x/.1, y/.1, z/.1)*10)
       local n = NoiseHandler.sample(Noise, x/.1, y/.1, z/.1)*10
        if  checked[vector] or y >255 or y <0 or (n<= DensityRange or n >-1.5) then
            return 
        end
        checked[vector] = true
        local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
        local strC = Vector3.new(cx,0,cz)
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
        local blocksT = new[`{Chunk.X},{Chunk.Z}`] or {}
        new[`{Chunk.X},{Chunk.Z}`] = blocksT
        local count = 0
        for i,v in blocks do
            count +=1
            local y,z =v,0
            if type(v) == "table" then
                y,z  = v[1],v[2]
            end
            blocksT[count] = Vector3.new(i,y,z)
        end
    end
    return new
end
return carver 