
local qf = require(game.ReplicatedStorage.QuickFunctions)
local resource = require(game.ReplicatedStorage.ResourceHandler)
resource:Init()
local itemhand = require(game.ReplicatedStorage.ItemHandler):Init()
require(game.ReplicatedStorage.BehaviorHandler):Init()
local managers = require(game.ReplicatedStorage.Managers):Init()
local bridge = require(game.ReplicatedStorage.BridgeNet)
local lp = game.Players.LocalPlayer
local EntityBridge = bridge.CreateBridge("EntityBridge")
--bridge.Start({})
local GetChunk = bridge.CreateBridge("GetChunk")
local datahandler = require(game.ReplicatedStorage.DataHandler)
local mulithandler = require(game.ReplicatedStorage.MultiHandler):Init()
local toload = {}
local currentlyloading = {}
local queued = {}
local debirs = require(game.ReplicatedStorage.Libarys.Debris):Init()
local anihandler = require(game.ReplicatedStorage.AnimationController)
local render = require(game.ReplicatedStorage.RenderStuff.Render)
local settings = require(game.ReplicatedStorage.GameSettings)
local control = require(script.Parent.Controller)
local hotbar = managers.HotBarManager
local comp = require(game.ReplicatedStorage.Libarys.compressor)
local https = game:GetService("HttpService")
local entityhandler = require(game.ReplicatedStorage.EntityHandler)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local tweenservice = game:GetService("TweenService")
local runservicer = game:GetService("RunService")
local HarmEvent = bridge.CreateBridge('OnEntityHarmed')
local function createAselectionBox(parent,color) local sb = Instance.new("SelectionBox",parent) sb.Visible = datahandler.HitBoxEnabled sb.Color3 = color or Color3.new(0.023529, 0.435294, 0.972549) sb.Adornee = parent sb.LineThickness = 0.025 return sb end
local function createEye(offset,hitbox)
    local eye = Instance.new("Part",hitbox.Parent)
    eye.Size = Vector3.new(hitbox.Size.X,0,hitbox.Size.Z)
    eye.Name = "Eye"
    eye.Transparency = 1
    local weld = Instance.new("Motor6D",eye)
    weld.Part0 = hitbox
    weld.Part1 = eye
    weld.Name = "EyeWeld"
    weld.C0 = offset and CFrame.new(Vector3.new(0,offset/2,0)*settings.GridSize) or CFrame.new()
    return eye
end
do
    local player = workspace:FindFirstChild('PlayerFolder') or Instance.new("Folder",workspace)
    player.Name = 'PlayerFolder'
    for i,v in game.Players:GetPlayers() do
        task.spawn(function()
            local char = v.Character or v.CharacterAdded:Wait()
            char.Parent = player
        end)
    end
end
local states = {}
local function CreateHumanoid(model)
    local h = Instance.new("Humanoid",model)
    for i,v in Enum.HumanoidStateType:GetEnumItems() do
        if v ~= Enum.HumanoidStateType.None then
            h:SetStateEnabled(v,false)        
        end
    end
    return h
end
local function changetext(nameLabel,STUDS_OFFSET_Y)
    nameLabel.TextScaled = true
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    
    local nameDisplayBillboard = nameLabel.Parent
    
    local textScaleSize = Vector2.new(.5, 1)
        local amountOfCharacter = string.len(nameLabel.Text)
        local _, numberOfLines = string.gsub(nameLabel.Text, "\n", "\n")
        if amountOfCharacter == 0 then
            numberOfLines = 0
        else	
            numberOfLines += 1
        end
        nameDisplayBillboard.Size = UDim2.new(
            amountOfCharacter * textScaleSize.X,
            0,
            numberOfLines * textScaleSize.Y,
            0
        )
        nameDisplayBillboard.StudsOffset = Vector3.new(0, STUDS_OFFSET_Y , 0)
    end

local function CreateModel(Data,ParentModel)
    local model = resource.GetEntityModelFromData(Data)
    if model then
        model = model:Clone()
        local humanoid = model:FindFirstChildWhichIsA("Humanoid")  or CreateHumanoid(model)
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new('Animator',humanoid)
        humanoid.Name = "AnimationController"
        humanoid.RigType = Enum.HumanoidRigType.R6
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.RequiresNeck = false
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        model.Parent = ParentModel
        model.Name = "EntityModel"
        local weld = Instance.new("Motor6D",ParentModel.PrimaryPart)
        weld.Name = "EntityModelWeld"
        weld.Part0 = ParentModel.PrimaryPart
        weld.Part1 = model.PrimaryPart
        return model
    end
end

bridge.CreateBridge("ChangeEntityProperty"):Connect(function(entitid,property,value)
    if datahandler.GetEntity(entitid) then
        datahandler.GetEntity(entitid)[property] = value
    end
end)
game.ReplicatedStorage.Events.EntityUpdater.OnClientEvent:Connect(function(entityId,newdata,dostuff)
    if datahandler.GetEntity(entityId) then
        local e = datahandler.GetEntity(entityId)
        for i,v in newdata or {} do
            e[i] = v 
        end
        for i,v in dostuff or {} do
            if e[i] then
                e[i](unpack(v))
            end
        end
    end
end)
game.ReplicatedStorage.Bindevent.Event:Connect(function(v)
    datahandler.GetEntity(game.Players.LocalPlayer.UserId):ApplyVelocity(v)
end)
bridge.CreateBridge("DoMover"):Connect(function(entity,Mover,...)
    local mover = game.ReplicatedStorage.EntityMovers:FindFirstChild(Mover)
    if mover and datahandler.GetEntity(entity) then
        require(mover).new(datahandler.GetEntity(entity),...)
    end
end)
HarmEvent:Connect(function(id,amt,IsDeath)
    local entity = datahandler.GetEntity(id)
    if not entity then return end  
    entity:OnHarmed(amt)
end)
game.ReplicatedStorage.Events.OnDeath.Event:Connect(function()
    local entity = datahandler.GetEntity(lp.UserId)
    if entity then
        local cam = game.Workspace.CurrentCamera
        cam.CameraType = Enum.CameraType.Scriptable
        local fov = tweenservice:Create(cam,TweenInfo.new(30,Enum.EasingStyle.Exponential),{FieldOfView = 30})
        local angle = tweenservice:Create(cam,TweenInfo.new(30,Enum.EasingStyle.Exponential),{CFrame = cam.CFrame*CFrame.Angles(math.rad(-20),math.rad(0),math.rad(50))})
        fov:Play()
        angle:Play()
        local ui = resource.GetUI('DeathScreen')
        if ui then
            ui = ui:Clone()
            ui.Parent = lp.PlayerGui
            local respawnButton = ui:FindFirstChild("RespawnButton",true)
            if respawnButton then
                task.wait(.3)
                respawnButton.MouseButton1Up:wait()
            end
        else
            task.wait(2)
        end
        fov:Cancel()
        angle:Cancel()
        game.ReplicatedStorage.Events.Respawn:FireServer()
        repeat
            task.wait()
        until datahandler.GetLocalPlayer() and not datahandler.GetLocalPlayer():GetState('Dead') 
        if ui then
        ui:Destroy()
        end
        cam.CameraType = Enum.CameraType.Custom
        cam.FieldOfView = 70
    end
end)
local i = 0
local function shoulddel(entitys,v,DEBUG)
    if not table.find(entitys,v.Name) and v:IsA("Model") then
        v:Destroy()
        local i = v.Name
        local last = datahandler.GetEntity(i)
        if last and last.Chunk  then
            local chunk = datahandler.GetChunk(last.Chunk.X,last.Chunk.Y)
            datahandler.GetEntity(i):Destroy()
        end
    end
end
datahandler.ClientEntityIndex = {}
EntityBridge:Connect(function(entitys,ClientIndex)
    if ClientIndex then 
     datahandler.ClientEntityIndex  = ClientIndex 
    end
    i =i and i + 1 
    if i == 200 then  print(entitys,i )  end 
   if i == 700 then  print(entitys,i ) i = nil end 
    for i,v in entitys do
        local id = v.Id or v[5]
        if type(id) == "string" then
            i =id
            v.Id = id
        elseif type(id) == "number" then
            i = datahandler.ClientEntityIndex[id]
            v.Id = datahandler.ClientEntityIndex[i] 
        end
        if i == nil then continue end 
        local e = game.Workspace.Entities:FindFirstChild(i) or workspace.DamagedEntities:FindFirstChild(i)
        local oldentity = datahandler.GetEntity(i)
        if v.ENCODE then
            for i,a in entityhandler.DECODE(oldentity or {},v.ENCODE) do
                v[i] = a
            end
            v.ENCODE = nil
        else
            v = entityhandler.DECODE(oldentity or {},v) 
        end
        if e and tostring(i) ~= tostring(Players.LocalPlayer.UserId) then
            local oldhitbox = oldentity.Hitbox
            --v = entityhandler.new(v)
            datahandler.GetEntity(i):UpdateEntity(v)
            if oldentity and v.Hitbox and  v.Hitbox ~= oldhitbox then
                if oldentity.Tweens and oldentity.Tweens["Pos"] then
                    oldentity.Tweens["Pos"]:Cancel()
                end
                if v.Hitbox then e.PrimaryPart.Size = Vector3.new(v.Hitbox.X,v.Hitbox.Y,v.Hitbox.X)*3 end 
                oldentity:UpdateModelPosition()
                if v.Position then e.PrimaryPart.CFrame = CFrame.new(v.Position*3) end 
            elseif v.Position then 
                oldentity.Tweens = oldentity.Tweens or {}
                oldentity.Tweens["Pos"] = tweenservice:Create(e.PrimaryPart,TweenInfo.new(0.1),{CFrame = CFrame.new(v.Position*3)})
                oldentity.Tweens["Pos"]:Play()
            end
            oldentity:UpdateRotationClient(true)
        elseif not e then
            local entity = entityhandler.new(v)
            if not entity then continue end 
            datahandler.AddEntity(i,entity)
            entity:UpdateEntity(v)
            local model = Instance.new("Model",workspace.Entities)
            local hitbox = Instance.new("Part",model)
            model.PrimaryPart = hitbox
            hitbox.Size = (Vector3.new(entity.Hitbox.X,entity.Hitbox.Y,entity.Hitbox.X) or Vector3.new(1,1,1))*settings.GridSize 
            local eye = createEye(entity.EyeLevel,hitbox)
            local eyebox = createAselectionBox(eye,Color3.new(1, 0, 0))
            eyebox.Parent = hitbox
            CreateModel(entity,model)
            entity.Entity = model
            entity:UpdateModelPosition()
            createAselectionBox(hitbox)
            hitbox.CanCollide = false
            hitbox.Anchored = true
            hitbox.Transparency = 1
            hitbox.Name = "Hitbox"
            hitbox.CFrame = CFrame.new(entity.Position*3)
            model.Name = i 
            if resource.GetAsset("Nametag") then
                local nametag = resource.GetAsset("Nametag"):Clone()
                nametag.Parent = hitbox
                nametag.Text.Text = v.Name or v.Id
            end
            e = model
           -- entity:UpdateRotationClient()
           oldentity = entity
            if i == tostring(game.Players.LocalPlayer.UserId) then
                workspace.CurrentCamera.CameraSubject = eye
                datahandler.LocalPlayer = datahandler.GetEntity(i)
                hotbar.UpdateAll()
                task.spawn(function()
                    local oldchunk =""
                    local done = false
                    task.spawn(function()
                        srender(hitbox)
                        done = true
                    end)
                while hitbox and model and (model.Parent == workspace.Entities or model.Parent == workspace.DamagedEntities) and true do
                    local currentChunk,c = qf.GetChunkfromReal(qf.cv3type("tuple",hitbox.Position)) 
                    currentChunk = currentChunk.."x"..c
                    task.spawn(function()
                        if currentChunk ~= oldchunk and done then
                            oldchunk = currentChunk
                            srender(hitbox)
                        end
                    end)
                    for i=0,20 do
                        local c =  qf.SortTables(hitbox.Position,toload)
                        game.Players.LocalPlayer.PlayerGui.Debugging.Storage.Text = "ToLoad: "..#c
                        for i,v in c do
                            local chunk = v[1]
                            local cx,cz = qf.cv2type("tuple",chunk)
                            if render.UpdateChunk(cx,cz) then
                                toload[chunk] = nil
                                --break
                            end
                        end
                    end
                    runservicer.Heartbeat:Wait()
                end
                end)
            end
            if entity.Health <= 0 then
                entity:OnHarmed(0)
            end
        end
        if i == tostring(game.Players.LocalPlayer.UserId) then
            if not datahandler.GetEntity(i) or datahandler.GetEntity(i).ClientControl ~= tostring(game.Players.LocalPlayer.UserId) then continue end 
            hotbar.UpdateAll()
            datahandler.GetEntity(i):UpdateEntityClient(v)
            local function combinevelocity(v1,v2)
                for i,v in v2.Velocity or {} do
                    v1:AddVelocity(i,v)
                end
            end
            combinevelocity(datahandler.GetEntity(i),v)
            datahandler.LocalPlayer = datahandler.GetEntity(i)
        end
        if e then
            if  e.PrimaryPart:FindFirstChild('Nametag') then
                e.PrimaryPart.Nametag.Enabled = not oldentity.Crouching 
                if oldentity:GetState('Dead') or oldentity.DisableNameTag then 
                    e.PrimaryPart.Nametag.Enabled = false
                end 
                changetext(e.PrimaryPart.Nametag.Text,e.PrimaryPart.Size.Y/2+1.5)
            end
        end
        if oldentity then
            oldentity:VisuliseHandItem()
            anihandler.UpdateEntity(oldentity)
        end
    end
    if not ClientIndex then return end 
    for i,v in game.Workspace.Entities:GetChildren() do shoulddel(ClientIndex,v) end
    for i,v in game.Workspace.DamagedEntities:GetChildren() do shoulddel(ClientIndex,v) end
end)
function GetChunks(cx,cz)
    queued[cx..','..cz] = true
    game.ReplicatedStorage.Events.GetChunk:FireServer(cx,cz)
end
local chtoup = {}
task.spawn(function()
    while task.wait(.09) do
        for i,v in chtoup do
            chtoup[i] = nil
            task.spawn(function()
                local cx,cz = v:GetNTuple() 
                render.UpdateChunk(cx,cz,true)
                
            end)
        end
    end
end)
bridge.CreateBridge("UpdateBlocks"):Connect(function(data)
   local function addtoup(x,y,z)
    local cx,cy,x,y,z = qf.GetChunkAndLocal(x,y,z)
    local chunk = datahandler.GetChunk(cx,cy)
    if not chunk then return end 
    chtoup[chunk]= chunk
    local cx,cz = chunk:GetNTuple()
    local v3 = Vector3.new(x,y,z)
    local isedge,edges = qf.CheckIfChunkEdge(v3.X,v3.Y,v3.Z)
    if isedge then
        local chx = datahandler.GetChunk(cx+edges.X,cz)
        local chz = datahandler.GetChunk(cx,cz+edges.Y)
        if edges.X ~= 0 and chx then
            chtoup[chx:GetNString()]= chx
        end
        if edges.Y ~= 0 and chz then
            chtoup[chz:GetNString()]= chz
        end
    end
   end
    for i,v in data.Remove or {} do
        local chunk = datahandler.RemoveBlock(v.X,v.Y,v.Z)
        addtoup(v.X,v.Y,v.Z)
    end
    for i,v in data.Add or {} do
        local coords =  v[1]
        datahandler.InsertBlock(coords.X,coords.Y,coords.Z,v[2])
        addtoup(coords.X,coords.Y,coords.Z)
    end
end)
local a = false
game.ReplicatedStorage.Events.GetChunk.OnClientEvent:Connect(function(cx,cz,data)
    toload[cx..','..cz] = true
    queued[cx..','..cz] = false
    -- do
    --     local p = Instance.new("Part")
    --     p.Position =  qf.convertchgridtoreal(cx,cz,4,66,4)
    --     p.Anchored = true
    --     p.Parent = workspace 
    --     p.Material = Enum.Material.Neon
    -- end
    data = require(game.ReplicatedStorage.Chunk).DeCompressVoxels(data)
    datahandler.CreateChunk({Blocks = data},cx,cz)
   if false then  
    local p = Instance.new("Part",workspace)
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Position = Vector3.new(cx*8*3,180,cz*8*3)
   end
end)
function srender(p)
    for v,i in datahandler.LoadedChunks  do
		local splited = v:split(",")
		local vector = Vector2.new(splited[1],splited[2])*settings.ChunkSize.X*settings.GridSize
        local pv = Vector2.new(p.Position.X,p.Position.Z)
		if (vector-pv).Magnitude > 10*settings.ChunkSize.X*settings.GridSize then
           -- print()
            task.spawn( function()
                toload[v] = nil
                queued[v] = nil
                render.DeLoad(splited[1],splited[2])
            end)
        end
	end
    local cx1,cz1 = qf.GetChunkfromReal(qf.cv3type("tuple",p.Position)) 
    local s= qf.GetSurroundingChunk(cx1,cz1,6)
    local passed = 0
    for i,v in qf.SortTables(p.Position,s) do
        v = v[1]
        passed+=1
        local cx,cz = qf.cv2type("tuple",v)
        local ccx,ccz =  qf.GetChunkfromReal(qf.cv3type("tuple",p.Position)) 
        if (ccx ~= cx1 or ccz ~= cz1 )and passed>=6 then
          --  break
        end
        if not datahandler.GetChunk(cx,cz) and not queued[cx..','..cz] then
            GetChunks(cx,cz)
            task.wait(.08)
        end
    end
end
game.ReplicatedStorage.Events.LOAD:FireServer()