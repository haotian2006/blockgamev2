local LocalizationService = game:GetService("LocalizationService")

local generation = {}
local c,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local cs,st = pcall(require,game.ReplicatedStorage.GameSettings)
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
function generation.GenerateTerrain(cx,cz,usesplinepoints)
	local bp = {}
	for x = 0,st.ChunkSize.X-1 do
		for z = 0,st.ChunkSize.X-1 do
			local height 
			local rx,_,rz = st.convertchgridtoreal(cx,cz,x,0,z)
			if usesplinepoints then
				height = generation.GetHeightFromSpline(rx,rz)  
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
local SplinePoints = {
	{-1,30},
	{-.5,50},
	{-0,50},
	{.3,70},
	{.4,80},
	{1,80}
}
local SplinePoints1 = {
	{-1,50},
	{1,50}
}
function generation.splineInterpolation(x, splineTable)
    local n = #splineTable
    if x <= splineTable[1][1] then
        return splineTable[1][2]
    elseif x >= splineTable[n][1] then
        return splineTable[n][2]
    end
    local i = 1
    for j = 2, n do
        if x <= splineTable[j][1] then
            i = j - 1
            break
        end
    end
    local x0, x1, y0, y1 = splineTable[i][1], splineTable[i + 1][1], splineTable[i][2], splineTable[i + 1][2]
    local t = (x - x0) / (x1 - x0)
    local t2 = t * t
    local t3 = t2 * t
    local c0 = 2 * t3 - 3 * t2 + 1
    local c1 = t3 - 2 * t2 + t
    local c2 = -2 * t3 + 3 * t2
    local c3 = t3 - t2

    local interpolatedValue = c0 * y0 + c1 * (x1 - x0) * (y0 + y1) / 2 + c2 * y1 + c3 * (x1 - x0) * (y0 + y1) / 2

    return interpolatedValue
end

function generation.GetHeightFromSpline(x,z)
	local noise = generation.Noise(x,z,octaves,lacunarity,persistence,noise_scale,seed)
	return generation.splineInterpolation(noise,SplinePoints)
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
