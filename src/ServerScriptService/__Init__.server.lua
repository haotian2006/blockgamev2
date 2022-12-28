local bridge = require(game.ReplicatedStorage.BridgeNet)
--bridge.Start({})
local EntityBridge = bridge.CreateBridge("EntityBridge")
require(game.ServerStorage.BehaviorHandler):Init()
local data = require(game.ReplicatedStorage.DataHandler)
local entityahndler = require(game.ServerStorage.EntityHandler)
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
local Cfig = require(game.ReplicatedStorage.GameSettings)
game.Players.PlayerAdded:Connect(function(player)
    local entity = entityahndler.Create("Player",{Name = player.Name,Id = tostring(player.UserId),Position = Vector3.new(-7, 60, 10),ClientControll = tostring(player.UserId)})
    data.AddEntity(entity)
    while true do
        task.wait()
    end
end)
local entity = entityahndler.Create("Npc",{Name = "Npc1",Id = "Npc1",Position = Vector3.new(-7.2, 60, 10)})
data.AddEntity(entity)
EntityBridge:Connect(function(plr,P,odata)
    local entity = data.LoadedEntities[tostring(plr.UserId)]
    if entity then 
     entity.Position = P
     entity.OrientationData = odata
    end
end)

game:GetService("RunService").Heartbeat:Connect(function( deltaTime)
    local entitycollisons = {}
    for id,entity in data.LoadedEntities do
        for i,v in data.LoadedEntities do
            if i ~= id then
                if not (entitycollisons[id..','..i] or entitycollisons[i..','..id]) then
                    entitycollisons[id..','..i] = true
                    CollisionHandler.entityvsentity(entity,v)
                end
            end
        end
        task.spawn(entity.Update,entity,deltaTime)
    end
    for i,player in game.Players:GetPlayers() do
        if player.Character and player.Character.PrimaryPart then
            local Pb = data.LoadedEntities[tostring(player.UserId)].Position
            local a = data.EntitiesinR(Pb.X,Pb.Y,Pb.Z,100,true)
            EntityBridge:FireTo(player,a)
        end
    end
    for id,entity in data.LoadedEntities do
        entity:ClearVelocity()
    end
end)