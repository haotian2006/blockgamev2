local LocalizationService = game:GetService("LocalizationService")
local data = require(game.ReplicatedStorage.DataHandler)
local entityahndler = require(game.ServerStorage.EntityHandler)
local Cfig = require(game.ReplicatedStorage.GameSettings)
game.Players.PlayerAdded:Connect(function(player)
    local entity = entityahndler.Create("Player",{Name = player.Name,Id = tostring(player.UserId),Position = Vector3.new(-7, 70, 10)})
    data.AddEntity(entity)
    game:GetService("RunService").Heartbeat:Connect(function()
        if player.Character and player.Character.PrimaryPart then
            local Pb = player.Character.PrimaryPart.Position
            game.ReplicatedStorage.Events.SendEntities:FireClient(player,data.EntitiesinR(Pb.X/Cfig.GridSize,Pb.Y/Cfig.GridSize,Pb.Z/Cfig.GridSize,100,true))
        end
    end)
    game.ReplicatedStorage.Events.SendEntities.OnServerEvent:Connect(function(plr,vel)
        entity.Velocity["Movement"] = vel
    end)
end)