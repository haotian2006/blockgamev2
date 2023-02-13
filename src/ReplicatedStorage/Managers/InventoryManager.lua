local manager = {}
local player = game.Players.LocalPlayer
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local runservice = game:GetService("RunService")
local dataHandler = require(game.ReplicatedStorage.DataHandler)
manager.Uis = {}
if runservice:IsServer() then return {} end 
local PEntity = dataHandler.GetLocalPlayer
function  manager()
    
end
return manager