local Layer = {}
local layers = {}
local allLayers = {}
local cacheInterval = 4
local cache = {}

--Get Caches the data as well while compute just computes it without caching 
function Layer.get(layer,Chunk,...)
    local key = Chunk
    local name = layer
    if cache[name] then 
        local a = cache[name][key]
        if a then return a end 
    else
        cache[name] = {} 
    end
    local value,shouldCache = layers[name[1]](layer,Chunk,...)
    if shouldCache ~= false then 
        cache[name][key] = value
    else
        cache[name][key] = nil
    end
    return value
end

function Layer.compute(layer,chunk,...)
    return layers[layer[1]](layer,chunk,...)
end

function Layer.create(name,parent,...)
    return {name,parent,...}
end

local Connection
function Layer.Init()
    if Connection then return end 
    for _,v in script:GetDescendants() do
        if v:IsA("ModuleScript") then
            allLayers[v.Name] = require(v)
            layers[v.Name] = require(v).compute
        end
    end
    local t = 0
    Connection = game:GetService("RunService").Heartbeat:Connect(function(dt: number)  
        t+=dt
        if t>= cacheInterval then
            table.clear(cache)
            t = 0
        end
    end)
end
return Layer
