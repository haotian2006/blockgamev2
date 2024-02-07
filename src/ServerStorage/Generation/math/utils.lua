local Utils = {}

function Utils.jenkins_hash(key)
    local hash = 0
    for i = 1, #key do
        hash = hash + string.byte(key, i)
        hash = hash + bit32.lshift(hash, 10)
        hash = bit32.bxor(hash, bit32.rshift(hash, 6))
    end
    hash = hash + bit32.lshift(hash, 3)
    hash = bit32.bxor(hash, bit32.rshift(hash, 11))
    hash = hash + bit32.lshift(hash, 15)
    return hash
end

function Utils.mixSeed(seed,x)
    seed = seed*653427+46876345
    seed += x
    if seed > 2147483640 then
        return seed % 2147483640
    end
    return seed 
end

function Utils.createRandom(seed,x,z,salt)
    if salt then
        seed = Utils.jenkins_hash(`{seed}_{salt}`)
    end
    seed = Utils.mixSeed(seed,x)
    seed = Utils.mixSeed(seed,z*231)
    return Random.new(seed)
end

function Utils.choose(random:Random,x,y)
    return if random:NextInteger(1, 2) == 1 then x else y
end
function Utils.choose4(random:Random,a,b,c,d)
    local r =  random:NextInteger(0, 3)
    return if r == 0 then a else if r == 1 then b else if r == 2 then c else d
end
local function toTwosComplement(n)
    return 4294967296 + n 
end

function Utils.band(x, y)
    if x < 0 then x = toTwosComplement(x) end
    if y < 0 then y = toTwosComplement(y) end
    local result = bit32.band(x, y)
    if result >= 2147483648 then 
        result = result - 4294967296 
    end
    return result
end

function Utils.bor(x, y)
    if x < 0 then x = toTwosComplement(x) end
    if y < 0 then y = toTwosComplement(y) end
    local result = bit32.bor(x, y)
    if result >= 2147483648 then 
        result = result - 4294967296 
    end
    return result
end
function Utils.lerp(a, b, c)
    return b + a * (c - b)
end
function Utils.lerp2(a, b, c, d, e, f)
    local x = c + a * (d - c)
    return x+ b* (e + a * (f- e)- x)
end
function Utils.lerp3(a, b, c, d, e, f, g, h, i, j, k)
    local x1 =  d + a * (e - d)
    local x =   x1 + b * ((f + a * (g - f)) - x1)
    local y1 =  h + a * (i -h)
    return    x + c * (( y1 + b * ((j + a * (k - j)) - y1)) - x)
end

function Utils.clampedLerp(a, b, c)
    if c < 0 then 
        return a
    elseif c > 1 then
        return b
    else
        return (a + c * (b-a))
    end
end

function Utils.inverseLerp(a, b, c)
    return (a - b) / (c - b)
end

function Utils.clampedMap(value, from, to, fValue, tValue)
    return Utils.clampedLerp(fValue, tValue, Utils.inverseLerp(value, from, to))
end

Utils.precentageCache4 = {}
Utils.YprecentageCache8 = {}
do
    for x = 1,4 do
        Utils.precentageCache4[x] = (((x-1) % 4 + 4) % 4) / 4
    end
    for y = 1,256 do
        Utils.YprecentageCache8[y] = (((y-1) % 8 + 8) % 8) / 8
    end
end
return Utils