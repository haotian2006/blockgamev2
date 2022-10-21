local generation = {}
--<Settings
local part_scale  = 4
local noise_scale = 100
local height_scale = 40*2

local octaves = 1
local lacunarity = 0
local persistence = 2
local seed = 12345

local max_height = 40*4
local noiseScale2 = 40*2
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
function generation.IsAir(x,y,z)
	local surface = (2+  generation.Noise(x,z,octaves,lacunarity,persistence,noise_scale,seed))*height_scale
	return  ((y <surface and y <max_height )or y == 0) 
	--return  ((y <surface and y <max_height and generation.IsCave(x,y,z))or y == 0) 
end	
function generation.IsCave(x,y,z)
	 local x,y,z = x,y,z
	local xNoise = math.noise(y/noiseScale2,z/noiseScale2,seed) * 50
	local yNoise = math.noise(x/noiseScale2,z/noiseScale2,seed) * 50
	local zNoise = math.noise(x/noiseScale2,y/noiseScale2,seed) * 50	

	 local density = xNoise + yNoise + zNoise
	 return density < 20
end
function generation.GetBlock(x,y,z)
    
end
function generation.GetChunk(chunk,range)
	if not range then error("No Range Provided") end
	local data = {}
	for y = max_height,0,-4 do
		for i,coord in range do
			local coords = string.split(coord,"x")
			local x,y,z = tonumber(coords[1]),y,tonumber(coords[2])
			local block = generation.IsAir(x,y,z)
			if block then
				data[x] = data[x] or {}
				data[x][y] = data[x][y] or {}
				data[x][y][z] = {"Stone",0,{0,0,0},x..','..y..','..z,i,true}
			end
		end
	end
	return data
end
return generation