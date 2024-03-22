local Synchronizer = {}


local RunService = game:GetService("RunService")
local SynchronizerShared = game:GetService("SharedTableRegistry"):GetSharedTable("Synchronizer")

local ISACTOR = true
local ISCLIENT = RunService:IsClient()

local Options = Instance.new("DataStoreGetOptions")
Options.UseCache = false

local DataStore

local BINDABLE:BindableFunction = script.Bindable
local REMOTE:RemoteFunction = script.Remote

local Data = {}
local AwaitingThreads = {}
local Client_Modifier = {}

function Synchronizer.setClientModifier(for_,callback)
    Client_Modifier[for_] = callback
end

function Synchronizer.requestData(for_,fromClient)
    local data = Data[for_]
    if data then 
        if Client_Modifier[for_] and fromClient then
            return Client_Modifier[for_](data)
        end
        return data
     end 
    local running = coroutine.running()
    AwaitingThreads[for_] = AwaitingThreads[for_] or {}
    table.insert(AwaitingThreads[for_],running)

    data = coroutine.yield()
    if Client_Modifier[for_] and fromClient then
        return Client_Modifier[for_](data)
    end
    return data
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
    if not DataStore then return nil end 
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
    if not DataStore then return end 
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

function Synchronizer.Init(Config) -- We assume that only main will call this
    if SynchronizerShared.Init then return warn("Attempted to Init From an Actor") end
    SynchronizerShared.Init = true
    Config = Config or {}
    local guid = Config.WorldGuid
    if  guid and not ISCLIENT and Config.SavingEnabled then 
        local DataStoreService = game:GetService("DataStoreService")
        DataStore = DataStoreService:GetDataStore("WORLD",guid)
    end

    ISACTOR = false
    BINDABLE.OnInvoke = requestData
    if ISCLIENT then return Synchronizer end 
    REMOTE.OnServerInvoke = function(player,from)
        return requestData(from,true)
    end
    return Synchronizer
end

return table.freeze(Synchronizer) 