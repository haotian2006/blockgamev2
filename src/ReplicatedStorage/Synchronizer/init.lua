local Synchronizer = {}


local RunService = game:GetService("RunService")
local SynchronizerShared = game:GetService("SharedTableRegistry"):GetSharedTable("Synchronizer")

local ISACTOR = true
local ISCLIENT = RunService:IsClient()

local Options = Instance.new("DataStoreGetOptions")
Options.UseCache = false

local DataStore
if not ISCLIENT then 
    local DataStoreService = game:GetService("DataStoreService")
    DataStore = DataStoreService:GetDataStore("tes2t",1)
end

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

function Synchronizer.getSavedData(for_)
    local sus,info = pcall(function()
        return DataStore:GetAsync(`Synchronize-{for_}`,Options)
    end)
    if not sus then
        warn(info)
        return 
     end
     print(for_,info)
    return info
end

function Synchronizer.updateSavedData(for_,ToSave)
     task.spawn(function()
        local sus,er = pcall(function()
            DataStore:SetAsync(`Synchronize-{for_}`,ToSave)
         end)
         if not sus then
            warn(er)
         end
     end)
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