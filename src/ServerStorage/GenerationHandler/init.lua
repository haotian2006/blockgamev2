local LocalizationService = game:GetService("LocalizationService")

local generation = {}
local c,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local c,st = pcall(require,game.ReplicatedStorage.GameSettings)
local part_scale  = 4
local noise_scale = 100
local height_scale = 60/2

local octaves = 1 
local lacunarity = 0
local persistence = 2
local seed = 1234567

local max_height = 60
local noiseScale2 = 60/2

local maxwormlength = 400
local maxwormsperchunk = 3
local maxworminchunklength = 3
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
function generation.proceduralNum(x,y,s,max,min)
	local thingy = 4
	min = min or 0
	return Random.new(s*x*y+x+y+s):NextInteger(min,max)--math.clamp( math.round(math.abs((math.noise((x/thingy)+.1,(y/thingy)+0.1,s)+.5)*max)),min,math.huge)
end
local maxres = 5
function generation.CreateBedrock(cx,cz,gtable):table
	for x = 0,st.ChunkSize.X-1 do
		for z = 0,st.ChunkSize.X-1 do
			local combine = qf.cv3type("string",x,0,z)
			gtable[combine] = 'Type|s%Cubic:Bedrock'
		end
	end	
	return gtable
end
function generation.Color(cx,cz,gtable):table
	local function getColor(x,y,z)
		local combine = x..','..y..','..z
		local self = gtable[combine]
		local above = gtable[x..','..(y+1)..','..z]
		if not above and self then
			return 'Type|s%Cubic:Grass'
		elseif (above == 'Type|s%Cubic:Grass' or not gtable[x..','..(y+3)..','..z]  ) and self  then
			return 'Type|s%Cubic:Dirt'
		elseif self then
			return'Type|s%Cubic:Stone'
		end
	end
	for y = st.ChunkSize.Y-1,0,-1 do
		for x = 0,st.ChunkSize.X-1 do
			for z = 0,st.ChunkSize.X-1 do
				local combine = x..','..y..','..z
				 gtable[combine] = getColor(x,y,z)
			end
		end	
	end
	return gtable
end
function generation.CreateWorms(cx,cz) -- cx and cy is the chunk it is being generated in
	--note that all math.random functions will be changed so it will be procedural generated instead
	local ammountofcaves =  generation.proceduralNum(cx,cz,seed,6)
	local worms = {}
	if ammountofcaves == 2 then
	local caves = 1
	--for caves = 2,ammountofcaves+1 do
		local sx,sy,sz = generation.proceduralNum(cx*1.3,cz*caves,seed+caves,7),generation.proceduralNum(cx*caves,cz*caves,seed+caves,50),generation.proceduralNum(cx*.12*caves,cz*1.6,seed+caves,7)-- generate a random startposition
		local ammount =  generation.proceduralNum(sz,sx/caves,seed,2) -- how much branches from the startpos 
		local Resolution = generation.proceduralNum(sz,sx/caves,seed,maxres,4)
		for ci = 1,ammount do
			--local c = BrickColor.random()-- doing this so each branch will be a diffrent color
			local wormdata = {}
			local WormP = CFrame.new(qf.convertchgridtoreal(cx,cz,sx,sy,sz,true))--[[convert it to grid positon from local grid ex: if cx is 0 and chgrid = 1 then grid = 1 
																				but if cx == 1 and chgrid = 1 then grid = 8 ]]
			local maxlength = generation.proceduralNum(sx*.4,sz*.23,seed,120) --worm length
			local cwx,cwz = cx,cz
			local changed = 0
			for i=1, maxlength do
				local x,y,z = math.noise(WormP.Y/Resolution+.1,seed+ci)+0.01,math.noise(WormP.X/Resolution+.1,seed+ci)+0.01,math.noise(WormP.Z/Resolution+.1,seed+ci)+0.01 -- get a direaction
				WormP = WormP*CFrame.Angles(x*(1+ci),y*(1+ci),z*(1+ci))*CFrame.new(0,0,-Resolution) -- adding ci so it adds an offset
				local roundpos = roundpos(WormP.Position)--rounds to grid
				x,y,z = roundpos.X,roundpos.Y,roundpos.Z
				wormdata[roundpos.X..','..roundpos.Y..','..roundpos.Z] = false -- convert the vector3 to a string and store it in a dictionary
				local ccx,ccz = qf.GetChunkfromReal(x,y,z,true)
				local function sphere()
					for x1 = 1, Resolution*2 do
						for y1 = 1, Resolution*2 do
							for z1 = 1, Resolution*2 do
								local worldSpace = Vector3.new(-x1+x,-y1+y,-z1+z)
								if Vector3.new(x1-Resolution,y1-Resolution,z1-Resolution).Magnitude <= Resolution-.1 then
									wormdata[qf.combinetostring(worldSpace.X,worldSpace.Y,worldSpace.Z)] = false
								end
							end
						end
					end
				end
				sphere()
				if ccx ~= cwx or ccz ~= cwz then
					cwx,cwz = ccx,ccz
					changed +=1
					if changed >= maxworminchunklength then break end
				end
				-- this parts for debugging/visual
				-- local Part = Instance.new("Part")
				-- Part.Anchored = true
				-- if i == 1 then
				-- 	Part.Material = Enum.Material.Neon -- marks the start
				-- end
				-- Part.Position = roundpos
				-- Part.Parent = workspace
				-- Part.BrickColor = c
				-- Part.Size = Vector3.new(1,1,1)

			end
			table.insert(worms,wormdata)
		end
	end
	return worms
end
function generation.GenerateTable(cx,cz)
	local newtable = {}
    for x = 0,st.ChunkSize.X-1 do
		for z = 0,st.ChunkSize.X-1 do
				newtable[x..','..z] = false
		end
	end
	return newtable
end
function generation.GenerateTerrain(cx,cz)
	local newtable = {}
    for x = 0,st.ChunkSize.X-1 do
		for z = 0,st.ChunkSize.X-1 do
			local setblocktoston = false
			for y = max_height-1,0,-1 do
				local v = qf.convertchgridtoreal(cx,cz,x,y,z,true)
				local d = (not generation.IsAir(v.X,v.Y,v.Z) and true) or false 
				newtable[x..','..y..','..z] = setblocktoston or d or nil
				setblocktoston = setblocktoston or d
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
function generation.runfunctionfrommuti(m,func,...)
	qf = m.QuickFunctions
	st = m.GameSettings
	if generation[func] then
		return generation[func](...)
	end
end
return generation