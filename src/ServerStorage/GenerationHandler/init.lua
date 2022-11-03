
local generation = {}
local qf = require(game.ReplicatedStorage.QuickFunctions)
local st = require(game.ReplicatedStorage.GameSettings)
local part_scale  = 4
local noise_scale = 100
local height_scale = 60/2

local octaves = 1 
local lacunarity = 0
local persistence = 2
local seed = 12345

local max_height = 60
local noiseScale2 = 60/2

local maxwormlength = 30
local maxwormsperchunk = 3
local Resolution = 4
function generation.RandNumber(x,y,seed,range)
	range = range or 1
	return math.clamp(math.round(math.abs(math.noise((x/y+y/x),seed))*10),0,range)
end
function generation.Noise(x, y, octaves, lacunarity, persistence, scale, seed)
	local value = 0 
	local x1 = x 
	local y1 = y
	local amplitude = 1
	for i = 1, octaves, 1 do
		value += math.noise(x1 / scale, y1 / scale, seed) * amplitude
		y1 *= lacunarity
		x1 *= lacunarity
		amplitude *= persistence
	end
	return math.clamp(value, -1, 1)
end
function generation.CreateWorm(cx,cz)
	local sx,sy,sz = math.random(0,7),math.random(0,127),math.random(0,7)
	local ammount = math.random(0,3)
	for i = 0,ammount-1 do
		local WormCF = CFrame.new(qf.convertchgridtoreal(sx,sy,sz,true))
		local maxlength = math.random(3,maxwormlength)
		for i=0, maxlength do
			local x,y,z = math.noise(WormCF.X/Resolution+.1,seed),math.noise(WormCF.Y/Resolution+.1,seed),math.noise(WormCF.Z/Resolution+.1,seed)
		end
	end
end
function generation.GenerateTable(cx,cz)
	local newtable = {}
    for x = 0,st.ChunkSize.X-1 do
		for z = 0,st.ChunkSize.X-1 do
			for y = 0,st.ChunkSize.Y-1 do
				newtable[x..','..y..','..z] = qf.convertchgridtoreal(cx,cz,x,y,z,true)
			end
		end
	end
	return newtable
end
function  generation.GetBiomeType(x,y)
    
end
function generation.IsAir(x,y,z)
    local surface = (2+  generation.Noise(x,z,octaves,lacunarity,persistence,noise_scale,seed))*height_scale
	return  not ((y <surface and y <max_height )or y == 0) 
end
return generation