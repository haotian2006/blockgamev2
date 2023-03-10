local bridge = require(game.ReplicatedStorage.BridgeNet)
--bridge.Start({})
local EntityBridge = bridge.CreateBridge("EntityBridge")
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
require(game.ServerStorage.BehaviorHandler):Init()
for i,v in game.ServerStorage.ServerStuff:GetChildren() do
    require(v)
end
local AnimationBridge = bridge.CreateBridge("AnimationHandler")
local data = require(game.ReplicatedStorage.DataHandler)
local entityahndler = require(game.ReplicatedStorage.EntityHandler)
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
local Cfig = require(game.ReplicatedStorage.GameSettings)
local qf = require(game.ReplicatedStorage.QuickFunctions)
game.Players.PlayerAdded:Connect(function(player)
    local entity = entityahndler.Create("Player",{Died = false,inventory = {AddTo = true,[1] = {"Type|s%Cubic:Dirt",64},[2] = {"Type|s%Cubic:Grass",64},[3] = {"Type|s%Cubic:Stone",64}},Name = player.Name,Id = tostring(player.UserId),Position = Vector3.new(-7, 6.6, 10),ClientControll = tostring(player.UserId)})
    data.AddEntity(entity)
end)
game.Players.PlayerRemoving:Connect(function(player)
    data.RemoveEntity(player.UserId)
end)
local entity = entityahndler.Create("Npc",{Name = "Npc1",Id = "Npc1",Position = Vector3.new(-7.2, 6.6, 10)}) data.AddEntity(entity)
game.ReplicatedStorage.Events.Respawn.OnServerEvent:Connect(function(player)
    data.RemoveEntity(player.UserId)
    for i,player in game.Players:GetPlayers() do
        UpdateClientEntities(player)
    end
    local entity = entityahndler.Create("Player",{inventory = {AddTo = true,[1] = {"Type|s%Cubic:Dirt",64},[2] = {"Type|s%Cubic:Grass",64},[3] = {"Type|s%Cubic:Stone",64}},Name = player.Name,Id = tostring(player.UserId),Position = Vector3.new(-7, 6.6, 10),ClientControll = tostring(player.UserId)})
    task.wait(.2)
    data.AddEntity(entity)
end)
game.ReplicatedStorage.Events.ServerFPS.OnServerEvent:Connect(function(player,a)
    entity:TurnTo(data.GetEntity(player.UserId).Position)
    local pe = data.GetEntityFromPlayer(player)
    pe.PlayingAnimations.Swing = a
   -- pe.PlayingAnimations.Normal = not pe.PlayingAnimations.Normal 
end)
local domoverbridge = bridge.CreateBridge("DoMover")
EntityBridge:Connect(function(plr,id,newdata)
    local entity = data.GetEntity(id)
    if not entity then return end 
    if entity.ClientControll ~= tostring(plr.UserId) then return end 
    if entity and newdata.Crouching ~= nil and newdata.Crouching ~= entity.Crouching  then
        entity.Crouching  = newdata.Crouching
        if not entity.Crouching then
            --entity.Position -= Vector3.new(0,.3,0)
            entity.HitBox = Vector2.new(entity.HitBox.X,entity.HitBox.Y+.3)
            entity.EyeLevel += .3
        else
            entity.HitBox = Vector2.new(entity.HitBox.X,entity.HitBox.Y-.3)
          --  entity.Position += Vector3.new(0,.3,0)
            entity.EyeLevel -= .3
        end
    end
  --  print(data.LoadedEntities[tostring(plr.UserId)].HitBox)
    if entity then 
        entity:UpdateDataServer(newdata)
    end
end)
local ublock = bridge.CreateBridge("UpdateBlocks")
bridge.CreateBridge("BlockBreak"):Connect(function(plr,block:Vector3)
    if data.GetEntityFromPlayer(plr) and data.GetEntityFromPlayer(plr):GetState('Dead') then return end 
    local blocktr = qf.DecompressItemData(data.GetBlock(block.X,block.Y,block.Z),"Type")
    if blocktr == "Cubic:Bedrock" then return end 
    data.RemoveBlock(block.X,block.Y,block.Z)
    ublock:FireAll({Remove = {block}})
end)
bridge.CreateBridge("BlockPlace"):Connect(function(plr,coords1)
    if data.GetEntityFromPlayer(plr) and data.GetEntityFromPlayer(plr):GetState('Dead') then return end  
    local coords = coords1
    local plre = data.GetEntityFromPlayer(plr)
    local item = plre.HoldingItem or {}
    --print(item)
    if data.canPlaceBlockAt(coords.X,coords.Y,coords.Z) and item[1] and resourcehandler.IsBlock(item[1]) then 
        data.InsertBlock(coords.X,coords.Y,coords.Z,item[1])
        ublock:FireAll({Add = {[coords1.X..','..coords1.Y..','..coords1.Z] = item[1]}})
    end
    if not data.GetBlock(coords.X,coords.Y,coords.Z) then 
        data.InsertBlock(coords.X,coords.Y,coords.Z,item[1])
        ublock:FireAll({Add = {[coords1.X..','..coords1.Y..','..coords1.Z] = item[1]}})
    end
end)
game.ReplicatedStorage.Events.KB.OnServerEvent:Connect(function(plr,id,lookvector)
    if data.GetEntityFromPlayer(plr) and data.GetEntityFromPlayer(plr):GetState('Dead') then return end 
    local entity = data.GetEntity(id)
    if not entity or entity:GetState('Dead') then return end 
    --entity:AddVelocity("KnockBack",Vector3.new(lookvector.X,.5,lookvector.Z)*100)
    local velocity = Vector3.new(lookvector.X*2,.6,lookvector.Z*2)
    entity:Damage(1)
    if entity.ClientControll then
        local player = game.Players:GetPlayerByUserId(entity.ClientControll) 
        if player then
            domoverbridge:FireTo(player,id,"Curve",velocity,.2)
        end
    else
        --entity:AddBodyVelocity("Kb",Vector3.new(lookvector.X*2,1,lookvector.Z*2))
        entity:KnockBack(velocity,.2)
        --require(game.ReplicatedStorage.EntityMovers.Curve).new(entity,velocity,.2)
    end

end)
function UpdateClientEntities(player)
    if player.Character and player.Character.PrimaryPart and data.GetEntity(player.UserId) then
        local Pb = data.GetEntity(player.UserId).Position
        local a = data.EntitiesinR(Pb.X,Pb.Y,Pb.Z,100,player)
        EntityBridge:FireTo(player,a)
    else
        EntityBridge:FireTo(player,{})
    end
end
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
        UpdateClientEntities(player)
    end
    for id,entity in data.LoadedEntities do
        entity:ClearVelocity()
    end
    
end)