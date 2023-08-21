local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SharedTableRegistry = game:GetService("SharedTableRegistry")
local TerrianHandler = require(script.TerrianHandler)
local NoiseRouter = require(ServerStorage.GenerationManager.worldgen.NoiseRouter)
local generation = {}
local c,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local cs,st = pcall(require,game.ReplicatedStorage.GameSettings)
local GM = require(ServerStorage.GenerationManager)
local part_scale  = 3
local noise_scale = 100
local height_scale = 60/2

local octaves = 3 
local lacunarity = 0
local persistence = 2
local seed = cs and st.Seed

local max_height = 60--60
local noiseScale2 = 60/2

local maxwormlength = 400
local maxwormsperchunk = 3
local maxworminchunklength = 3
local vector3int = Vector3int16.new
local registryfunc = {
	density_function = function(d,p)
		local df = GM.DensityFunction.HolderHolder.new(GM.Holder.parser(GM.WorldgenRegistries.DENSITY_FUNCTION,GM.DensityFunction.Evaluate)(d))
		GM.WorldgenRegistries.DENSITY_FUNCTION:register(GM.Identifier.parse(p),df)
	end,
	noise = function(d,p)
		GM.WorldgenRegistries.NOISE:register(GM.Identifier.parse(p),GM.NoiseParameters.Evaluate(d))
	end,
	noise_settings = function(d,p)
		GM.WorldgenRegistries.NOISE_SETTINGS:register(GM.Identifier.parse(p),GM.NoiseGeneratorSettings.Evaluate(d))
	end
}
local function ISATU(t)
	return type(t) == 'table' or type(t) =="userdata"
end
local function regisertstuff(path,type,prefix)
	local fx = registryfunc[type] 
	local function dosmt(d,p)
		if  typeof(d) == "boolean" then return end 
		if ISATU(d) and d.ISFOLDER then
			for i,v in d do
				local a = p..'/'..i
				dosmt(v,a)
			end
		else
			fx(d,p)
		end
	end
	if fx == nil then
		error(`{type} is not a valid registry`)
	end
	for i,v in path do
		local p = prefix..":"..i
		dosmt(v,p)
	end
end
local RandomState,Router,Sampler,Visitor,SurfaceNoise,FactorNoise,Seed,NoiseSettings,MappedRouter
function generation:Init(seed)
	Seed = seed
	local beh = require(ReplicatedStorage.BehaviorHandler)
	for i,v in beh.WorldGeneration  do
		if type(v) == "boolean" then continue end 
		local pf = i
		for ii,dir in v do
			if type(dir) == "boolean" then continue end 
			regisertstuff(dir,ii,pf)
		end
	end
	NoiseSettings = GM.WorldgenRegistries.NOISE_SETTINGS:get(GM.Identifier.parse("C:overworld"))
	RandomState = GM.RandomState.new(NoiseSettings,seed)
	Router = RandomState.router
	Sampler = GM.Climate.fromRouter
	Visitor = RandomState:createVisitor(NoiseSettings.noise)
	local sD =  GM.WorldgenRegistries.DENSITY_FUNCTION:get(GM.Identifier.parse("C:overworld/CubicalSurface"))--CubicalSurface
	local fD =  GM.WorldgenRegistries.DENSITY_FUNCTION:get(GM.Identifier.parse("C:overworld/factor"))
	SurfaceNoise = sD:mapAll(Visitor)
	FactorNoise = fD:mapAll(Visitor)
	MappedRouter = RandomState.router--NoiseRouter.mapAll(Router,Visitor)
	TerrianHandler:Init(RandomState,MappedRouter,Visitor)
end


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
			local combine = vector3int(x,0,z)
			gtable[combine] = 'T|s%C:Bedrock' 
		end
	end	
	return gtable
end
local function getColor(x,y,z,gtable)
	local self = gtable[st.to1D(x,y,z)]
	local above = gtable[st.to1D(x,y+1,z)]
	if  y <57 and (not above or above == 'T|s%C:Sand') and self  then
		return 'T|s%C:Sand'
	end
	if not above and self then
		return 'T|s%C:Grass'
	elseif (above == 'T|s%C:Grass' or not gtable[st.to1D(x,y+3,z)]  ) and self  then
		return 'T|s%C:Dirt'
	elseif self then
		return'T|s%C:Stone'
	else 
		return false 
	end
end
function generation.Color(cx,cz,gtable):{}
	for y = st.ChunkSize.Y-1,0,-1 do
		for z = 0,st.ChunkSize.X-1 do
			for x = 0,st.ChunkSize.X-1 do
				 local combine =st.to1D(x,y,z)
				 gtable[combine] = getColor(x,y,z,gtable)
			end
		end	
	end
	return gtable
end
function generation.sphere(worms,Resolution,x,y,z,special )
	if not special  then
	for x1 = 1, Resolution*2 do
		for y1 = 1, Resolution*2 do
			for z1 = 1, Resolution*2 do
				local worldSpace =vector3int(-x1+x,-y1+y,-z1+z)
				if Vector3.new(x1-Resolution,y1-Resolution,z1-Resolution).Magnitude <= Resolution-.1 and worldSpace.Y>=0 then
					local ccx,ccz,lx,ly,lz = qf.GetChunkAndLocal(worldSpace.X,worldSpace.Y,worldSpace.Z)
					local comb = ccx..','..ccz
					worms[comb] = worms[comb] or {}
					--print(localP)
					worms[comb][st.to1D(lx,ly,lz,true)] = false --'air'
				end
			end
		end
	end
	else
		local ccx,ccz,lx,ly,lz = qf.GetChunkAndLocal(x,y,z)
		local comb = ccx..','..ccz
		worms[comb] = worms[comb] or {}
		table.insert(worms[comb],st.to1D(lx,ly,lz)) 
	end
end
function generation.GetWormData(cx,cz)
	local Chance =  generation.proceduralNum(cx,cz,seed,20)
	if Chance == 2 then
	local caves = 1
	--for caves = 2,ammountofcaves+1 do
		local sx,sy,sz = generation.proceduralNum(cx*1.3,cz*caves,seed+caves,7),generation.proceduralNum(cx*caves,cz*caves,seed+caves,50),generation.proceduralNum(cx*.12*caves,cz*1.6,seed+caves,7)-- generate a random startposition
		local ammount =  generation.proceduralNum(sz,sx/caves,seed,3) -- how much branches from the startpos 
		local Resolution = generation.proceduralNum(sz,sx/caves,seed,maxres,3)
		return sx,sy,sz,ammount,Resolution
	end
end
function generation.CreateWorms(cx,cz,special) -- cx and cy is the chunk it is being generated in
	local sx,sy,sz,ammount,Resolution = generation.GetWormData(cx,cz)
	if sx == nil then return nil end 
	local worms = {}
	for ci = 1,ammount do
		--local c = BrickColor.random()-- doing this so each branch will be a diffrent color

		local WormP = CFrame.new(qf.convertchgridtoreal(cx,cz,sx,sy,sz,true))--[[convert it to grid positon from local grid ex: if cx is 0 and chgrid = 1 then grid = 1 
																			but if cx == 1 and chgrid = 1 then grid = 8 ]]
		local maxlength = generation.proceduralNum(sx*.4,sz*.23,seed,maxwormlength) --worm length
		local cwx,cwz = cx,cz
		local changed = 0
		for i=1, maxlength do
			local x,y,z = math.noise(WormP.Y/Resolution+.1,seed+ci)+0.01,math.noise(WormP.X/Resolution+.1,seed+ci)+0.01,math.noise(WormP.Z/Resolution+.1,seed+ci)+0.01 -- get a direaction
			WormP = WormP*CFrame.Angles(x*(1+ci),y*(1+ci),z*(1+ci))*CFrame.new(0,0,-Resolution) -- adding ci so it adds an offset
			local roundpos = roundpos(WormP.Position)--rounds to grid
			x,y,z = roundpos.X,roundpos.Y,roundpos.Z
			--wormdata[roundpos.X..','..roundpos.Y..','..roundpos.Z] = false -- convert the vector3 to a string and store it in a dictionary
			local ccx,ccz = qf.GetChunkfromReal(x,y,z,true)
			generation.sphere(worms,Resolution,x,y,z,special)
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
	end
	return worms
end
local size = st.ChunkSize.X*st.ChunkSize.X*st.ChunkSize.Y
function generation.GenerateBlueprint()
	return table.create(size,false)
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
local smoothingRadius = 4
local sizex = st.ChunkSize.X-1
local sizexn = st.ChunkSize.X
local function getnearby(x,z,cx,cz,data)
	if x <0 then
		x = sizexn-x
		cx -= 1
	elseif x>sizex then
		cx += 1
		x = x-sizexn
	end
	if z <0 then
		z = sizexn-z
		cz -= 1
	elseif z>sizex then
		cz += 1
		z = z-sizexn
	end
	return data[cx..','..cz][st.to1DXZ(x,z)] 
end
function generation.SmoothTerrian(cx,cz,data)
	local main = data[cx..','..cz]
	local new =  table.create(size,false)
	for x = 0,sizex do
		for z = 0,sizex do
			local idx = st.to1DXZ(x,z)
			local sumY = main[idx]
			local numPoints = 1
			for dx = -smoothingRadius, smoothingRadius do
				for dz = -smoothingRadius, smoothingRadius do
					if dx ~= 0 or dz ~= 0 then
						local nx,nz =x+dx,z+dz
						local nearbyY = getnearby(nx,nz,cx,cz,data)
						if nearbyY then
							sumY = sumY + nearbyY
							numPoints = numPoints + 1
						end
					end
				end
			end
			local averageY = sumY / numPoints
			local height = math.round(averageY)
			for y =height,0,-1 do
				new[st.to1D(x,y,z)] =  true
			end
		end
	end
	return new
end
local function lerp(a, b, t)
    return a + (b - a) * t
end
local HorizontalNoiseResolutionDivisor = 1
function generation.SmoothDensity(cx,cz,data)
	local main = data[cx..','..cz]
	for x = 0,sizex do
		for z = 0,sizex do
			local idx = st.to1DXZ(x,z)
			
			local level00 = getnearby(x,z,cx,cz,data)
			local level10 = getnearby(x+4,z,cx,cz,data)
			local level01 = getnearby(x,z+4,cx,cz,data)
			local level11 = getnearby(x+4,z+4,cx,cz,data)
			
			local lerpResult = GM.Utils.lerp2((x) / 8, (z) / 8, level00, level10, level01, level11)
			
			local level =(lerpResult)
			main[idx] =  level + 0 
		end
	end
	return main
end
function generation.GenerateSurfaceDensity(cx,cz)
	local bp = {}
	local ofx,ofy = st.getoffset(cx,cz)
	for x = 0,st.ChunkSize.X-1,4 do
		for z = 0,st.ChunkSize.X-1,4 do
			local rx,rz = ofx +x, ofy+z
			local offset =SurfaceNoise:compute(Vector3.new(rx,0,rz))
			--local factor = FactorNoise:compute(Vector3.new(rx,0,rz))
			local indx = st.to1DXZ(x,z)
			local value = offset
			bp[indx] = value
			bp[indx+1] = value
			bp[indx+2] = value
			bp[indx+3] = value

			bp[indx+8] = value
			bp[indx+16] = value
			bp[indx+24] = value

			bp[indx+9] = value
			bp[indx+10] = value
			bp[indx+11] = value

			bp[indx+17] = value
			bp[indx+18] = value
			bp[indx+19] = value
			
			bp[indx+25] = value
			bp[indx+26] = value
			bp[indx+27] = value
		end
	end
	return bp
end
function generation.GenerateTerrain(cx,cz,usesplinepoints)
	local bp = {}
	for x = 0,st.ChunkSize.X-1 do
		for z = 0,st.ChunkSize.X-1 do
			local height 
			local rx,_,rz = st.convertchgridtoreal(cx,cz,x,0,z)
			if usesplinepoints then
				height =SurfaceNoise:compute(Vector3.new(rx,0,rz)) --generation.GetHeightFromSpline(rx,rz)  
				-- bp[st.to1DXZ(x,z)] = height
				-- continue 
			end
			for y = st.ChunkSize.Y-1,0,-1 do
				if not height then
					height =  (not generation.IsAir(rx,y,rz,true)) and y or nil
				end
				bp[st.to1D(x,y,z)] =  (height and y <= height and true) or false
			end
		end
	end
	return bp
end
function  generation.GetBiomeType(x,y)
    
end

function generation.GenerateMultiNoise(x,z)
	local continentalness = math.noise(x/1000,z/1000,seed)*3
	local erosion  = math.noise(x/670,z/670,seed)*.5
	local pv  = math.noise(x/345,z/345,seed)*.2
	return continentalness,erosion,pv
end
function generation.IsAir(x,y,z)
    local surface = (2+  generation.Noise(x,z,octaves,lacunarity,persistence,noise_scale,seed))*height_scale
	return  not ((y <surface and y <max_height )or y == 0) 
end
function generation.runfunctionfrommuti(m,func,...)
	qf = m.QuickFunctions
	qf.ADDSETTINGS(m)
	st = m.GameSettings
	seed = st.Seed
	if generation[func] then
		return generation[func](...)
	end
end
return generation
