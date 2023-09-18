local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SharedTableRegistry = game:GetService("SharedTableRegistry")
local SharedChunks = SharedTableRegistry:GetSharedTable("SharedChunks")
local TerrianHandler = require(script.TerrianHandler)
local Biome = require(script.BiomeHandler)
local NoiseRouter = require(ServerStorage.Deepslate.worldgen.NoiseRouter)
local generation = {}
local c,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local cs,st = pcall(require,game.ReplicatedStorage.GameSettings)
local GM = require(ServerStorage.Deepslate)
local mathutils = require(game.ServerStorage.Deepslate.math.Utils)
local SharedService = require(game.ServerStorage.ServerStuff.SharedService)
local behaviorhandler =  require(ReplicatedStorage.BehaviorHandler)
local function SharedToNormal(shared,p)
    if typeof(shared) ~= "SharedTable" then return shared end 
    p = p or {}
    for i,v in shared do
        if typeof(v) == "SharedTable" then
            p[i] = {}
            SharedToNormal(v,p[i])
        else
            p[i] = v
        end
    end
    return p
end

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
	NoiseSettings = GM.WorldgenRegistries.NOISE_SETTINGS:get(GM.Identifier.parse("c:overworld"))
	RandomState = GM.RandomState.new(NoiseSettings,seed)
	Visitor = RandomState:createVisitor(NoiseSettings.noise)
	MappedRouter = RandomState.router--NoiseRouter.mapAll(Router,Visitor)
	TerrianHandler:Init(RandomState,MappedRouter,Visitor)
	Biome:Init(RandomState,MappedRouter,Visitor)
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
			gtable[combine] = 'c:Bedrock' 
		end
	end	
	return gtable
end
local once = false
function generation.Color(chunk,gtable,surface,custom):{}
	local function GetBiomeAt(x,y,z)
		if not custom then return chunk:GetBiomeAt(x,y,z)  end 
		local yy = math.floor(y/8)*8
		local s = custom[st.to1D(x,yy,z)]
		return s or chunk:GetBiomeAt(x,y,z) 
	end
	local biome,biomedata = {}
	local function getColor(x,y,z)
		local idx = st.to1D(x,y,z)
		local hy= surface[st.to1DXZ(x,z)]
		local self = gtable[st.to1D(x,y,z)]
		local above = gtable[idx+8]
		if  y <57 and (not above or above == 'T|s%c:Sand') and self  then
			return 'T|s%c:Sand'
		end
		if y == 62 and not above then 
			return "T|c:Water"
		end
		if not above and self then
			return (biomedata.SurfaceBlock or 'c:Grass')
		elseif ( not gtable[idx+24] or ( y>=hy) )and self  then
			return (biomedata.MiddleBlock or 'c:Dirt')
		elseif self then
			return'T|s%c:Stone'
		else 
			return false 
		end
	end
	for z = 0,st.ChunkSize.X-1 do
		for x = 0,st.ChunkSize.X-1 do
			for y = st.ChunkSize.Y-1,0,-1 do
				--debug.profilebegin("getbiome")
					local biome1 = GetBiomeAt(x,y,z)
					if biome ~= biome1 then
					biomedata = behaviorhandler.GetBiome(biome1 or "") or {}
						biome = biome1
				--	debug.profileend()
				end
				 local combine =st.to1D(x,y,z)
				-- debug.profilebegin("getcolor")
				 gtable[combine] = getColor(x,y,z)
				-- debug.profileend()
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
		local sx,sy,sz = generation.proceduralNum(cx*1.3,cz*caves,seed+caves,7),generation.proceduralNum(cx*caves,cz*caves,seed+caves,50),generation.proceduralNum(cx*.12*caves,cz*1.6,seed+caves,7)-- generate a random startposition
		local ammount =  generation.proceduralNum(sz,sx/caves,seed,3) 
		local Resolution = generation.proceduralNum(sz,sx/caves,seed,maxres,3)
		return sx,sy,sz,ammount,Resolution
	end
end
function generation.CreateWorms(cx,cz,special)
	local sx,sy,sz,ammount,Resolution = generation.GetWormData(cx,cz)
	if sx == nil then return nil end 
	local worms = {}
	for ci = 1,ammount do
		local WormP = CFrame.new(qf.convertchgridtoreal(cx,cz,sx,sy,sz,true))
		local maxlength = generation.proceduralNum(sx*.4,sz*.23,seed,maxwormlength) 
		local cwx,cwz = cx,cz
		local changed = 0
		for i=1, maxlength do
			local x,y,z = math.noise(WormP.Y/Resolution+.1,seed+ci)+0.01,math.noise(WormP.X/Resolution+.1,seed+ci)+0.01,math.noise(WormP.Z/Resolution+.1,seed+ci)+0.01 
			WormP = WormP*CFrame.Angles(x*(1+ci),y*(1+ci),z*(1+ci))*CFrame.new(0,0,-Resolution) 
			local roundpos = roundpos(WormP.Position)
			x,y,z = roundpos.X,roundpos.Y,roundpos.Z
			local ccx,ccz = qf.GetChunkfromReal(x,y,z,true)
			generation.sphere(worms,Resolution,x,y,z,special)
			if ccx ~= cwx or ccz ~= cwz then
				cwx,cwz = ccx,ccz
				changed +=1
				if changed >= maxworminchunklength then break end
			end

		end
	end
	return worms
end
local size = st.ChunkSize.X*st.ChunkSize.X*st.ChunkSize.Y
local xsize,ysiz = st.getChunkSize()
local w,h = 4,8
function generation.LerpFinalXZ(cx,cz,quadx,quadz)
	local density = TerrianHandler.LerpFinalDXZ(cx,cz,quadx,quadz)
	local surface = TerrianHandler.LerpXZ2D(cx,cz,quadx,quadz)
	--local biomesmap = Biome.generateBiomes(biome2d,biome,quadx,quadz)
	return {density,surface}
end
function generation.GetBiomesstuffidkdebug(x,y,z)
	local x = Vector3.new(Biome.get2DNoiseValues(x,z))
    local y = Vector2.new(Biome.get3DNoiseValues(x,y,z))
    return {x,y}
end
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

function  generation.GetBiomeType(x,y)
    
end

return generation
