
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

local maxwormlength = 120
local maxwormsperchunk = 3

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
local function roundpos(v3)
	return Vector3.new(math.floor(v3.X+0.5),math.floor(v3.Y+0.5),math.floor(v3.Z+0.5))
end
local Resolution = 1
function generation.proceduralNum(x,y,s,max)
	local thingy = 4
	return math.abs((math.noise((x/thingy)+.1,(y/thingy)+0.1,s)+.5)*max)
end
function generation.CreateWorm(cx,cz) -- cx and cy is the chunk it is being generated in
	--note that all math.random functions will be changed so it will be procedural generated instead
	local sx,sy,sz = math.random(0,7),math.random(0,127),math.random(0,7)-- generate a random startposition
	local ammount = math.random(0,3) -- how much branches from the startpos 
	local worms = {}
	print(ammount)
	for ci = 1,ammount do
		local c = BrickColor.random()-- doing this so each branch will be a diffrent color
		local wormdata = {}
		local WormP = CFrame.new(qf.convertchgridtoreal(cx,cz,sx,sy,sz,true))--[[convert it to grid positon from local grid ex: if cx is 0 and chgrid = 1 then grid = 1 
																			 but if cx == 1 and chgrid = 1 then grid = 8 ]]
		local maxlength = math.random(50,maxwormlength) --worm length
		for i=1, maxlength do
			local x,y,z = math.noise(WormP.X/Resolution+.1,seed+ci)+0.01,math.noise(WormP.Y/Resolution+.1,seed+ci)+0.01,math.noise(WormP.Z/Resolution+.1,seed+ci)+0.01 -- get a direaction
			WormP = WormP*CFrame.Angles(x*(1+ci),y*(1+ci),z*(1+ci))*CFrame.new(0,0,-Resolution) -- adding ci so it adds an offset
			local roundpos = roundpos(WormP.Position)--rounds to grid
			wormdata[qf.cv3type("string",roundpos)] = false -- convert the vector3 to a string and store it in a dictionary

			-- this parts for debugging/visual
			local Part = Instance.new("Part")
			Part.Anchored = true
			if i == 1 then
				Part.Material = Enum.Material.Neon -- marks the start
			end
			Part.Position = roundpos
			Part.Parent = workspace
			Part.BrickColor = c
			Part.Size = Vector3.new(1,1,1)

		end
		table.insert(worms,wormdata)
	end
	return worms
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