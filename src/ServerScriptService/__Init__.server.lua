local bridge = require(game.ReplicatedStorage.BridgeNet)
--bridge.Start({})
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
resourcehandler:Init()
require(game.ReplicatedStorage.BehaviorHandler):Init()
require(game.ReplicatedStorage.Managers):Init()
local EntityBridge = bridge.CreateBridge("EntityBridge")
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
    local entity = entityahndler.Create("Player",{Died = false,inventory = {AddTo = true,[1] = {"T|s%C:Dirt",64},[6] = {"T|s%C:Dirt",1},[2] = {"T|s%C:Grass",64},[3] = {"T|s%C:Stone",64}},Name = player.Name,Id = tostring(player.UserId),Position = Vector3.new(-7, 6.6, 10),ClientControll = tostring(player.UserId)})
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
    local entity = entityahndler.Create("Player",{inventory = {AddTo = true,[1] = {"T|s%C:Dirt",64},[2] = {"T|s%C:Grass",64},[3] = {"T|s%C:Stone",64}},Name = player.Name,Id = tostring(player.UserId),Position = Vector3.new(-7, 6.6, 10),ClientControll = tostring(player.UserId)})
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
        local dcby = entity.CrouchLower or 0
        if not entity.Crouching then
            --entity.Position -= Vector3.new(0,.3,0)
            entity.Hitbox = Vector2.new(entity.Hitbox.X,entity.Hitbox.Y+dcby)
            entity.EyeLevel = entity.EyeLevel+dcby
        else
            entity.Hitbox = Vector2.new(entity.Hitbox.X,entity.Hitbox.Y-dcby)
          --  entity.Position += Vector3.new(0,.3,0)
            entity.EyeLevel =  entity.EyeLevel- dcby
        end
    end
  --  print(data.LoadedEntities[tostring(plr.UserId)].Hitbox)
    if entity then 
        entity:UpdateDataServer(newdata)
    end
end)
local ublock = bridge.CreateBridge("UpdateBlocks")
bridge.CreateBridge("BlockBreak"):Connect(function(plr,block:Vector3)
    if data.GetEntityFromPlayer(plr) and data.GetEntityFromPlayer(plr):GetState('Dead') then return end 
    local blocktr = qf.DecompressItemData(data.GetBlock(block.X,block.Y,block.Z),"T")
    if blocktr == "C:Bedrock" then return end 
    data.RemoveBlock(block.X,block.Y,block.Z)
    ublock:FireAll({Remove = {block}})
end)
bridge.CreateBridge("BlockPlace"):Connect(function(plr,coords1,ori)
    if data.GetEntityFromPlayer(plr) and data.GetEntityFromPlayer(plr):GetState('Dead') then return end  
    
    local coords = coords1
    local plre = data.GetEntityFromPlayer(plr)
    local item = plre.HoldingItem or {}
    item = qf.deepCopy(item)
    if item[1] and ori then
        item[1] ..= '/O|s%'..ori
    end
    --print(item)
    if data.canPlaceBlockAt(coords.X,coords.Y,coords.Z) and item[1] and resourcehandler.IsBlock(item[1]) and not data.GetBlock(coords.X,coords.Y,coords.Z) then 
        data.InsertBlock(coords.X,coords.Y,coords.Z,item[1])
        ublock:FireAll({Add = {[coords1.X..','..coords1.Y..','..coords1.Z] = item[1]}})
    end
end)
game.ReplicatedStorage.Events.KB.OnServerEvent:Connect(function(plr,id,lookvector)
    local plre = data.GetEntityFromPlayer(plr)
    --plre:DropItem('C:Dirt',1)
    if data.GetEntityFromPlayer(plr) and data.GetEntityFromPlayer(plr):GetState('Dead') then return end 
    local entity = data.GetEntity(id)
    if not entity or entity:GetState('Dead') then return end 
    --entity:AddVelocity("KnockBack",Vector3.new(lookvector.X,.5,lookvector.Z)*100)
    local velocity = Vector3.new(lookvector.X*5,.6,lookvector.Z*5)
    entity:Damage(1)
    if entity.ClientControll then
        local player = game.Players:GetPlayerByUserId(entity.ClientControll) 
        if player and not entity.God then
            domoverbridge:FireTo(player,id,"Curve",velocity,.2)
        end
    elseif not entity.God then
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