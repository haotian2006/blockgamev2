local layers = {}
local Classes = {}
local Sample = {}
local cache = {}
local cacheInterval = 10
local Utils = require(script.Parent.Parent.Parent.math.utils)
function layers.sample(layer,x,y,z,...)
    return Sample[layer[1] or layer.name](layer,x,y,z,...)
end
function layers.get(layer,x,y,z,...)
    local key = Vector3.new(x,y,z)
    if cache[layer] then 
        local a = cache[layer][key]
        if a then
            return a
        end
    else
        cache[layer] = {} 
    end
    local value = Sample[layer[1] or layer.name](layer,x,y,z,...)
    cache[layer][key] = value
    return value
end
function layers.clearCache()
    table.clear(cache)
end
function layers.load(name,fx)
    if fx.init then fx.init() end 
    Classes[name] = fx
    Sample[name] = fx.sample
end
function layers.createTemplate(name,seed,salt,parent,...)
    return {name,Utils.jenkins_hash(`{seed},{salt or 0}`),parent,...}
end
function layers.create(name,seed,salt,parent,...)
    if Classes[name].new then
        return Classes[name].new(seed,salt,parent,...)
    end
    return {name,Utils.jenkins_hash(`{seed},{salt or 0}`),parent,...}
end
local Connection
function layers.Init()
    if Connection then return end 
    for _,v in script:GetDescendants() do
        if v:IsA("ModuleScript") then
            layers.load(v.Name, require(v))
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
return table.freeze(layers)