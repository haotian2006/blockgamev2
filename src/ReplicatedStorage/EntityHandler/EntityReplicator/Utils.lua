local GameSettings = require(game.ReplicatedStorage.GameSettings)
local Math = require(game.ReplicatedStorage.Libs.MathFunctions)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Entity = require(game.ReplicatedStorage.EntityHandler)
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
    any attributes  not listed would be deafult to 0
]]
Replication.REPLICATE_LEVEL = {
    __main = 1,__velocity = 1,__changed = 1,__cachedData = 1,__localData = 1,
    Chunk = 1,Grounded = 1,Guid = 1,__running = 1,__containers = 1,slot = 1,
    __class = 1,
    --__components = 2,
    __animations = 2,
    Crouching = 3, Position = 3,Hitbox = 3, EyeLevel = 3,Rotation = 3,HeadRotation = 3,Holding = 3
}

--THIS IS DANGER 
function Replication.setReplicateLevel(key,level)
    Replication.REPLICATE_LEVEL[key] = level
end

local FastChanges = {
    Position = true,
    Velocity = true,
    Rotation = true,
    HeadRotation = true,
}
local function findFastChanges(self)
    local old = self.__localData.OldData or {}
end

function Replication.fastEncode(self)
    local Guid = self.Guid
end

return Replication