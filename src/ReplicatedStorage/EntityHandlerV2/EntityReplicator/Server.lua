local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end 
return require(game.ServerStorage.ServerStuff.EntityReplicatorServer)