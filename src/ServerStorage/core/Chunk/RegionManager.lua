local Regions = {}

local RegionHelper = require(script.Parent.Generator.RegionHelper)
local DataHandler = require(game.ReplicatedStorage.Data)
local EntityUtils = require(game.ReplicatedStorage.Utils.EntityUtils)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)
local Communicator = require(script.Parent.Generator.Communicator)
local Config = require(script.Parent.Generator.Config)
local Generator = require(script.Parent.Generator)

local LoadedRegions = {}

local REGION_DISTANCE = 14
local Corners = {
    Vector3.new(REGION_DISTANCE,0,REGION_DISTANCE),
    Vector3.new(-REGION_DISTANCE,0,REGION_DISTANCE),
    Vector3.new(REGION_DISTANCE,0,-REGION_DISTANCE),
    Vector3.new(-REGION_DISTANCE,0,-REGION_DISTANCE)
}

local function UpdateRegion(region,toRemove)
    local chunksInRegion = RegionHelper.getAllChunksInRegion(region.X, region.Z)
    local AllChanges = {}
    local HadUpdates = false
    for _,chunk in chunksInRegion do
        local ChunkData = DataHandler.getChunkFrom(chunk)
        if not ChunkData then continue end 
        local Changes = ChunkData.Changes
        if not next(Changes) then continue end 
        HadUpdates = true
        local t = {}
        local idx = 1
        for i,v in Changes do
            t[idx] = Vector2.new(i,v)
            idx+=1
        end
        table.insert(AllChanges,{chunk,t})
        table.clear(Changes)
    end
    local RegionId = RegionHelper.getIndexFromRegion(region.X, region.Z)
    Communicator.sendMessageToId(RegionId,"UpdateRegion",region,HadUpdates and AllChanges,toRemove)
end

game.ReplicatedStorage.Events.DoSmt.OnServerEvent:Connect(function()
   UpdateRegion(Vector3.new(0,0))
end)

function Regions.addChunk(chunk)
    local Region = RegionHelper.getRegion(chunk)
    if not LoadedRegions[Region] then
        print("LOADED REGION",Region)
        local RegionId = RegionHelper.getIndexFromRegion(Region.X, Region.Z)
        Communicator.sendMessageToId(RegionId,"AddRegion",Region)
    end
    LoadedRegions[Region] = true
end
local Close = false
function Regions.Update(ov)
    if not ov and Close then return end 
    local toLoad = {}
    for _,player in game:GetService("Players"):GetPlayers() do
        local Entity = DataHandler.getEntityFromPlayer(player)
        if not Entity then continue end 
        local CurrentChunk = EntityUtils.getChunk(Entity)
        for _,offset in Corners do
            local loc = CurrentChunk + offset
            local Region = RegionHelper.getRegion(loc)
            toLoad[Region] = true
        end
    end
    local new,removed,same = OtherUtils.findKeyDiffrences(LoadedRegions, toLoad)
    for key in same do
        UpdateRegion(key)
    end

    for key in new do 
        local RegionId = RegionHelper.getIndexFromRegion(key.X, key.Z)
        Communicator.sendMessageToId(RegionId,"AddRegion",key)
    end
    
    for key in removed do 
        UpdateRegion(key,true)
    end
    LoadedRegions = toLoad
    Communicator.sendMessageToAll("UpdateAllRegions")
end

local Last = os.time()
game:GetService("RunService").Heartbeat:Connect(function(a0: number)  
    if os.time()-Last >= 30 then
       -- print("-----AUTOSAVE-----")
       -- Regions.Update()
        Last= os.time()
    end
end)
local AwaitingOnClose = {}
script.Parent.Generator.Event.Event:Connect(function(msgType,data)
    if msgType == "OnClose" then
        table.insert(AwaitingOnClose,data)
    end

    --Remote:FireAllClients(chunk,Builder.compress(shape))
end)

game:BindToClose(function()
    do
        return
    end
    Close = true
    --Regions.Update(true)
    while #AwaitingOnClose < Config.Actors do
        task.wait()
    end
    print("DONE")
end)
return Regions 