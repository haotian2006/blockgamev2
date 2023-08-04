local ServerScriptService = game:GetService("ServerScriptService")
local GH = {}
local Worker = {}
local Workers = {}
local Index = 0
Worker.__index = Worker
local deafultAmount = 30
local Settings = require(game.ReplicatedStorage.GameSettings)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local GenHandler = require(game.ServerStorage.GenerationHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
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
function GH:DoWork(...)
    local worker:Actor = GH:GetWorker()
    worker:SendMessage("M",...)
    return worker.DataHandler.Event:Wait()
end
function GH:Init(amt)
    amt = amt or deafultAmount
    if inited then warn("GENERATION WAS INITEDED TWICE") return end 
    inited = true
    for i = 1,amt do
        local worker = Worker.new(i)
        table.insert(Workers,worker)
    end
end

function GH:CreateTerrain(cx,cz)
    return GH:DoWork("GenerateTerrain",cx,cz)
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
return GH
