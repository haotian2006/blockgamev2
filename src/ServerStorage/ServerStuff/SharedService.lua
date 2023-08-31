local SharedTableRegistry = game:GetService("SharedTableRegistry")
local SharedT = SharedTableRegistry:GetSharedTable("SharedT")
local SS = {}
local event = (script:FindFirstChild("Event") or Instance.new("BindableEvent",script))
local Downloads = {}
local timer = {}
local isMain = false
local function SharedToNormal(shared,p)
    if typeof(shared) ~= "SharedTable" then return shared end 
    p = p or {}
    for i,v in shared do
        if typeof(v) == "SharedTable" then
            p[i] = {}
            SharedToNormal(v,p[i])
        else
            p[i] = v
        end
    end
    return p
end
local timeout = 15
local clear_Intervals = 2
local last_Cleared = time()
function SS:GetEvent()
    return event.Event
end
function SS:DownloadData(key)
    local value = SharedToNormal(SharedT[key])
    timer[key] = time() +timeout
    Downloads[key] = value
    return  value
end
function SS:Get(key)
    timer[key] = time()+timeout
    return Downloads[key]
end
function SS:Clear()
    local ctime = time()
    if last_Cleared<ctime then
        last_Cleared = ctime+clear_Intervals
    end
    for i,v in timer do
        if v < ctime then
            Downloads[i] = nil
            timer[i]  = nil
        end
    end
end
function SS:GetOrDownload(key)
    self:Clear()
    return Downloads[key] and self:Get(key) or self:DownloadData(key)
end
function SS:Upload(key,value)
    SharedT[key] = value
    Downloads[key] = value
    event:Fire(key,value)
end

function SS:Listen()
    event.Event:Connect(function(key,value)
        if  Downloads[key] then return end 
        Downloads[key] = SharedToNormal(value)
    end)
    return SS
end

return SS