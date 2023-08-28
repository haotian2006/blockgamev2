--Handler Async Tasks and creation
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local GH = {}
local Worker = {}
local Workers = {}
local Index = 0
Worker.__index = Worker
local deafultAmount = 50
local IsServer = game:GetService("RunService"):IsServer()
local sharedservice = game:GetService("SharedTableRegistry")
local st = sharedservice:GetSharedTable("WORKERTASKS")
local mhworkers = Instance.new("Folder")
mhworkers.Name = "WorkerHolder"
mhworkers.Parent = if IsServer then game.ServerScriptService else game.Players.LocalPlayer:WaitForChild("PlayerScripts") 
function Worker.new(index)
   local clone = if IsServer then ReplicatedStorage.WorkerHolder.Server else ReplicatedStorage.WorkerHolder.Client
   clone = clone:Clone()
   clone.Name = index
   clone.Parent = mhworkers
   clone.Main.Enabled = true
   return clone
end
local inited = false
function GH:GetWorker()
    if #Workers == 0 then error("TABLE IS EMPTY") end 
    Index +=1
    if Workers[Index] then
        return Workers[Index]
    else
        Index = 0
        return self:GetWorker()
    end
end
local id = 0
function GH:GetId()
    id += 1
    if st[id] then
        return self:GetId()
    elseif id >= 32768 then
        id = 0
        return self:GetId()
    end
    return id 
end
local function SharedToNormal(shared,p)
    if typeof(shared) ~= "SharedTable" then
        return shared
    end
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
function GH:DoWork(...)
    local c = self:GetId()
    local worker:Actor = GH:GetWorker()
    worker:SendMessage("M",c,...)
    worker.DataHandler.Event:Wait()
    local data = st[c]
    st[c] = nil
    return SharedToNormal(data)
end
function GH:Init(amt)
    amt = amt or deafultAmount
    if inited then warn("WORKERS WAS INIT TWICE") return end 
    inited = true
    for i = 1,amt do
        local worker = Worker.new(i)
        table.insert(Workers,worker)
    end
end
return GH
