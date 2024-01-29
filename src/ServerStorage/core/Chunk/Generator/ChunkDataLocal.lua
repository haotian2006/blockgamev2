local Config = require(script.Parent.Config)
local Chunk = require(script.Parent.LocalChunk)
local MaxTime =  Config.MaxTimeDebris
local Storage = {}

local Stack = require(game.ReplicatedStorage.Libarys.DataStructures.Stack)

local DESTROY_INTERVAL = 10

local DestroyStack = Stack.new(10000)

local Chunks = {}

local function OnDestroy(chunk)
    local obj = Chunks[chunk]
    if not obj then return end 
    if obj[2] or obj[3] then
        obj[1] = task.delay(MaxTime,OnDestroy,chunk)
        obj[2] = false
        return
    end
    Chunks[chunk] = nil
    Stack.push(DestroyStack, obj)
end

function Storage.add(name,value)
    value[1] = task.delay(MaxTime, OnDestroy,name)
    Chunks[name] = value
end

function Storage.pause(name)
    local object = Chunks[name]
    if not object then return end 
    local t = object[1]
    if t then
        task.cancel(t)
    end
    object[3] = true
    object[1] = nil
end

function Storage.resume(name)
    local object = Chunks[name]
    if not object then return end 
    object[1] = object[1] or task.delay(MaxTime,OnDestroy,name)
    object[2] = true
    object[3] = false
end



function Storage.remove(name)
    local object = Chunks[name]
    if not object then return end 
    local t = object[1]
    if t then
        task.cancel(t)
    end
    object[2] = false
    OnDestroy(name)
end

function Storage.getSize()
    local count = 0
    for i,v in Chunks do
        count +=1
    end
    return count
end

function Storage.get(name)
    local a = Chunks[name]
    if not a then return  end 
    a[2] = true
    return a
end

local sharedBuffer = buffer.create( 4*8*256*8)
buffer.fill(sharedBuffer, 0,255,4*8*256*8)

function Storage.getFeatureBuffer(chunk)
    local old = Storage.getOrCreate(chunk)
    if not old.FeatureBuffer then
        Chunk.initFeatureBuffer(old)
    end
    return old.FeatureBuffer
end

function Storage.getCarvedBuffer(chunk)
    local old = Storage.getOrCreate(chunk)
    if old.FCarve then
        return sharedBuffer
    end
    if not old.Carved then
        Chunk.initCarveBuffer(old)
    end
    return old.Carved
end

function Storage.getOrCreate(name)
    local a = Chunks[name] 
    if not a then 
        local chunk = Chunk.new(name)
        Storage.add(name, chunk )
        return chunk
    end 
    a[2] = true
    return a
end

game:GetService("RunService").Heartbeat:Connect(function()
    for i = 1,DESTROY_INTERVAL do
        local item = Stack.pop(DestroyStack)
        if not item then break end 
        table.clear(item)
    end
end)

return Storage