--//trees etc
local SEED = 12345

local Utils = require(script.Parent.Parent.Parent.math.utils)
local NoiseHandler = require(script.Parent.Parent.Parent.math.noise)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local Carver = require(script.Parent.Parent.Parent.math.carver)
local to1dXZ = IndexUtils.to1DXZ
local to1d = IndexUtils.to1D
local structure = {}
local v3 = Vector3.new
local addBlock = Carver.addBlock
local tree =   {
    name = "c:tree",
    chance = 1,
    override = 2,
    layout = {
        key = {
            3,2
        },
        shape = {
            [v3(0, 1, 0)] = 1,
            [v3(0, 2, 0)] = 1,
            [v3(0, 3, 0)] = 1,
            [v3(0, 4, 0)] = 1,
            [v3(-1, 4, 0)] = 2, [v3(-2, 4, 0)] = 2, [v3(-1, 4, 1)] = 2, [v3(-2, 4, 1)] = 2,
            [v3(-1, 4, -1)] = 2, [v3(-2, 4, -1)] = 2, [v3(-1, 4, 2)] = 2, [v3(-1, 4, -2)] = 2,
            [v3(1, 4, 0)] = 2, [v3(2, 4, 0)] = 2, [v3(1, 4, 1)] = 2, [v3(2, 4, 1)] = 2,
            [v3(1, 4, -1)] = 2, [v3(2, 4, -1)] = 2, [v3(1, 4, 2)] = 2, [v3(1, 4, -2)] = 2,
            [v3(0, 4, 1)] = 2, [v3(0, 4, 2)] = 2, [v3(0, 4, -1)] = 2, [v3(0, 4, -2)] = 2,
            [v3(0, 5, 0)] = 1,
            [v3(-1, 5, 0)] = 2, [v3(-2, 5, 0)] = 2, [v3(-1, 5, 1)] = 2, [v3(-2, 5, 1)] = 2,
            [v3(-1, 5, -1)] = 2, [v3(-2, 5, -1)] = 2, [v3(-1, 5, 2)] = 2, [v3(-1, 5, -2)] = 2,
            [v3(1, 5, 0)] = 2, [v3(2, 5, 0)] = 2, [v3(1, 5, 1)] = 2, [v3(2, 5, 1)] = 2,
            [v3(1, 5, -1)] = 2, [v3(2, 5, -1)] = 2, [v3(1, 5, 2)] = 2, [v3(1, 5, -2)] = 2,
            [v3(0, 5, 1)] = 2, [v3(0, 5, 2)] = 2, [v3(0, 5, -1)] = 2, [v3(0, 5, -2)] = 2,
            [v3(0, 6, 0)] = 2,
            [v3(-1, 6, 0)] = 2, [v3(-1, 6, 1)] = 2, [v3(-1, 6, -1)] = 2,
            [v3(1, 6, 0)] = 2, [v3(1, 6, 1)] = 2, [v3(1, 6, -1)] = 2,
            [v3(0, 6, -1)] = 2, [v3(0, 6, 1)] = 2,
            [v3(0, 7, 0)] = 2,
         }
    }

}
local village = {
    name = "c:village",
    chance = 100,
    override = 2,
    layout = {
        key = {
            1,2,3
        },
        shape = function(CarvedOut,cx,cz,ofx,height,ofz,stru,biomeAndSurface,random:Random)
            local hut = stru.layout.hut
            local rx,rz = cx*8+ofx,cz*8+ofz
            local current = Vector3.new(cx,0,cz)
            local finished = tree
            local surface = biomeAndSurface[current][2]
            local function branch(rx,rz,dir,chance)
                if chance == 0 then return end 
                if random:NextInteger(1, 100) > chance then return end 
                local range = random:NextInteger(5, 30)
                local interval = 7
                for o =0,range do
                    interval-=1
                    local x = 0
                    local z =0
                    if dir == 1 then
                        x = rx+o
                    elseif dir == 2 then
                        z = rz+o
                    elseif dir == 3 then
                        x = rx-o
                    elseif dir == 4 then
                        z = rz -o
                    end
                    for i =0,1 do
                        if dir == 1 or dir ==3 then
                            z = rz+i
                        elseif dir == 2 or dir == 4 then
                            x = rx+i
                        end
                        local chx,chz,xx,_,zz = ConversionUtils.gridToLocalAndChunk(x,height,z)
                        if current.X ~= chx or current.Z ~= chz then
                            current = Vector3.new(chx,0,chz)
                            if not  biomeAndSurface[current] then 
                                finished = false
                                break 
                            end 
                            surface = biomeAndSurface[current][2]
                        end
                        local idx = to1dXZ[xx][zz]
                        local atHeight = buffer.readu8(surface, idx-1)
                        addBlock(CarvedOut, chx, chz, xx, atHeight, zz,3,1)
                        if interval <=0 and random:NextInteger(1, 5)  == 1 then
                            interval = 7
                            local x = x
                            local z = z
                            if dir == 1 then
                                z+=3
                            elseif dir == 2 then
                                x += 3
                            elseif dir == 3 then
                                z -=7
                            elseif dir == 4 then
                                x -=7
                            end
                            local chx,chz,xx,_,zz = ConversionUtils.gridToLocalAndChunk(x,height,z)
                            Carver.addStructure(chx, chz, xx, atHeight, zz, hut, stru.layout.key, 1, CarvedOut)
                        end
                     end 
                end
            end
            branch(rx,rz,1,100)
            branch(rx,rz,2,100)
            branch(rx,rz,3,100)
            branch(rx,rz,4,100)
            return finished
          --  Carver.addStructure(cx, cz, ofx, height, ofz, hut, stru.layout.key, 2, CarvedOut)
        end,
        hut = (function()
            local t = {}
            for x = 0,5 do
                for z = 0,5 do
                    for y = 0,5 do
                        t[v3(x,y,z)] = 1
                    end
                end
            end
            return t
        end)()
    }

}
local function getStructure(biome)
  return  {
    tree,
    
    }
end
--[[
    {
    name : String,
    chance: number|table,
    override:1,
    yHeight = random,
    layout : table|function,
    }
]]
function structure.sample(cx,cz,blocks,biomeAndSurface)
    local chunkStr = `{cx},{cz}`
    local biome = biomeAndSurface[chunkStr][1]
    local surface = biomeAndSurface[chunkStr][2]
    local newTemp = {}
    debug.profilebegin("parse")
    for i,v in biomeAndSurface do
        local x,z = i:match("(-?%d+),(-?%d+)")
        newTemp[v3(x,0,z)] = v
    end
    debug.profileend()
    biomeAndSurface = newTemp
    if typeof(biome) =='buffer' then
        biome = buffer.readu16(biome, 2)
    end
    local strucutres = getStructure(biome)
    local random = Utils.createRandom(SEED+2341, cx, cz)
    local CarvedOut = {}
    local cofx,cofz = cx*8,cz*8 
    debug.profilebegin("sampleStructures")
    local finished = tree
    for i,stru in strucutres do
        if random:NextInteger(1, stru.chance or 10) ~= 1 then continue end
        local ofx = random:NextInteger(0, 7)
        local ofz = random:NextInteger(0, 7)
        local idx = to1dXZ[ofx][ofz]
        local height = buffer.readu8(surface, idx-1)
        local blockAt = buffer.readu32(blocks, (to1d[ofx][height][ofz]-1)*4)
        if blockAt == 0 then continue end 
        local key = stru.layout.key
        local currentV = v3(ofx+cofx,height,ofz+cofz)
        local mode = stru.override
        if typeof( stru.layout.shape) == "function" then
            local v = stru.layout.shape(CarvedOut,cx,cz,ofx,height,ofz,stru,biomeAndSurface,random)
            if not v then
                finished = false
            end
            continue
        end
        for offset,block in stru.layout.shape do
            local chx = cx
            local chz = cz
            local current = offset+currentV
            local xx,yy,zz = current.X,current.Y,current.Z
            if yy < 0 or yy >255 then continue end 
            if not ConversionUtils.isWithIn(xx, 0, zz) then
                chx,chz,xx,_,zz = ConversionUtils.gridToLocalAndChunk(xx, yy, zz)
            end
           addBlock(CarvedOut, chx, chz, xx,yy,zz,key[block],mode)
        end
    end
    debug.profileend()
    return Carver.toArray(CarvedOut),finished
end
return structure 