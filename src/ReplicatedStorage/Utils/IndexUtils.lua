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
Convert.to1d = {}::{[number]:{[number]:{[number]:number}}}
local cArea = (ChunkWidth)*(ChunkHeight) 
local PreComputed = Convert.to1d
function Convert.preCompute()
    for x = 0,ChunkWidth-1 do
        PreComputed[x] = PreComputed[x] or {}
        for y = 0,ChunkHeight-1 do
            PreComputed[x][y] = PreComputed[x][y] or {}
            for z = 0,ChunkWidth-1 do
                local idx =  x+y*ChunkWidth+z *cArea+1
                PreComputed[x][y][z] =  idx
                Convert.to3D[idx] = Vector3.new(x,y,z)
            end
        end
    end
    freezeAll(PreComputed)
    freezeAll(Convert.to3D)
end


return table.freeze(Convert)
