local self = require(game.ReplicatedStorage.DataHandler)

local HttpService = game:GetService("HttpService")
local runservice = game:GetService("RunService")
local ChunkObj = require(game.ReplicatedStorage.Chunk)
local settings = require(game.ReplicatedStorage.GameSettings)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local EntityBridge = bridge.CreateBridge("EntityBridge")
local sharedservice = require(game.ServerStorage.ServerStuff.SharedService)
local GetChunk = bridge.CreateBridge("GetChunk")
local isserver = runservice:IsServer()
local sing = require(game.ReplicatedStorage.Libarys.Signal)
function self.AddToLoad(cx,cz,stuff,op2)
    local c = self.GetChunk(cx,cz,'2')
    c:AddToLoad(stuff,op2)
end
local InProgress = {}
function self.GetChunk(cx,cz,create)
    local str = cx..','..cz
    if not self.LoadedChunks[str] and create then
        if InProgress[str] then
            InProgress[str]:Wait()
            return self.LoadedChunks[str] 
        end
        InProgress[str] = sing.new()
        self.CreateChunk(nil,cx,cz)
        InProgress[str]:DisconnectAll()
        InProgress[str] = nil
    end
    return self.LoadedChunks[str] 
end

local ublock = bridge.CreateBridge("UpdateBlocks")

function self.PlaceBlockGLOBAL(x,y,z,data)
    self.InsertBlock(x,y,z,data)
    ublock:FireAll({Add = {{Vector3.new(x,y,z),data}}})
end
function self.RemoveBlockGlobal(x,y,z,data)
    self.RemoveBlock(x,y,z)
    ublock:FireAll({Remove = {Vector3.new(x,y,z)}})
end

self.TempChunks = {}
local TempChunks = self.TempChunks

local NoiseQueue = {}
local LerpQueue = {}
local ColorQueue = {}
local FeatureQueue = {}
local FeatureNoiseQueue = {}
local FeatureLerpQueue = {}
local ReadyToSend = {}
local Requested = {}
debug.setmemorycategory("DataHandler Server")

local MAX_TERRIAN = 5
local function SendToClients()
    local compressed = {}
    local key = {}
    for player,data in ReadyToSend do
        if not game.Players:FindFirstChild(player.Name) then ReadyToSend[player] = nil continue end 
        local tosend = {}
        for _,v in data do
            local str = tostring(v)
            if not compressed[str] then 
                local cx,cz = v()
                debug.profilebegin("compress")
                compressed[str] = v:CompressVoxels(key)
                debug.profileend()
            end
            tosend[str] = compressed[str]
        end
        table.clear(data)
        game.ReplicatedStorage.Events.GetChunk:FireClient(player,tosend,key)
    end
end
local function AddToTable(idx)
    for i,v in Requested[idx] do  
        ReadyToSend[v] = ReadyToSend[v] or {}
        table.insert(ReadyToSend[v],TempChunks[idx])
    end
end

local function GetTempString(x,y)
    return `{x},{y}`
end
local function GILQ(x,y)
    return LerpQueue[GetTempString(x,y)]
end

local once = false
local function FeatureAdd(chunk)
    chunk:InsertFeatures()
    AddToTable(tostring(chunk))
    self.insertChunk(chunk)
end
local function FeatureLerp(chunk)
    chunk:LerpFeatureNoise()
    FeatureQueue[tostring(chunk)] = chunk
end
local function FeatureNoise(chunk)
    if chunk.generatingStructure then return end
    chunk.generatingStructure = true 
    chunk:ComputeFeatureNoises()
    FeatureLerpQueue[tostring(chunk)] = chunk
end

local function Color(chunk)
    local cx,cz = chunk:GetNTuple()
    chunk:Color()
    game.ReplicatedStorage.ServerInfo.ChunksLoaded.Value +=1
    chunk.Generated = true 
    FeatureNoiseQueue[tostring(chunk)] = chunk
    return true
end
local function Lerp(chunk)
    local cx,cz = chunk:GetNTuple()
    local c10,c01,c11 = GILQ(cx+1,cz),GILQ(cx,cz+1),GILQ(cx+1,cz+1)
    if not (c10 and c01 and c11 ) then return end
    chunk.Lerping = true
    sharedservice:Upload(chunk:GetUploadData())
   sharedservice:Upload(c10:GetUploadData())
   sharedservice:Upload(c01:GetUploadData())
   sharedservice:Upload(c11:GetUploadData())
   chunk:LerpValues()
   if chunk.PreValues[3] ~= c10.PreValues[3]  ~= c01.PreValues[3] ~=c11.PreValues[3]  then
    chunk:LerpBiome()
   end
   ColorQueue[tostring(chunk)] = chunk
end
local function GenerateNoise(chunkStr)
    if TempChunks[chunkStr] then 
        if TempChunks[chunkStr].Generated then
            AddToTable(chunkStr)
        end
        return
    end 
    local cx,cz = unpack(string.split(chunkStr,","))
    cx,cz = tonumber(cx),tonumber(cz)
    local chunkObj = ChunkObj.new(cx,cz)
    TempChunks[chunkStr] = chunkObj
    local data = chunkObj:GenerateNoiseValues()
    LerpQueue[chunkStr] = chunkObj
end
local function HandleFeatures()
    for i,v in FeatureQueue do
        task.spawn(FeatureAdd,v)
        FeatureQueue[i] = nil
    end
end

local function HandleFeatureLerpQueue()
    for i,v in FeatureLerpQueue do
        task.spawn(FeatureLerp,v)
        FeatureLerpQueue[i] = nil
    end
end

local function HandleFeatureNoiseQueue()
    for i,v in FeatureNoiseQueue do
        task.spawn(FeatureNoise,v)
        FeatureNoiseQueue[i] = nil
    end
end

local function HandleLerpQueue()
    for i,v in LerpQueue do
        if  v.Lerping  then continue end 
        task.spawn(function()
            Lerp(v)
        end)
    end
end
local function HandleNoiseQueue()
    for i,v in NoiseQueue do
        task.spawn(GenerateNoise,v)
        table.remove(NoiseQueue,i)
    end
end
local function HandleColorQueue()
    for i,v in ColorQueue do
        task.spawn(Color,v)
        ColorQueue[i] = nil
    end
end
runservice.Heartbeat:Connect(function(dt)
    SendToClients()
    HandleFeatures()
    HandleFeatureLerpQueue()
    HandleFeatureNoiseQueue()
    HandleColorQueue()
    HandleLerpQueue()
    HandleNoiseQueue()
end)

game.ReplicatedStorage.Events.GetChunk.OnServerEvent:Connect(function(player,cx,cz)
    if cx > 32767 or cx < -32768 or cz > 32767 or cz < -32768 then warn("REACHED BORDER") return end 
    local new = self.GetChunk(cx,cz)
    local idx = `{cx},{cz}`
    Requested[idx] = Requested[idx] or {}
    table.insert( Requested[idx] ,player)
    table.insert(NoiseQueue,idx)
 end)

return {}