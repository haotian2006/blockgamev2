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
mhworkers.Parent = script

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
   local clone = script.Parent.Parent.Actor:Clone()
   clone.Name = index
   clone.Parent = mhworkers
   clone.MainR.Enabled = true
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
        return Workers[Index],Index
    else
        Index = 0
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

function MH:CullChunk(cx,cz)
    local t = table.create(8*8*256,false)
     local tasks,done = 0,0
     local thread = coroutine.running()
     local alldata = {}
     for x =0,1 do
         for z = 0,1 do
             tasks +=1
             local i = tasks
             local tk = Vector2.new(x,z)
             task.spawn(function()
                 alldata[i]= MH:DoWork("cullSection",cx,cz,x,z)
                 done +=1
                 if 4 == done then
                     coroutine.resume(thread)
                 end
             end)

         end
     end
     if 4 ~= done then coroutine.yield() end 
     for i =1,4 do
        local a = alldata[i] 
        for i,v in a do
            t[v.X] = v.Y
        end
     end
    return t  
    --  local ofx,ofy = Settings.getoffset(cx,cz)
    --  local m = Instance.new("Model")
    --  for idx in t do
    --     local p = Instance.new("Part")
    --     p.Size = Vector3.new(3,3,3)
    --     p.Anchored = true
    --     local x,y,z = Settings.to3D(idx)
    --     p.Position = Vector3.new(x+ofx,y,z+ofy)*3
    --     p.Parent = m
    --  end
    --  m.Parent = workspace
end

return MH
