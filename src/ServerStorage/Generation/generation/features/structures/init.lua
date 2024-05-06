--//trees etc


local Utils = require(script.Parent.Parent.Parent.math.utils)
local Distributions = require(script.Parent.Parent.Parent.math.Distributions)
local NoiseHandler = require(script.Parent.Parent.Parent.math.noise)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
local Carver = require(script.Parent.Parent.Parent.math.Carver2)
local Storage = unpack(require(game.ServerStorage.core.Chunk.Generator.ChunkAndStorage))
local BlockHandler = require(game.ReplicatedStorage.Handler.Block)
local BiomeHelper = require(game.ReplicatedStorage.Handler.Biomes)
local Biomes 

local to1dXZ = IndexUtils.to1DXZ
local to1d = IndexUtils.to1D
local structure = {}
local v3 = Vector3.new

local SEED
local WorldConfig = require(game.ReplicatedStorage.WorldConfig)
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
local gridToLocalAndChunk = ConversionUtils.gridToLocalAndChunk
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
    local structures = getStructure(biome)
    local CarvedOut = {}
    local cofx,cofz = cx*8,cz*8 
    debug.profilebegin("sampleStructures")

    local currentBuffer = Storage.getFeatureBuffer(Vector3.new(cx,0,cz))
    local currentBlocks = blocks
    for i,stru in structures do
        local random = Utils.createRandom(SEED+2341 , cx, cz,stru.salt or i)
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
            stru.layout.shape(CarvedOut,cx,cz,ofx,height,ofz,stru,random)
            continue
        end
        for offset,block in stru.layout.shape do
            local current = offset+currentV
            local ncx,ncz,lx,ly,lz = gridToLocalAndChunk(current.X, current.Y, current.Z)
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