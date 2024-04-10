 

local Events = game.ReplicatedStorage.Events.Block
local BlockR:RemoteFunction = Events.Client 
local Update:RemoteEvent = Events.Update
local CubicalEvents = require(Events.Parent)

local RunService = game:GetService("RunService")

local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Chunk = require(game.ReplicatedStorage.Chunk)
local RenderHandler = require(script.Parent.Parent.chunk.Rendering.Handler)
local Data = require(game.ReplicatedStorage.Data)
local BlockBreaking = require(script.Parent.Parent.Rendering.BlockBreaking)
local Block = {}
local Breaking = {}

function Block.placeHoldingBlock(x,y,z)
    return BlockR:InvokeServer(Vector3.new(x,y,z))
end

CubicalEvents.UpdateBlock.listen(function(data)
    local loc,id = unpack(data)
    local x,y,z = loc.X,loc.Y,loc.Z
    local cx,cz,lx,ly,lz = ConversionUtils.gridToLocalAndChunk(x, y, z)
    local chunk = Data.getChunk(cx,cz)
    if not chunk then  return false end
    Chunk.insertBlockAt(chunk, lx,ly,lz, id)
    RenderHandler.blockUpdate(x, y, z)
    return true
end)

local function stopBreaking(guid)
    Breaking[guid] = nil
end

local function startedBreaking(guid,location,mul,time)
    local data = {
        Guid = guid,
        Multiplier = mul,
        BreakTime = time,
        Location = location,
        Progress = 0,
    }
    if Breaking[guid] then
        stopBreaking(guid)
    end
    Breaking[guid] = data
end


local function UpdateOne(data,dt)
    local Multiplier = data.Multiplier
    local BreakTime = data.BreakTime
    local Location = data.Location
    local block = Data.getBlock(Location.X,Location.Y,Location.Z)
    if block == 0 then 
        stopBreaking(data.Guid)
        return 
    end
    data.Progress += dt*Multiplier
    if data.Progress >= BreakTime then
        --stopBreaking(data.Guid)
    end
    local percentage = BreakTime/(BlockBreaking.getNumOfFrames())
    local Frame = data.Progress //percentage+1
    return Location,Frame
end

CubicalEvents.StartBreakingBlockClient.listen(function(data: {string}?)  
    if not data then return end 
    startedBreaking(unpack(data))
end)

CubicalEvents.StopBreakingBlock.listen(function(data: string?)  
    if not data then return end 
    stopBreaking(data)
end)

RunService.Heartbeat:Connect(function(dt)
    local locations = {

    }
    for i,v in Breaking do
        local pass,progress = UpdateOne(v, dt)
        if not pass then continue end 
        locations[pass] = progress
    end
    BlockBreaking.Update(locations)
end)

return Block  