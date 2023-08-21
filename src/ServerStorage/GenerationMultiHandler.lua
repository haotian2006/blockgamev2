local ServerScriptService = game:GetService("ServerScriptService")
local GH = {}
local Worker = {}
local Workers = {}
local Index = 0
Worker.__index = Worker
local deafultAmount = 50
local Settings = require(game.ReplicatedStorage.GameSettings)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local GenHandler = require(game.ServerStorage.GenerationHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local sharedservice = game:GetService("SharedTableRegistry")
local st 
local mhworkers = Instance.new("Folder")
mhworkers.Name = "idk"
mhworkers.Parent = game.ServerScriptService
function Worker.new(index)
   local clone = script.Parent.Actor:Clone()
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
    if inited then warn("GENERATION WAS INITEDED TWICE") return end 
    st = SharedTable.new()
    sharedservice:SetSharedTable("Generation",st)
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
