local PlayerManager = {}

local Players = game:GetService("Players")
local RunServie = game:GetService("RunService")

local IS_CLEINT = RunServie:IsClient()

local PlayersInGame = {}

Players.PlayerAdded:Connect(function(player)
    table.insert(PlayersInGame,player)
end)

Players.PlayerRemoving:Connect(function(player)
    table.remove(PlayersInGame,table.find(PlayersInGame, player))
end)


if IS_CLEINT then


    
else


end

return PlayerManager