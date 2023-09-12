local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local MH = {}
local Worker = {}
local Workers = {}

local InProgress = {}
local Index = 0
Worker.__index = Worker
local deafultAmount = 6
local Settings = require(game.ReplicatedStorage.GameSettings)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)

local st ={}
local mhworkers = Instance.new("Folder")
mhworkers.Name = "idk"
mhworkers.Parent = game.ServerScriptService

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
local pdata = {}
function Worker.new(index)
   local clone = script.Parent.Actor:Clone()
   clone.Name = index
   clone.Parent = mhworkers
   clone.MainG.Enabled = true
   clone.DataHandler.Event:connect(function(id,data)
        pdata[id] = data--SharedToNormal(sharedtable[id])
        coroutine.resume(st[id])
       -- sharedtable[id] = nil
   end)
   return clone
end
local inited = false

function MH:GetWorker(SPEICIAL)
    if #Workers == 0 then error("TABLE IS EMPTY") end 
    Index +=1
    if Workers[Index] then
        if not InProgress[Index] then
            return Workers[Index],Index
        end
        return self:GetWorker()
    else
        Index = 0
        task.wait()
        return self:GetWorker()
    end
end
local id = 0
function MH:GetId()
    id += 1
    if st[id] ~= nil then
        return self:GetId()
    elseif id >= 32768 then
        id = 0
        return self:GetId()
    end
    return id 
end
local SPEICALFUNCTIONS = {"ComputeChunk","GetBiomesstuffidkdebug"}
function MH:DoWork(func,...)
    local c = self:GetId()
    local worker:Actor,idx = MH:GetWorker()
    worker:SendMessage("M",c,func,...)
    st[c] = coroutine.running()
    coroutine.yield()
    local data = pdata[c]
     st[c] = nil
     pdata[c] = nil
    return data
end
function MH:Init(amt)
    amt = amt or deafultAmount
    if inited then warn("GENERATION WAS INITEDED TWICE") return end 
    inited = true
    for i = 1,amt do
        local worker = Worker.new(i)
        table.insert(Workers,worker)
        task.spawn(function()
            repeat
                task.wait()
            until worker.Init.Value == true
            worker:SendMessage('Init')
       end)
    end

    return MH
end

return MH
