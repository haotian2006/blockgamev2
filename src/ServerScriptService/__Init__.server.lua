local HttpService = game:GetService("HttpService")
local bridge = require(game.ReplicatedStorage.BridgeNet)
--bridge.Start({})

local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
resourcehandler:Init()
local beh = require(game.ReplicatedStorage.BehaviorHandler):Init()
local Manager = require(game.ReplicatedStorage.Managers):Init()
local itemhand = require(game.ReplicatedStorage.ItemHandler):Init()
local EntityBridge = bridge.CreateBridge("EntityBridge")
for i,v in game.ServerStorage.ServerStuff:GetChildren() do
    require(v)
end
local comp = require(game.ReplicatedStorage.Libarys.compressor)
local interval = 0
local debirs = require(game.ReplicatedStorage.Libarys.Debris):Init()
local AnimationBridge = bridge.CreateBridge("AnimationHandler")
local data = require(game.ReplicatedStorage.DataHandler)
local entityahndler = require(game.ReplicatedStorage.EntityHandler)
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
local Cfig = require(game.ReplicatedStorage.GameSettings)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local CraftingManager =   Manager.CraftingManager:Init()
--<TESTING MODE>
local MR = require(game.ReplicatedStorage.Libarys.ModingRemote)
local Damage = MR.GetRemote("Damage")
local playercontrol = require(game.ServerStorage.PlayerControlsHandler)
local KeyDown = bridge.CreateBridge("UisKeyInput")
data.PlayerControl = {}
data.DONELOADING = true
KeyDown:Connect(function(player,key,isdown)
    local e = data.GetEntityFromPlayer(player)
    if not key or not e then return end 
    local c =data.PlayerControl[player]
    if isdown then c:KeyDown(key);itemhand.handleItemInput(key,true,c,e,player)  else c:KeyUp(key) end 
  --  print(key,isdown)
end)
game.ReplicatedStorage.Events.DoSmt.OnServerEvent:Connect(function(player,stuff)
    require(game.ServerStorage.DataStores.BlockSaver).Save()
end)

local function CreatePlayer(player)
    if   data.PlayerControl[player] then
        data.PlayerControl[player]:Clear()
    else
        data.PlayerControl[player] = playercontrol.new()
    end
    local entity = entityahndler.Create("Player",{Died = false,inventory = {AddTo = true,[1] = {"T|s%C:Dirt",64},[12] = {"T|s%C:Grass",64},[9] ={"T|s%DebugPart",64}, [7] = {"T|s%C:Slab",1},[6] = {"T|s%C:Stair",1},[3] = {"T|s%C:Stick",1},[5] = {"T|s%C:Stone",64}},Name = player.Name,Id = tostring(player.UserId),Position = Vector3.new(-7, 90, 10),ClientControl = tostring(player.UserId)})
    task.wait(.2 )
    data.AddEntity(entity)
end
for i,v in game.Players:GetPlayers() do
    CreatePlayer(v)
end
game.Players.PlayerAdded:Connect(CreatePlayer)
game.Players.PlayerRemoving:Connect(function(player)
    data.loadedentitysforplayer[tostring(player.UserId)] = nil
    data.PlayerControl[player] = nil
    data.RemoveEntity(player.UserId)
end)
for i =1,1 do
    local entity = entityahndler.Create("Npc",{Name = "Npc1",Id = "Npc1"..i,Position = Vector3.new(-7.2, 90, 10)}) data.AddEntity(entity)
end
game.ReplicatedStorage.Events.Respawn.OnServerEvent:Connect(function(player)
    data.loadedentitysforplayer[tostring(player.UserId)] = nil
    data.RemoveEntity(player.UserId)
    interval += 20 + math.random(1,10)
    for i,player in game.Players:GetPlayers() do
        UpdateClientEntities(player)
    end
    CreatePlayer(player)
end)
game.ReplicatedStorage.Events.ServerFPS.OnServerEvent:Connect(function(player,a)
    --entity:TurnTo(data.GetEntity(player.UserId).Position)
    local pe = data.GetEntityFromPlayer(player)
    pe.PlayingAnimations.Swing = a
   -- pe.PlayingAnimations.Normal = not pe.PlayingAnimations.Normal 
end)
local domoverbridge = bridge.CreateBridge("DoMover")
data.loadedentitysforplayer = {}
EntityBridge:Connect(function(plr,id,newdata)
    local entity = data.GetEntity(id)
    if not entity then return end 
   -- newdata = HttpService:JSONDecode(newdata)
 
    if entity.ClientControl ~= tostring(plr.UserId) then return end 
    if not entity:CanCrouch() and entity.Crouching then newdata.Crouching = false end 
    if entity and newdata.Crouching ~= nil and newdata.Crouching ~= not not entity.Crouching  then
        entity.Crouching  = newdata.Crouching 
        local dcby = entity.CrouchLower or 0
        if not entity.Crouching  then
            --entity.Position -= Vector3.new(0,.3,0)
            entity.Hitbox = Vector2.new(entity.Hitbox.X,entity.Hitbox.Y+dcby)
            entity.EyeLevel = entity.EyeLevel+dcby
        else
            entity.Hitbox = Vector2.new(entity.Hitbox.X,entity.Hitbox.Y-dcby)
          --  entity.Position += Vector3.new(0,.3,0)
            entity.EyeLevel =  entity.EyeLevel- dcby
        end

    end
    if id == tostring(plr.UserId) then
        data.loadedentitysforplayer[id] = newdata.Loaded
        newdata.Loaded = nil
    end
  --  print(data.LoadedEntities[tostring(plr.UserId)].Hitbox)
    if entity then 
        entity:UpdateDataServer(newdata)
    end
end)
local ublock = bridge.CreateBridge("UpdateBlocks")
bridge.CreateBridge("BlockBreak"):Connect(function(plr,block:Vector3)
    if data.GetEntityFromPlayer(plr) and data.GetEntityFromPlayer(plr):GetState('Dead') then return end 
    local blocktr = data.GetBlock(block.X,block.Y,block.Z)
    if (blocktr and blocktr[2].T == "C:Bedrock") or not blocktr then return end 
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
        do
            local block = resourcehandler.IsBlock(item[1])
            block = beh.GetBlock(block)
            block = block.components
            local x,y,z = unpack(ori:split(","))
            x = block.RotateX and x or 0 
            y = block.RotateY and y or 0
            z = block.RotateZ and z or 0
            ori = x..','..y..','..z
        end
        item[1] ..= '/O|s%'..ori
    end
    --print(item)
    if data.canPlaceBlockAt(coords.X,coords.Y,coords.Z) and item[1] and resourcehandler.IsBlock(item[1]) and not data.GetBlock(coords.X,coords.Y,coords.Z) then 
        data.InsertBlock(coords.X,coords.Y,coords.Z,item[1])
        ublock:FireAll({Add = {[coords1.X..','..coords1.Y..','..coords1.Z] = item[1]}})
    end
end)
Damage.OnServerEvent:Connect(function(plr,id,lookvector)
    local plre = data.GetEntityFromPlayer(plr)
    local item = (plre.HoldingItem or {})[1]
    local idata = itemhand.GetItemData(item) or {}
    if data.GetEntityFromPlayer(plr) and data.GetEntityFromPlayer(plr):GetState('Dead') then return end 
    local entity = data.GetEntity(id)
    if not entity or entity:GetState('Dead') then return end 
    local velocity = Vector3.new(lookvector.X,.6,lookvector.Z) *(idata.KnockBackForce or 5)
    entity:Damage(idata.Damage or 1)
    if entity.ClientControl then
        local player = game.Players:GetPlayerByUserId(entity.ClientControl) 
        if player and not entity.God then
            domoverbridge:FireTo(player,id,"Curve",velocity,.2)
        end
    elseif not entity.God then
        entity:KnockBack(velocity,.2)
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
    if entity.ClientControl then
        local player = game.Players:GetPlayerByUserId(entity.ClientControl) 
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
        local a = data.EntitiesinR(Pb.X,Pb.Y,Pb.Z,100,player,interval)
        local new = {}
        for i,v in a do
            table.insert(new,v)
        end
        EntityBridge:FireTo(player,new)
    else
        EntityBridge:FireTo(player,{})
    end
end
local t = 0
local tick = 1/20
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
    local a = false
    if t >= tick then
        interval +=  1
        if interval >= 10 then
            interval = 0
        end
        for i,player in game.Players:GetPlayers() do
            UpdateClientEntities(player)
        end  
        t = 0
        a = true
    end
    t+=deltaTime
    for id,entity in data.LoadedEntities do
        entity:ClearVelocity()
        if a then
            entity:ClearUpdated()
            entity.__Last = {}
        end
    end
    
end)