local SS = {}
local event = (script:FindFirstChild("Event") or Instance.new("BindableEvent",script)) -- creates a bindable to tell if a new table is added
local destroyEvent = (script:FindFirstChild("DEvent") or Instance.new("BindableEvent",script)) 
destroyEvent.Name = "DEvent"
local chunk = require(game.ReplicatedStorage.Chunk)
local Downloads = {}
local timer = {}

local life_Span = 10 -- how long should data be cached for
local clear_Intervals = 2 -- how often should it be checked 
local last_Cleared = time()

function SS:Get(key)
    timer[key] = time()+life_Span+8
    return Downloads[key]
end
--removes data thats not needed anymore to avoid using too much memory 
function SS:Clear()
    local ctime = time()
    if last_Cleared<ctime then
        last_Cleared = ctime+clear_Intervals
    else
        return
    end
    for i,v in timer do
        if v >= ctime then continue end
        Downloads[i] = nil
        timer[i]  = nil
    end
end
function SS:Upload(key,value)
    self:Clear()
    if Downloads[key] then 
        if Downloads[key][2] == value[3] then
                event:Fire(key,-1)
            return 
        end
    end 
    Downloads[key] = {chunk.DeCompressVoxels(value[1],value[2]),value[3]}
    timer[key] = time() +life_Span
    event:Fire(key,value)
end

function SS:Listen()
    event.Event:Connect(function(key,value)
        if value == -1 then  timer[key] = time() +life_Span+8 return end 
        if Downloads[key] then 
            if Downloads[key][2] == value[3] then
                timer[key] = time() +life_Span+8
                return 
            end
        end 
        Downloads[key] = {chunk.DeCompressVoxels(value[1],value[2]),value[3]}
        timer[key] = time() +life_Span+8
        self:Clear()
    end)
    destroyEvent.Event:Connect(function(key)
        Downloads[key] = nil
        timer[key] = nil
    end)
    return SS
end

return SS