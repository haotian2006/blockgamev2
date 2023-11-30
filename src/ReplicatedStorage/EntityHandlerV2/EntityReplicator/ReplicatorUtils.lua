local BridgeNet = require(game.ReplicatedStorage.BridgeNet)
local ReplicationRemote = BridgeNet.CreateBridge("ReplicationRemote")
local GameSettings = require(game.ReplicatedStorage.GameSettings)
local Math = require(game.ReplicatedStorage.Libarys.MathFunctions)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Entity = require(game.ReplicatedStorage.EntityHandlerV2)
local IS_CLIENT = RunService:IsClient()
local Replication = {}
Replication.EntityPlayerId = {}
Replication.temp = {

}
local temp = Replication.temp
--[[
    0: replicates
    1: does not replicate at all 
    2: only replicates once
    3: does not replicate to owner at all
    any attributes with not listed would be deafult to 0
]]
Replication.REPLICATE_LEVEL = {
    __main = 1,__velocity = 1,__changed = 1,__cachedData = 1,__localData = 1,Chunk = 1,Grounded = 1,Guid = 1,__running = 1,
    __components = 2,__animations = 2,
    Crouching = 3, Position = 3,Hitbox = 3, EyeLevel = 3,Rotation = 3,HeadRotation = 3

}
function Replication.swapKeyPairs(t)
    local new = {}
    for i,v in t do
        new[v] = i
    end
    return new
end
local X_BITS = 0b0000_0001_1111_1100
local Z_BITS = 0b1111_1110_0000_0000
local POSITION_PRECISION = 8191 
local ROTATION_PRECISION = 32767 / 180 
local Vector2int16 = Vector2int16.new
local function encodePosition(x,y,z)
    local xx = x
    local x = math.floor(x * POSITION_PRECISION)-32768
    local z = math.floor(z * POSITION_PRECISION)-32768
    return Vector2int16(x,z),y
end
local function decodePosition(x,y)
    return Vector3.new(
        (x.X+32768)/POSITION_PRECISION,
        y,
        (x.Y+32768)/POSITION_PRECISION
    )
end
local function encodeRotation(rx,ry,r)
    local rx = Math.normalizeAngle2(rx)
    local ry = Math.normalizeAngle2(ry)
    if not r then
        return Vector2int16(math.floor(rx *ROTATION_PRECISION),math.floor(ry *ROTATION_PRECISION))
    else
        local r = Math.normalizeAngle2(r)
        return Vector3int16.new(math.floor(rx *ROTATION_PRECISION),math.floor(ry *ROTATION_PRECISION),math.floor(r *ROTATION_PRECISION))
    end
end
local function decodeRotation(x)
    if typeof(x) == "Vector2int16" and x.Y ~= -32768 then
        return Vector2.new(x.X/ROTATION_PRECISION,x.Y/ROTATION_PRECISION)
    elseif typeof(x) == "Vector3int16" then
        return Vector2.new(x.X/ROTATION_PRECISION,x.Y/ROTATION_PRECISION),x.Z/ROTATION_PRECISION
    else
        return x.X/ROTATION_PRECISION
    end
end
local FAST_CHANGES = {"Position","Rotation","HeadRotation",}
function Replication.getFastChanges(self)
    local old = self.__localData.Old or {}
    self.__localData.Old  = old
    local localD = self.__localData
    local changes = {}
    if old["Position"] ~= self["Position"] then
        changes["Position"] = self["Position"] 
        if IS_CLIENT then
            changes["Position"]  += Entity.getTotalVelocity(self)*1/30
        end
    end
    old["Position"] =   changes["Position"] or self["Position"]
    if localD["Rotation"] then
        if old["Rotation"] ~= localD["Rotation"] then
            changes["Rotation"] = localD["Rotation"] 
        end
        old["Rotation"] = localD["Rotation"] 
    else
        if old["Rotation"] ~= self["Rotation"] then
            changes["Rotation"] = self["Rotation"] 
        end
        old["Rotation"] = self["Rotation"] 
    end

    if localD["HeadRotation"] then
        if old["HeadRotation"] ~= localD["HeadRotation"] then
            changes["HeadRotation"] = localD["HeadRotation"] 
        end
        old["HeadRotation"] = localD["HeadRotation"] 
    else
        if old["HeadRotation"] ~= self["HeadRotation"] then
            changes["HeadRotation"] = self["HeadRotation"] 
        end
        old["HeadRotation"] = self["HeadRotation"] 
    end

    -- for i,v in FAST_CHANGES do
    --     if old[v] ~= self[v] then
    --         changes[v] = self[v] 
    --     end
    --     old[v] = self[v]
    -- end
    return changes
end
local CHX = GameSettings.ChunkSize.X
function Replication.fastEncode(self,idk)
    if temp[self.Guid] then 
        return   temp[self.Guid]  ~= 1 and table.clone(temp[self.Guid]) or nil
    end 
    idk = idk or {}
    local changes = Replication.getFastChanges(self)
    local pos = changes.Position
    local Chunk 
    local toUpdate = table.create(2)
    local Changed = false
    toUpdate[1] = {self.Guid}
    if pos and not idk.Position then
        local cx,cz = math.floor(pos.X/CHX), math.floor(pos.Z/CHX)
        local lx,ly,lz = pos.X%CHX,pos.Y,pos.Z%CHX
        local chunk = Vector2.new(cx,cz)
        toUpdate[2],ly = encodePosition(lx,ly,lz)
        if self.__localData.Old.Chunk ~= chunk then 
            Chunk = chunk
            self.__localData.Old.Chunk = chunk
            toUpdate[4] = chunk
            toUpdate[3] = false
        end
        toUpdate[1][2] = ly
        Changed = true
    end
    if changes.Rotation and not idk.Rotation then
        toUpdate[3] = Math.normalizeAngle2(changes.Rotation)
        Changed = true
        toUpdate[2] = toUpdate[2] or false
    end
    if changes.HeadRotation and not idk.HeadRotation then
        toUpdate[3] = encodeRotation(changes.HeadRotation.X,changes.HeadRotation.Y,toUpdate[3])

        toUpdate[2] = toUpdate[2] or false
        Changed = true
    elseif toUpdate[3] then
        toUpdate[3] = Vector2int16(toUpdate[3]*ROTATION_PRECISION,-32768)
    end
    temp[self.Guid] =  Changed and toUpdate or 1
    return Changed and toUpdate
end
function Replication.fastDecode(data,old)
    local lP,chunk,hR,R
    local update = {}
    if data[2] then
        local ch =data[4] or old.Chunk or Vector2.zero
        old.Chunk = ch
        lP = decodePosition(data[2],data[1].Y)
        local worldPos = ConversionUtils.convertLocalToGrid(ch.X,ch.Y,lP.X,lP.Y,lP.Z)
        update.Position = worldPos
      --  print(ch)
     --   print(worldPos)
    end
    if data[3] then
        hR,R = decodeRotation(data[3])
        if typeof(hR) == "number" then
            R = hR
            hR = nil
        end
        update.Rotation =R
        update.HeadRotation =hR
    end
    return update
end


return Replication
