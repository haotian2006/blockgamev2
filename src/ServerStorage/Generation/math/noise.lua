local Noise = {}
local Utils = require(script.Parent.utils)
local BasicNoise = {}

function BasicNoise.new(seed,salt)
    if salt then
        seed = Utils.jenkins_hash(`{seed}_{salt}`)
    end
    local RandomObject =Random.new(seed)
    return Vector3.new(RandomObject:NextNumber(-1000,1000),RandomObject:NextNumber(-1000,1000),RandomObject:NextNumber(-1000,1000))
end

function BasicNoise.sample(self,x,y,z)
   return math.noise(x+self.X,y+self.Y,z+self.Z)
end

Noise.newBasic = BasicNoise.new
Noise.basicSample = BasicNoise.sample

function Noise.new(seed,firstOctave,amplitudes,persistance,lacunarity,salt)
    local inputFactor = 2^firstOctave
    local valueFactor = 2^ (#amplitudes - 1) / ((2^ #amplitudes) - 1)
    local self = {amplitudes,inputFactor,valueFactor,table.create(#amplitudes,false),persistance or .5,lacunarity or 2}
    for i = 1, #amplitudes do
        if amplitudes[i] == 0.0 then continue end 
        local octave = firstOctave + i 
        self[4][i] = BasicNoise.new(Utils.jenkins_hash(`Octave_{octave}_{seed}`),salt)
    end
    return self
end

function Noise.parse(seed,setting)
    return Noise.new(seed, setting.firstOctave, setting.amplitudes, setting.persistance, setting.lacunarity,setting.salt)
end

function Noise.sample(self,x,y,z)
    local inputFactor = self[2]
    local valueFactor = self[3]
    local value = 0
    local persistance = self[5]
    local lacunarity  = self[6]
    x,y,z = x or 0, y or 0, z or 0
    for i,basicNoise in self[4] do
        if basicNoise then 
            local ampt = self[1][i] or 1
            value += ampt*valueFactor*BasicNoise.sample(basicNoise, x*inputFactor, y*inputFactor, z*inputFactor)
        end 
        valueFactor*=persistance
        inputFactor*=lacunarity
    end

    return value
end

return Noise