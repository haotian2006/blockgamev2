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
export type continents = number
export type erosion = number
export type weirdness = number
export type temperature = number
export type humidity = number
export type depth = number
function biome:Init(settings,MR)
    MappedRouter = MR
    local allbiomes = settings.biomes or {}
    BiomeGetter = MultiNoiseHandler.Evaluate(allbiomes)
    biome.INITED = true
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
  return temperature and temperature:compute(pos), humidity and humidity:compute(pos), depth and depth:compute(pos)
end
function biome.newTable(temperature,humidity,continents,erosion,depth,weirdness)
    return {temperature,humidity,continents,erosion,depth,weirdness}
end
function biome.fromTable(t)
    return Climate.target(unpack(t))
end
biome.newTarget = Climate.target
function biome.getBiomeFromParams(c,e,w,t,h,d)
    return BiomeGetter:getBiomeFromTarget(biome.newTarget(t,h,c,e,d,w))
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