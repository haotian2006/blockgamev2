local biome = {}
local RandomState,MappedRouter,Visitor
local gamesettings = require(game.ReplicatedStorage.GameSettings)
local Climate = require(game.ServerStorage.Deepslate.worldgen.biome.Climate)
local cs = gamesettings.ChunkSize
local csx,csy = cs.X,cs.Y
local MultiNoiseHandler = require(game.ServerStorage.Deepslate.worldgen.biome.MultiNoiseBiomeSource)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local BiomeGetter 
local SharedService = require(game.ServerStorage.ServerStuff.SharedService)
local noiseRouter = require(game.ServerStorage.Deepslate.worldgen.NoiseRouter)
local mathutils = require(game.ServerStorage.Deepslate.math.Utils)
export type continents = number
export type erosion = number
export type weirdness = number
export type temperature = number
export type humidity = number
export type depth = number
function biome:Init(settings,MR,Visitor)
    MappedRouter = MR
    local allbiomes = settings.biomes or {}
    BiomeGetter = MultiNoiseHandler.Evaluate(allbiomes)
    biome.INITED = true
end
local w = 4
function biome.getNoiseValues(cx,cz,biomeSection,quadx,quadz)
    debug.profilebegin("getFeatures")
    local noises = {}
    local holder = {}
    local index = 0
    local vv = 0
    if quadx == 1 and quadz == 0 then
        vv = 1
    elseif quadx == 0 and quadz == 1 then
        vv = 2
    elseif quadx ==1 and quadz == 1 then
        vv = 3
    end
    local ofx,ofz = gamesettings.getoffset(cx,cz)
    local x,z = ofx+4*quadx,4*quadz+ofz
    if type(biomeSection) == "string" then
        biomeSection = {biomeSection}
    end
    for i,v in biomeSection do
        if not holder[v] then
            index +=1
            local biomesData = BehaviorHandler.GetBiome(v)
            for name,func in biomesData.noiseFunctions do
               if noises[name] then continue end
                if vv == 1 then
                    noises[name] = Vector2.new(func:sample(x,0,z),func:sample(x+4,0,z))
                elseif vv == 2 then
                    noises[name] = Vector2.new(func:sample(x,0,z),func:sample(x,0,z+4))
                elseif vv == 3 then
                    noises[name] = Vector3.new(func:sample(x,0,z),func:sample(x+4,0,z),func:sample(x,0,z+4))
                else
                    noises[name] = Vector2.new(func:sample(x,0,z),func:sample(x+8,0,z+8))
                end
            end
            holder[v] = true
        end
    end
    debug.profileend()
    return noises
end
function biome.lerpFNoise(quadx,quadz,noise00,noise10,noise01,noise11,key)
    local noise = {}
    debug.profilebegin("LerpFeatures")

    local idx = 0 
    for qx =0,4-1 do
		local x = qx+4*quadx
		local xx = ((x % w + w) % w) / w
		for qz  =0,4-1 do
			local z = qz+4*quadz
			local zz = ((z % w + w) % w) / w
            for id,name in key do
                idx+=1
                --idx = qx + qz *4 + 1
                noise[idx] =   mathutils.lerp2(xx,zz,noise00[id],noise10[id],noise01[id],noise11[id])
            end
		end
	end
    debug.profileend()
    return noise
end
function biome.getFeatures(cx,cz,biomes,quadx,quadz)
    local biomesData = BehaviorHandler.GetBiome(biome)
    debug.profilebegin("getFeatures")
    local noisefunctions = biomesData.NoiseFunctions
    local ofx,ofz = gamesettings.getoffset(cx,cz)
    local s = Vector3.new( 4*quadx+ofx,0,4*quadz+ofz)
    local middle00 = {}
    local middle10 = {}
    local middle01 = {}
    local middle11 = {}
    for i,v in noisefunctions do
        middle00[i] = v:compute(s)
        middle10[i] = v:compute(s+Vector3.new(w,0,0))
        middle01[i] = v:compute(s+Vector3.new(0,0,w))
        middle11[i] = v:compute(s+Vector3.new(w,0,w))
    end
    for qx =0,4-1 do
		local x = qx+4*quadx
		local xx = ((x % w + w) % w) / w
		for qz  =0,4-1 do
			local z = qz+4*quadz
			local zz = ((z % w + w) % w) / w
            for i,v in noisefunctions do
                local value = mathutils.lerp2(xx,zz,middle00[i],middle10[i],middle01[i],middle11[i])

            end
		end
    end
    debug.profileend()
    return {}
end
function biome.get2DNoiseValues(x,z): (continents,erosion,weirdness)
    local pos = Vector3.new(x,0,z)
    local continents = MappedRouter.continents
    local erosion = MappedRouter.erosion 
    local weirdness =  MappedRouter.weirdness 
    return continents and continents:compute(pos),
    erosion and erosion:compute(pos),
    weirdness and weirdness:compute(pos)
end
function biome.get3DNoiseValues(x,y,z,debug): (temperature,humidity,depth)
local pos = Vector3.new(x,y,z)
  local temperature = MappedRouter.temperature
  local humidity = MappedRouter.humidity
  local depth =  not debug and MappedRouter.depth or MappedRouter.depthDebug
  return temperature and temperature:compute(pos), humidity and humidity:compute(pos)--, depth and depth:compute(pos)
end
function biome.newTable(temperature,humidity,continents,erosion,depth,weirdness)
    return {temperature,humidity,continents,erosion,depth,weirdness}
end
function biome.fromTable(t)
    return Climate.target(unpack(t))
end
biome.newTarget = Climate.target
function biome.getBiomeFromParams(c,e,w,t,h,d)
    return BiomeGetter:getBiomeFromTarget(biome.newTarget(t,h,c,e,d or 0,w))
end
function biome.generateBiomes(b2D,b3D,quadx,quadz)
    
end
function biome.generateBiomesMap(cx,cz)
    local offx,offz = gamesettings.getoffset(cx,cz)
    for x = 0,csx-1,4 do
        for z = 0,csx-1,4 do
            local rx,rz = offx+x,offz+z
            local continents,erosion,weirdness = biome.get2DNoiseValues(rx,rz)
            for y = 0,csy-1,4 do
                local temperature,humidity = biome.get3DNoiseValues(rx,y,rz)
                local target = Climate.target(temperature,humidity,continents,erosion,1)
            end
        end
    end
end
local w = 4
function biome.Lerp2D(cx,cz,quadx,quadz)
    debug.profilebegin("lerping base")
	local current = (SharedService:Get(`{cx},{cz}`)[2])
	local found = {}
	local t ={}
	local function get(x,z)
		local str = `{x},{z}`
        if not found[str] then
            found[str] = SharedService:Get(str)[2]
        end
		return found[str]
	end
	for qx =0,w-1 do
		local x = qx+4*quadx
		local xx = ((x % w + w) % w) / w
		for qz  =0,w-1 do
			local z = qz+4*quadz
			local zz = ((z % w + w) % w) / w
			local level00 = current
            local level10 = get(cx+1,cz)
            local level01 = get(cx,cz+1)
            local level11 = get(cx+1,cz+1)
            local level = lerp2Climate(level00,level10,level01,level11,xx,zz)
            table.insert(t,Vector2int16.new(settings.to1DXZ(x,z),level))
		end
	end
    debug.profileend()
	return t
end
return biome