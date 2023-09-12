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
    timer[key] = time()+life_Span
    return Downloads[key]
end
--removes data thats not needed anymore to avoid using too much memory 
function SS:Clear()
    local ctime = time()
    if last_Cleared<ctime then
        last_Cleared = ctime+clear_Intervals
    end
    for i,v in timer do
        if v >= ctime then continue end
        Downloads[i] = nil
        timer[i]  = nil
    end
end
function SS:Upload(key,value)
    if Downloads[key] then return end 
    self:Clear()
    Downloads[key] = value
    timer[key] = time() +life_Span
    event:Fire(key,value)
end

function SS:Listen()
    event.Event:Connect(function(key,value)
        self:Clear()
        if  Downloads[key] then return end 
        Downloads[key] = value
        timer[key] = time() +life_Span
    end)
    destroyEvent.Event:Connect(function(key)
        Downloads[key] = nil
        timer[key] = nil
    end)
    return SS
end

return SS