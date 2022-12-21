local bridge = require(game.ReplicatedStorage.BridgeNet)
--bridge.Start({})
local EntityBridge = bridge.CreateBridge("EntityBridge")
local data = require(game.ReplicatedStorage.DataHandler)
local entityahndler = require(game.ServerStorage.EntityHandler)
local Cfig = require(game.ReplicatedStorage.GameSettings)
game.Players.PlayerAdded:Connect(function(player)
    local entity = entityahndler.Create("Player",{Name = player.Name,Id = tostring(player.UserId),Position = Vector3.new(-7, 60, 10)})
    data.AddEntity(entity)
    game:GetService("RunService").Heartbeat:Connect(function()
        if player.Character and player.Character.PrimaryPart then
            local Pb = player.Character.PrimaryPart.Position
            EntityBridge:FireTo(player,data.EntitiesinR(Pb.X/Cfig.GridSize,Pb.Y/Cfig.GridSize,Pb.Z/Cfig.GridSize,100,true))
        end
    end)
end)
EntityBridge:Connect(function(plr,P)
    local entity = data.LoadedEntities[tostring(plr.UserId)]
    if entity then 
     entity.Position = P
    end
end)