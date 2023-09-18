local SharedTableRegistry = game:GetService("SharedTableRegistry")
local SharedT = SharedTableRegistry:GetSharedTable("SharedT")
local SS = {}
local event = (script:FindFirstChild("Event") or Instance.new("BindableEvent",script)) -- creates a bindable to tell if a new table is added
local Downloads = {}
local timer = {}

local life_Span = 10 -- how long should data be cached for
local clear_Intervals = 2 -- how often should it be checked 
local last_Cleared = time()
function SS:GetEvent()
    return event.Event
end
function SS:Get(key)
    timer[key] = time()+life_Span+4
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
    clear_Intervals = 1
    self:Clear()
    if Downloads[key] then  
        if timer[key]-5 <= time() then
            event:Fire(key,-1)
        end
        return 
    end 
    Downloads[key] = value
    timer[key] = time() +life_Span
    event:Fire(key,value)
end

function SS:Listen()
    event.Event:Connect(function(key,value)
        if value == -1 then  timer[key] = time() +life_Span +4 return end 
        if  Downloads[key] then 
            timer[key] = time() +life_Span+8
            return
         end 
        Downloads[key] = value
        timer[key] = time() +life_Span +4
        self:Clear()
    end)
    return SS
end

return SS