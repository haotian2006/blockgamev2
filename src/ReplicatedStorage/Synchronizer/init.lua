local Synchronizer = {}

local RunService = game:GetService("RunService")
local SynchronizerShared = game:GetService("SharedTableRegistry"):GetSharedTable("Synchronizer")

local ISACTOR = true
local ISCLIENT = RunService:IsClient()

local BINDABLE:BindableFunction = script.Bindable
local REMOTE:RemoteFunction = script.Remote

local Data = {}
local AwaitingThreads = {}

function Synchronizer.requestData(for_)
    if Data[for_] then return Data[for_] end 
    local running = coroutine.running()
    AwaitingThreads[for_] = AwaitingThreads[for_] or {}
    table.insert(AwaitingThreads[for_],running)
    return coroutine.yield()
end

local requestData = Synchronizer.requestData

function Synchronizer.setData(for_,data)
    Data[for_] = data
    for i,v in AwaitingThreads[for_] or {} do
        task.spawn(v,data)
    end
    AwaitingThreads[for_] = nil
end

function Synchronizer.getDataClient(for_)
    return REMOTE:InvokeServer(for_)
end

function Synchronizer.getDataActor(for_)
    return BINDABLE:Invoke(for_)
end

function Synchronizer.isActor()
    return ISACTOR
end

function Synchronizer.isClient()
    return ISCLIENT
end

function Synchronizer.Init() -- We assume that only main will call this
    if SynchronizerShared.Init then return warn("Attempted to Init From an Actor") end
    SynchronizerShared.Init = true

    ISACTOR = false
    BINDABLE.OnInvoke = requestData
    if ISCLIENT then return Synchronizer end 
    REMOTE.OnServerInvoke = function(player,from)
        return requestData(from)
    end
    return Synchronizer
end

return table.freeze(Synchronizer) 