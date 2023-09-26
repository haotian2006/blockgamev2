local WorldgenRegistries = require(script.Parent.Parent.WorldgenRegistries)
local indentifier = require(script.Parent.Parent.Parent.core.Identifier)
local NN = require(script.Parent.Parent.Parent.math.noise.NormalNoise)
local Perline = require(script.Parent.Parent.Parent.math.noise.PerlineNoise)
local Radomlib = require(script.Parent.Parent.Parent.math.RandomObject)
local Random 
local noises = {

}
local Feature = {}
local function evalNoise(noise,useNormal,offset)
    if type(noise) =="string" then
        local str = `{noise}{not useNormal}{offset or 0}`
        if noises[str] then return noises[str] end 
        local settings =   WorldgenRegistries.NOISE:get(indentifier.parse(noise))
        useNormal = useNormal or settings.useNormal
        offset = offset or settings.offset
        local obj
        local rand =Random
        if offset then
            local seed= Random.seed
            rand = Radomlib.new(seed + offset)
        end
        if useNormal then           
            obj =  NN.new(rand,settings)
        else
             obj = Perline.new(rand,settings.firstOctave,settings.amplitudes)
        end
        noises[str] = obj 
        return obj 
    elseif type(noise) == "table" then
        local setting = noise.noiseSettings 
        offset =  noise.offset
        local rand =Random
        if offset then
            local seed= Random.seed
            rand = Radomlib.new(seed + offset)
        end
        if type(setting) == "string" then
            local data = evalNoise(setting,noise.useNormal,offset)
        elseif noise.amplitudes then
            if useNormal then
                return NN.new(rand,noise)
            end
            return Perline.new(rand,noise.firstOctave,noise.amplitudes)
        else
            if useNormal then
                return NN.new(rand,setting)
            end
            return Perline.new(rand,setting.firstOctave,setting.amplitudes)
        end
    end
end
local function  Evaluate(feature)
    if not feature.noiseSettings then warn(`{feature.name} is missing noiseSettings`) end 
    feature.noiseFunction = evalNoise(feature.noiseSettings)
    return feature
end
function Feature.Evaluate(info,rand)
    Random = Random or rand
    for i,v in info do
        Evaluate(v)
    end
end
function Feature.EvaluateOne(info)
   return Evaluate(info)
end
return Feature