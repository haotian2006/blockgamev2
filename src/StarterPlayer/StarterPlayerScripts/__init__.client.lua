
local qf = require(game.ReplicatedStorage.QuickFunctions)
local resource = require(game.ReplicatedStorage.ResourceHandler)
resource:Init()
require(game.ReplicatedStorage.BehaviorHandler):Init()
local bridge = require(game.ReplicatedStorage.BridgeNet)
local lp = game.Players.LocalPlayer
local EntityBridge = bridge.CreateBridge("EntityBridge")
--bridge.Start({})
local GetChunk = bridge.CreateBridge("GetChunk")
local datahandler = require(game.ReplicatedStorage.DataHandler)
local ErrorHandler = require(game.ReplicatedStorage.Libarys.ErrorHandler)
local toload = {}
local currentlyloading = {} 
local queued = {}


local RenderHandler = require(script.Parent.Render):Init()

for i,v in script.Parent.ClientStuff:GetChildren() do
    require(v)
end

function GetChunks(cx,cz)
    queued[cx..','..cz] = true
    game.ReplicatedStorage.Events.GetChunk:FireServer(cx,cz)
end
local chtoup = {}

bridge.CreateBridge("UpdateBlocks"):Connect(function(data)
   local function addtoup(x,y,z)
    local cx,cy,x,y,z = qf.GetChunkAndLocal(x,y,z)
    local chunk = datahandler.GetChunk(cx,cy)
    if not chunk then return end 
    chtoup[chunk]= chunk
    local cx,cz = chunk:GetNTuple()
    local v3 = Vector3.new(x,y,z)
    local isedge,edges = qf.CheckIfChunkEdge(v3.X,v3.Y,v3.Z)
    if isedge then
        local chx = datahandler.GetChunk(cx+edges.X,cz)
        local chz = datahandler.GetChunk(cx,cz+edges.Y)
        if edges.X ~= 0 and chx then
            chtoup[chx:GetNString()]= chx
        end
        if edges.Y ~= 0 and chz then
            chtoup[chz:GetNString()]= chz
        end
    end
   end
    for i,v in data.Remove or {} do
        local chunk = datahandler.RemoveBlock(v.X,v.Y,v.Z)
        addtoup(v.X,v.Y,v.Z)
    end
    for i,v in data.Add or {} do
        local coords =  v[1]
        datahandler.InsertBlock(coords.X,coords.Y,coords.Z,v[2])
        addtoup(coords.X,coords.Y,coords.Z)
    end
end)
local a = false

local deloaddistance = 14
local renderdistance = 11
function srender(p)
    for v,i in datahandler.LoadedChunks  do
		local splited = v:split(",")
		local vector = Vector2.new(splited[1],splited[2])*settings.ChunkSize.X*settings.GridSize
        local pv = Vector2.new(p.X,p.Z)
		if (vector-pv).Magnitude > deloaddistance*settings.ChunkSize.X*settings.GridSize then
           -- print()
            task.spawn( function()
                toload[v] = nil
                queued[v] = nil
         --       render.DeLoad(splited[1],splited[2])
            end)
        end
	end
    local cx1,cz1 = qf.GetChunkfromReal(qf.cv3type("tuple",p)) 
    local s= qf.GetSurroundingChunk(cx1,cz1,renderdistance)
    local passed = 0
    for i,v in qf.SortTables(p,s) do
        v = v[1]
        passed+=1
        local cx,cz = qf.cv2type("tuple",v)
        local ccx,ccz =  qf.GetChunkfromReal(qf.cv3type("tuple",p)) 
        if (ccx ~= cx1 or ccz ~= cz1 )and passed>=6 then
          --  break
        end
        if not datahandler.GetChunk(cx,cz) and not queued[cx..','..cz] then
            GetChunks(cx,cz)
            task.wait(.02)
        end
    end
end

game.ReplicatedStorage.Events.LOAD:FireServer()
task.delay(2,function()
    srender(Vector3.new(0, 0, 0)*3)
end)
--RenderHandler.requestNearby(Vector3.new(342, 90, -77))