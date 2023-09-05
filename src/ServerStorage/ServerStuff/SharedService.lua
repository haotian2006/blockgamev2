local SharedTableRegistry = game:GetService("SharedTableRegistry")
local SharedT = SharedTableRegistry:GetSharedTable("SharedT")
local SS = {}
local event = (script:FindFirstChild("Event") or Instance.new("BindableEvent",script)) -- creates a bindable to tell if a new table is added
local Downloads = {}
local timer = {}

local life_Span = 5 -- how long should data be cached for
local clear_Intervals = 2 -- how often should it be checked 
local last_Cleared = time()
function SS:GetEvent()
    return event.Event
end
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
    self:Clear()
    Downloads[key] = value
    event:Fire(key,value)
end

function SS:Listen()
    event.Event:Connect(function(key,value)
        if  Downloads[key] then return end 
        Downloads[key] = value
        timer[key] = time() +life_Span
    end)
    return SS
end

return SS