local Convert = {}

local GameSettings = require(game.ReplicatedStorage.GameSettings)
local ChunkWidth = GameSettings.ChunkSize.X
local ChunkHeight = GameSettings.ChunkSize.Y

local function freezeAll(t)
    for i,v in t do
        if type(v) == "table" then
            freezeAll(v)
        end
    end
    table.freeze(t)
end

Convert.to3D = {}::{[number]:Vector3}
Convert.to1D = {}::{[number]:{[number]:{[number]:number}}}
Convert.to1DVector = {}::{[Vector3]:number}
local cArea = (ChunkWidth)*(ChunkHeight) 
local PreComputed = Convert.to1D
local preComputedFlag = false
function Convert.preCompute(DoVector)
    if preComputedFlag then return end
    preComputedFlag = true
    for x = 1,ChunkWidth do
        PreComputed[x] = PreComputed[x] or {}
        for y = 1,ChunkHeight do
            PreComputed[x][y] = PreComputed[x][y] or {}
            for z = 1,ChunkWidth do
                local idx =  x+y*ChunkWidth+z *cArea+1
                PreComputed[x][y][z] =  idx
                local v =Vector3.new(x,y,z)
                Convert.to3D[idx] = v
                Convert.to1DVector[v] = idx
            end
        end
    end
    freezeAll(PreComputed)
    freezeAll(Convert.to3D)
    freezeAll(Convert.to1DVector)
end

Convert.to2D = {}::{[number]:Vector3}
Convert.to1DXZ = {}::{[number]:{[number]:number}}
local PreComputed2D = Convert.to1DXZ
local preComputed2DFlag = false
function Convert.preCompute2D()
    if preComputed2DFlag then return end 
    preComputed2DFlag = true
    for x = 0,ChunkWidth-1 do
        PreComputed2D[x] = PreComputed2D[x] or {}
        for z = 0,ChunkWidth-1 do
            local idx =  x+z *ChunkWidth+1
            PreComputed2D[x][z] =  idx
            Convert.to2D[idx] = Vector3.new(x,0,z)
        end
    end
    freezeAll(PreComputed2D)
    freezeAll(Convert.to2D)
end

Convert.to3DSection = {}::{[number]:Vector3}
Convert.to1DSection = {}::{[number]:{[number]:{[number]:number}}}
local cAreaSection = (ChunkWidth//4)*(ChunkHeight//8) 
local PreComputedSection = Convert.to1DSection
local preComputedSectionFlag = false
function Convert.preComputeSection()
    if preComputedSectionFlag then return end 
    preComputedSectionFlag = true
    for x = 0,ChunkWidth//4-1 do
        PreComputedSection[x] = PreComputedSection[x] or {}
        for y = 0,ChunkHeight//8-1 do
            PreComputedSection[x][y] = PreComputedSection[x][y] or {}
            for z = 0,ChunkWidth//4-1 do
                local idx =  x+y*(ChunkWidth//4)+z *cAreaSection+1
                PreComputedSection[x][y][z] =  idx
                Convert.to3DSection[idx] = Vector3.new(x,y,z)
            end
        end
    end
    freezeAll(PreComputedSection)
    freezeAll(Convert.to3DSection)
end

Convert.to3DChunkQuad = {}::{[number]:Vector3}
Convert.to1DChunkQuad  = {}::{[number]:{[number]:{[number]:number}}}
local cqAreaSection = (ChunkWidth//2)*(ChunkHeight) 
local PreComputedChunkQuad  = Convert.to1DChunkQuad 
local preComputedChunkQuadFlag = false
function Convert.preComputeChunkQuad()
    if preComputedChunkQuadFlag then return end 
    preComputedChunkQuadFlag = true
    for x = 0,ChunkWidth//2-1 do
        PreComputedChunkQuad[x] = PreComputedChunkQuad[x] or {}
        for y = 0,ChunkHeight-1 do
            PreComputedChunkQuad[x][y] = PreComputedChunkQuad[x][y] or {}
            for z = 0,ChunkWidth//2-1 do
                local idx =  x+y*(ChunkWidth//2)+z *cqAreaSection+1
                PreComputedChunkQuad[x][y][z] =  idx
                Convert.to3DChunkQuad[idx] = Vector3.new(x,y,z)
            end
        end
    end
    freezeAll(PreComputedChunkQuad)
    freezeAll(Convert.to3DChunkQuad)
end

Convert.to2DChunkQuad = {}::{[number]:Vector3}
Convert.to1DXZChunkQuad = {}::{[number]:{[number]:number}}
local preComputed2DChunkQuadFlag = false
function Convert.preCompute2DChunkQuad()
    if preComputed2DChunkQuadFlag then return end 
    preComputed2DChunkQuadFlag = true
    local PreComputed2D = Convert.to1DXZChunkQuad
    for x = 0,ChunkWidth//2-1 do
        PreComputed2D[x] = PreComputed2D[x] or {}
        for z = 0,ChunkWidth//2-1 do
            local idx =  x+z *(ChunkWidth//2)+1
            PreComputed2D[x][z] =  idx
            Convert.to2DChunkQuad[idx] = Vector3.new(x,0,z)
        end
    end
    freezeAll(PreComputed2D)
    freezeAll(Convert.to2DChunkQuad)
end

function Convert.preComputeAll()
    for i,v in Convert do
        if type(v) == "function" and i ~= "preComputeAll" then
            v(true)
        end
    end
end

return table.freeze(Convert)
