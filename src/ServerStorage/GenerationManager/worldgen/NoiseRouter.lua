
local Holder
local NormalNoise
local DensityFunction
local WorldgenRegistries
local hash
local a = false
if not a then 
    a = true
    Holder =require(script.Parent.Parent.core.Holder)
    hash = require(script.Parent.Parent.math.Hash)
end
local NoiseRouter = {}
function NoiseRouter:Init()
    NormalNoise = require(script.Parent.Parent.math.noise.NormalNoise)
    DensityFunction = require(script.Parent.DensityFunction)
    WorldgenRegistries = require(script.Parent.WorldgenRegistries)
end
local function fieldParser(obj)
    return DensityFunction:GetClass("HolderHolder").new(Holder.parser(WorldgenRegistries.DENSITY_FUNCTION, DensityFunction.Evaluate)(obj))
end

function NoiseRouter.Evaluate(obj)
    local root = obj or {}
    local data = {
        barrier = fieldParser(root.barrier),
        fluidLevelFloodedness = fieldParser(root.fluid_level_floodedness),
        fluidLevelSpread = fieldParser(root.fluid_level_spread),
        lava = fieldParser(root.lava),
        veinToggle = fieldParser(root.vein_toggle),
        veinRidged = fieldParser(root.vein_ridged),
        veinGap = fieldParser(root.vein_gap),

        temperature = fieldParser(root.temperature),
        vegetation = fieldParser(root.vegetation),
        continents = fieldParser(root.continents),
        erosion = fieldParser(root.erosion),
        depth = fieldParser(root.depth),
        ridges = fieldParser(root.ridges),
        
        initialDensityWithoutJaggedness = fieldParser(root.initial_density_without_jaggedness),
        finalDensity = fieldParser(root.final_density),

        initalDensity = fieldParser(root.inital_Density),
        factor = fieldParser(root.factor),
        offset = fieldParser(root.offset),
        xzOrder = {}
    }
    if obj.xzOrder then
        for i,v in obj.xzOrder do
            data.xzOrder[i] = fieldParser(v)
        end
    end
    return data
end

function NoiseRouter.create(router)
    return {
        barrier = DensityFunction.Constant.ZERO,
        fluidLevelFloodedness = DensityFunction.Constant.ZERO,
        fluidLevelSpread = DensityFunction.Constant.ZERO,
        lava = DensityFunction.Constant.ZERO,
        veinToggle = DensityFunction.Constant.ZERO,
        veinRidged = DensityFunction.Constant.ZERO,
        veinGap = DensityFunction.Constant.ZERO,

        temperature = DensityFunction.Constant.ZERO,
        vegetation = DensityFunction.Constant.ZERO,
        continents = DensityFunction.Constant.ZERO,
        erosion = DensityFunction.Constant.ZERO,
        depth = DensityFunction.Constant.ZERO,
        ridges = DensityFunction.Constant.ZERO,

        initialDensityWithoutJaggedness = DensityFunction.Constant.ZERO,
        finalDensity = DensityFunction.Constant.ZERO,

        initalDensity =  DensityFunction.Constant.ZERO,
        factor = DensityFunction.Constant.ZERO,
        offset = DensityFunction.Constant.ZERO,

        xzOrder = {},
        unpack(router),
    }
end

function NoiseRouter.mapAll(router, visitor)
    local data = {
        barrier = DensityFunction.Constant.ZERO,
        fluidLevelFloodedness = DensityFunction.Constant.ZERO,
        fluidLevelSpread = DensityFunction.Constant.ZERO,
        lava = DensityFunction.Constant.ZERO,
        veinToggle = DensityFunction.Constant.ZERO,
        veinRidged = DensityFunction.Constant.ZERO,
        veinGap = DensityFunction.Constant.ZERO,

        temperature = router.temperature:mapAll(visitor),
        vegetation = router.vegetation:mapAll(visitor),
        continents = router.continents:mapAll(visitor),
        erosion = router.erosion:mapAll(visitor),
        depth = router.depth:mapAll(visitor),
        ridges = router.ridges:mapAll(visitor),

        initialDensityWithoutJaggedness = router.initialDensityWithoutJaggedness:mapAll(visitor),
        finalDensity = router.finalDensity:mapAll(visitor),

        initalDensity =  router.initalDensity:mapAll(visitor),
        factor = router.factor:mapAll(visitor),
        offset = router.offset:mapAll(visitor),
        xzOrder = {}
    }
    if router.xzOrder then
        for i,v in router.xzOrder do
            data.xzOrder[i] = v:mapAll(visitor)
        end
    end
    return data
end

local noiseCache = {}
function NoiseRouter.instantiate(random, noise)
    local key = noise:key()
    if not key then
        error('Cannot instantiate noise from direct holder')
    end
    key = tostring(key)
    local cached = noiseCache[key]
    if cached[1] == random.seed then
        return cached[2]
    end

    local result = NormalNoise.new(random:FromHashOf(key), noise:value())
    noiseCache[key] = {random.seed,result}
    return result
end

return NoiseRouter
