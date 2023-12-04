local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local bridge = require(game.ReplicatedStorage.BridgeNet)
local ErrorHandler = require(game.ReplicatedStorage.Libarys.ErrorHandler)
--bridge.Start({})
local Signal = require(game.ReplicatedStorage.Libarys.Signal)
local PlayersLoaded = {}
local function PlayerIsLoaded(player,wait)
    if not  PlayersLoaded[player.UserId] then
        PlayersLoaded[player.UserId] = Signal.new()
    end
    if PlayersLoaded[player.UserId] == true then return true end 
    if not wait then return  end 
    PlayersLoaded[player.UserId]:Wait()
    PlayersLoaded[player.UserId]:DisconnectAll()
    PlayersLoaded[player.UserId] = true
end
game.ReplicatedStorage.Events.LOAD.OnServerEvent:Connect(function(plr)
    PlayerIsLoaded(plr)
    PlayersLoaded[plr.UserId]:Fire()
end)

local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
resourcehandler:Init()
local beh = require(game.ReplicatedStorage.BehaviorHandler):Init()
local EntityBridge = bridge.CreateBridge("EntityBridge")
for i,v in game.ServerStorage.ServerStuff:GetChildren() do
    require(v)
end
local comp = require(game.ReplicatedStorage.Libarys.compressor)
local interval = 0
local data = require(game.ReplicatedStorage.DataHandler)
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
local LEntity = data.GetLoadedEntitys()
local gmh = require(game.ServerStorage.GenerationMultiHandler):Init()
--<TESTING MODE>
local MR = require(game.ReplicatedStorage.Libarys.ModingRemote)
local Damage = MR.GetRemote("Damage")


local cri = game.ReplicatedStorage.climate::RemoteEvent
cri.OnServerEvent:Connect(function(plr,xx,yy,z)
    local x,y = unpack(gmh:GetBiomeValues(xx,yy,z))
    local biome =  data.GetBiome(xx,yy,z)
   -- local str = `c:{x.X} | e:{x.Y} | d:{y.Z} | t:{y.X} | h:{y.Y} | w:{x.Z}`
    local str = string.format('c: %.3f | e: %.3f | t: %.3f | h: %.3f | w: %.3f | biome: %s',x.X,x.Y,y.X,y.Y,x.Z,biome or "")
 --   return str
 cri:FireClient(plr,str)
end)
local spawnp = Vector3.new(342, 90, -77)
--local spawnp = Vector3.new(219, 2.108, 214)

game.Players.PlayerAdded:Connect(function(player)
   -- CreatePlayer(player)
end)
game.Players.PlayerRemoving:Connect(function(player)
    -- LEntity.Remove(player)

    -- data.RemoveEntity(player.UserId)
    -- PlayersLoaded[player.UserId] = nil
end)
if not RunService:IsServer() and false then
    -- for i =1,2 do
    --     local entityahndler = require(game.ReplicatedStorage.EntityHandler)  local entity = entityahndler.Create("Npc",{Health = 10000000,Speed= 20, ['behavior.AttackPlayer'] = {MaxRange = 10,priority = 2,} , ['behavior.Random_Stroll'] = nil, ['behavior.GoToPlayer'] = {MaxRange = 1000,priority = 2,interval = 1,},Name = "BOSS: MAN FACE MAN",Id = "BOSS: MAN FACE MAN"..i,Position = Vector3.new(-100, 90, -400)})   require(game.ReplicatedStorage.DataHandler).AddEntity(entity)
    --    -- local entity = entityahndler.Create("Npc",{Name = "Npc1",Id = "Npc1"..i,Position = Vector3.new(-100, 90, -400)}) data.AddEntity(entity)
    -- end
end

game.ReplicatedStorage.Events.ServerFPS.OnServerEvent:Connect(function(player,a)
    --entity:TurnTo(data.GetEntity(player.UserId).Position)
    local pe = data.GetEntityFromPlayer(player)
    pe.PlayingAnimations.Swing = a
   -- pe.PlayingAnimations.Normal = not pe.PlayingAnimations.Normal 
end)
local domoverbridge = bridge.CreateBridge("DoMover")

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
           -- entity.Position += Vector3.new(0,dcby,0)
            entity.Hitbox = Vector2.new(entity.Hitbox.X,entity.Hitbox.Y+dcby)
            entity.EyeLevel = entity.EyeLevel+dcby
        else
            entity.Hitbox = Vector2.new(entity.Hitbox.X,entity.Hitbox.Y-dcby)
          --  entity.Position -= Vector3.new(0,dcby,0)
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
    local blocktr = data.GetBlock(block.X,block.Y,block.Z)
    if (blocktr and blocktr:getName() == "c:Bedrock") or not blocktr then return end 
    data.RemoveBlock(block.X,block.Y,block.Z)

    ublock:FireToAllExcept(plr,nil,block.X,block.Y,block.Z)
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
    --plre:DropItem('c:Dirt',1)
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
    if not PlayerIsLoaded(player) then return end 
    if player.Character and player.Character.PrimaryPart and data.GetEntity(player.UserId) then
        local Pb = data.GetEntity(player.UserId).Position
        local a = data.EntitiesinR(Pb.X,Pb.Y,Pb.Z,100)
        local new = {}
        local le = LEntity.Get(player)
        for i,v in a do
            local id = le:Find(i)
            local cmp = v:ConvertToClient(player,interval)
            if next(cmp) ~= nil then
                table.insert(new,cmp)
            end
        end
        le:Update(a)
        local ab= le:Get()
        if next(new) ~= nil or ab then
            EntityBridge:FireTo(player,new,ab)
        end
    else
        EntityBridge:FireTo(player,{},{})
    end
end
