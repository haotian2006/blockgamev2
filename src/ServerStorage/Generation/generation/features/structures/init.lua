--//trees etc


local Utils = require(script.Parent.Parent.Parent.math.utils)
local Distributions = require(script.Parent.Parent.Parent.math.Distributions)
local NoiseHandler = require(script.Parent.Parent.Parent.math.noise)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local Carver = require(script.Parent.Parent.Parent.math.Carver2)
local Storage = unpack(require(game.ServerStorage.core.Chunk.Generator.ChunkAndStorage))
local BlockHandler = require(game.ReplicatedStorage.Block)
local BiomeHelper = require(game.ReplicatedStorage.Handler.Biomes)
local Biomes 

local to1dXZ = IndexUtils.to1DXZ
local to1d = IndexUtils.to1D
local structure = {}
local v3 = Vector3.new

local SEED
local WorldConfig = require(game.ReplicatedStorage.WorldConfig)
--[[
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

]]
local function getStructure(biome)
    local b = BiomeHelper.getBiomeFrom(biome)
    if not b then return {} end 
  return  Biomes[b].Structures
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
export type Structure = {
    salt : number?,
    chance : number,
    override : number,
    layout : {
        key : {[number]:number},
        shape: {}
    },
    randomY :Distributions.Distribution
}

function structure.parse(info)
    SEED = SEED or WorldConfig.Seed
    local parsed = {
        salt = info.salt,
        chance = info.chance or 10,
        override = info.override or 2,
        layout = info.layout or {},
        randomY = info.randomY and Distributions.parse(info.randomY)
    }

    if not parsed.layout.key or not parsed.layout.shape then return {} end 
    for i,v in parsed.layout.key do
        parsed.layout.key[i] = BlockHandler.parse(v)
    end
    return parsed
end

local writter = buffer.writeu32
function structure.sample(cx,cz)
    SEED = SEED or WorldConfig.Seed
    local currentChunk = Vector3.new(cx,0,cz)
    local ChunkData = Storage.getChunkData(currentChunk)
    local biome = ChunkData.Biome
    local surface = ChunkData.Surface
    local blocks = ChunkData.Shape
    if typeof(biome) =='buffer' then
        biome = buffer.readu16(biome, 2)
    end
    local strucutres = getStructure(biome)
    local CarvedOut = {}
    local cofx,cofz = cx*8,cz*8 
    debug.profilebegin("sampleStructures")

    local currentBuffer = Storage.getFeatureBuffer(Vector3.new(cx,0,cz))
    local currentBlocks = blocks
    for i,stru in strucutres do
        local random = Utils.createRandom(SEED+2341, cx, cz,stru.salt or i)
        if random:NextInteger(1, stru.chance or 10) ~= 1 then continue end
        local ofx = random:NextInteger(1, 8)
        local ofz = random:NextInteger(1, 8)
        local idx = to1dXZ[ofx][ofz]
        local height = math.clamp(buffer.readu8(surface, idx-1), 1, 256)
        local blockAt = buffer.readu32(blocks, (to1d[ofx][height][ofz]-1)*4)
        if blockAt == 0 then continue end 
        local key = stru.layout.key
        local currentV = v3(ofx+cofx-1,height,ofz+cofz-1)
        local mode = stru.override
        if typeof( stru.layout.shape) == "function" then
            local v = stru.layout.shape(CarvedOut,cx,cz,ofx,height,ofz,stru,random)
            if not v then
                finished = false
            end
            continue
        end
        for offset,block in stru.layout.shape do
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
    debug.profileend()
end

function structure.addRegirstry(b)
    Biomes = b
end
return structure 