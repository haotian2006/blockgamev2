local Layer = {}
local layers = {}
local allLayers = {}
local cacheInterval = 4
debug.setmemorycategory("CUBICAL LAYER CACHE ")
local cache = {}

local Events = require(game.ReplicatedStorage.Libarys.Signal)

function Layer.get(layer,Chunk,...)
    local key = Chunk
    local name = layer
    if cache[name] then 
        local a = cache[name][key]
        if a then
            if type(a) == "table" and a.__type then
                return a:Wait()
            else
                return a
            end
        end
    else
        cache[name] = {} 
    end
    local event = Events.new()
    cache[name][key] = event
    local value,Cahce = layers[name[1]](layer,Chunk,...)
    event:Fire(value)
    event:DisconnectAll()
    if Cahce ~= false then 
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
