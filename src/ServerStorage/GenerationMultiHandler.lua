local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local GH = {}
local Worker = {}
local Workers = {}
local SPEICALWorkers = {}
local InProgress = {}
local Index = 0
Worker.__index = Worker
local amtofspecial = 5
local deafultAmount = 3
local Settings = require(game.ReplicatedStorage.GameSettings)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local GenHandler = require(game.ServerStorage.GenerationHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local sharedservice = game:GetService("SharedTableRegistry")
local sharedtable = sharedservice:GetSharedTable("Generation")
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
        sharedtable[id] = nil
   end)
   return clone
end
local inited = false

function GH:GetWorker(SPEICIAL)
    local Workers = not SPEICIAL and Workers or SPEICALWorkers
    if #Workers == 0 then error("TABLE IS EMPTY") end 
    Index +=1
    if Workers[Index] then
        if not InProgress[Index] or not SPEICIAL  then
            return Workers[Index],Index
        end
        if SPEICIAL and Index <amtofspecial then 
            return Workers[Index],Index
        end
        return self:GetWorker(SPEICIAL)
    else
        Index = 0
        task.wait()
        return self:GetWorker(SPEICIAL)
    end
end
local id = 0
function GH:GetId()
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
function GH:DoWork(func,...)
    local SPEICIAL = table.find(SPEICALFUNCTIONS,func)
    local c = self:GetId()
    local worker:Actor,idx = GH:GetWorker(SPEICIAL)
    if SPEICIAL then 
        InProgress[idx] = true
    end
    worker:SendMessage("M",c,func,...)
    st[c] = coroutine.running()
    coroutine.yield()
    local data = pdata[c]
     st[c] = nil
     pdata[c] = nil
    if SPEICIAL then 
        InProgress[idx] = nil
    end
    return data
end
function GH:Init(amt)
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
            worker:SendMessage('Init',Settings.Seed)
       end)
    end
    for i =1,amtofspecial do
        local worker = Worker.new(i)
        table.insert(SPEICALWorkers,worker)
        task.spawn(function()
            repeat
                task.wait()
            until worker.Init.Value == true
            worker:SendMessage('Init',Settings.Seed,true)
       end)
    end
    return GH
end
local sizex,sizey = Settings.getChunkSize()
function GH:InterpolateDensity(cx,cz)
    local t ,s= {},{}
   -- lerp[`{cx},{cz}`] = table.create(Settings.maxChunkSize)
    local tasks,done = 0,0
    local thread = coroutine.running()
    local alldata = {}
    for x =0,1 do
        for z = 0,1 do
            tasks +=1
            local tk = tasks
            task.spawn(function()
                alldata[tk]=  GH:DoWork("LerpFinalXZ",cx,cz,x,z)
                done +=1
                if tasks == done*2 then
                    coroutine.resume(thread)
                end
            end)
            tasks +=1
        end
    end
    if tasks ~= done then coroutine.yield() end 
    for i,v in alldata do
        for i,v in v[1] do
            t[v.X] =  v.Y>0 and true or false
        end
        for i,v in v[2] do
            s[v.X] = v.Y
        end
    end
  --  lerp[`{cx},{cz}`] = nil
    return t,s--t
end
function GH:ComputeChunk(cx,cz)
    local data = GH:DoWork("ComputeChunk",cx,cz)
    return data
end
function GH:SmoothTerrian(cx,cz,data)
    return GH:DoWork("SmoothTerrian",cx,cz,data)
end
function GH:CreateTerrain(cx,cz)
    return GH:DoWork("GenerateTerrain",cx,cz)
end
function GH:GenerateSurfaceDensity(cx,cz)
    return GH:DoWork("GenerateSurfaceDensity",cx,cz)
end
function GH:SmoothDensity(cx,cz,data)
    return GH:DoWork("SmoothDensity",cx,cz,data)
end
function GH:GetBiomeValues(x,y,z)
    return GH:DoWork("GetBiomesstuffidkdebug",x,y,z)
end
function GH:GenerateCaves(cx,cz)
    local sx,sy,sz,ammount,Resolution = GenHandler.GetWormData(cx,cz)
    if sx == nil then return end 
    local data = GH:DoWork("GenerateCaves",cx,cz)
    local new = {}
    for chunk,chdata in data do
        local commaPos = string.find(chunk, ",")
        local cx = tonumber(string.sub(chunk, 1, commaPos - 1))
        local cy = tonumber(string.sub(chunk, commaPos + 1))
        for i,index in chdata do
            local x,y,z = Settings.to3D(index)
            x,y,z = Settings.convertchgridtoreal(cx,cz,x,y,z)
            GenHandler.sphere(new,Resolution,x,y,z)
        end
    end
    return new
end

return setmetatable(GH,{__index =function(self,key)
    GH[key] = function (self,...)
        return GH:DoWork(key,...)
    end
    return  GH[key] 
end})
