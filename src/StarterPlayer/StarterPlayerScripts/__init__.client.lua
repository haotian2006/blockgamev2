
local qf = require(game.ReplicatedStorage.QuickFunctions)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local EntityBridge = bridge.CreateBridge("EntityBridge")
--bridge.Start({})
local GetChunk = bridge.CreateBridge("GetChunk")
local datahandler = require(game.ReplicatedStorage.DataHandler)
local mulithandler = require(game.ReplicatedStorage.MultiHandler)
local toload = {}
local currentlyloading = {}
local queued = {}
local anihandler = require(game.ReplicatedStorage.AnimationController)
local render = require(game.ReplicatedStorage.RenderStuff.Render)
local settings = require(game.ReplicatedStorage.GameSettings)
local resource = require(game.ReplicatedStorage.ResourceHandler)
resource:Init()
local control = require(script.Parent.Controller)
local inventory = require(game.ReplicatedStorage.Managers.InventoryManager)
local hotbar = require(game.ReplicatedStorage.Managers.HotBarManager)
local entityhandler = require(game.ReplicatedStorage.EntityHandler)
local Players = game:GetService("Players")
local tweenservice = game:GetService("TweenService")
local runservicer = game:GetService("RunService")

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
    local model = resource.GetEntityModelDataFromData(Data)
    if model then
        model = model.Model
        model = model:Clone()
        local humanoid = model:FindFirstChildWhichIsA("Humanoid") or model:FindFirstChildWhichIsA("AnimationController")  or Instance.new("AnimationController",model)
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator",humanoid)
        humanoid.Name = "AnimationController"
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
    if datahandler.LoadedEntities[entitid] then
        if type(property) == "table" then
            local tab = datahandler.LoadedEntities[entitid]
            for i,v in ipairs(property) do
                if i == #property then
                    tab[v] = 5
                else
                    tab[v] = tab[v] or {}
                    tab = tab[v] 
                end
            end
        else
            datahandler.LoadedEntities[entitid][property] = value
        end
    end
end)
game.ReplicatedStorage.Events.EntityUpdater.OnClientEvent:Connect(function(entityId,newdata,dostuff)
    if datahandler.LoadedEntities[entityId] then
        local e = datahandler.LoadedEntities[entityId]
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
bridge.CreateBridge("DoMover"):Connect(function(entity,Mover,...)
    local mover = game.ReplicatedStorage.EntityMovers:FindFirstChild(Mover)
    if mover and datahandler.LoadedEntities[entity] then
        require(mover).new(datahandler.LoadedEntities[entity],...)
    end
end)
EntityBridge:Connect(function(entitys)
    for i,v in game.Workspace.Entities:GetChildren() do
        if not entitys[v.Name] then
            v:Destroy()
            i = v.Name
            if datahandler.LoadedEntities[i] then
                local last = datahandler.LoadedEntities[i]
                local chunk = datahandler.GetChunk(last.Chunk.X,last.Chunk.Y)
                datahandler.LoadedEntities[i]:Destroy()
            end
        end
    end
    for i,v in entitys do
        local e = game.Workspace.Entities:FindFirstChild(i)
        local oldentity = datahandler.LoadedEntities[i]
        if e and tostring(i) ~= tostring(Players.LocalPlayer.UserId) then
            local oldhitbox = oldentity.HitBox
            datahandler.LoadedEntities[i]:UpdateEntity(v)
            if oldentity and v.HitBox ~= oldhitbox then
                if oldentity.Tweens and oldentity.Tweens["Pos"] then
                    oldentity.Tweens["Pos"]:Cancel()
                end
                e.PrimaryPart.Size = Vector3.new(v.HitBox.X,v.HitBox.Y,v.HitBox.X)*3
                e.PrimaryPart.CFrame = CFrame.new(v.Position*3)
                oldentity:UpdateModelPosition()
            else
                oldentity.Tweens = oldentity.Tweens or {}
                oldentity.Tweens["Pos"] = tweenservice:Create(e.PrimaryPart,TweenInfo.new(0.1),{CFrame = CFrame.new(v.Position*3)})
                oldentity.Tweens["Pos"]:Play()
            end
            oldentity:UpdateRotationClient(true)
            oldentity:VisuliseHandItem()
        elseif not e then
            local entity = entityhandler.new(v)
            datahandler.AddEntity(i,entity)
            local model = Instance.new("Model",workspace.Entities)
            entity.Entity = model
            local hitbox = Instance.new("Part",model)
            model.PrimaryPart = hitbox
            hitbox.Size = (Vector3.new(v.HitBox.X,v.HitBox.Y,v.HitBox.X) or Vector3.new(1,1,1))*settings.GridSize 
            local eye = createEye(v.EyeLevel,hitbox)
            local eyebox = createAselectionBox(eye,Color3.new(1, 0, 0))
            eyebox.Parent = hitbox
            CreateModel(v,model)
            entity:UpdateModelPosition()
            createAselectionBox(hitbox)
            hitbox.CanCollide = false
            hitbox.Anchored = true
            hitbox.Transparency = 1
            hitbox.Name = "HitBox"
            hitbox.CFrame = CFrame.new(v.Position*3)
            model.Name = i
            local nametag = game.ReplicatedStorage.Assets.Nametag:Clone()
            nametag.Parent = hitbox
            nametag.Text.Text = v.Name or v.Id
            e = model
           -- entity:UpdateRotationClient()
           oldentity = entity
            if i == tostring(game.Players.LocalPlayer.UserId) then
                workspace.CurrentCamera.CameraSubject = eye
                datahandler.LocalPlayer = datahandler.LoadedEntities[i]
                hotbar.UpdateAll()
                task.spawn(function()
                    local oldchunk =""
                    local done = false
                    task.spawn(function()
                        srender(hitbox)
                        done = true
                    end)
                    print(hitbox and model and model.Parent == workspace.Entities and true)
                while hitbox and model and model.Parent == workspace.Entities and true do
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
        end
        if i == tostring(game.Players.LocalPlayer.UserId) then
            datahandler.LoadedEntities[i]:UpdateEntityClient(v)
            local function combinevelocity(v1,v2)
                for i,v in v2.Velocity do
                    v1:AddVelocity(i,v)
                end
            end
            combinevelocity(datahandler.LoadedEntities[i],v)
            datahandler.LocalPlayer = datahandler.LoadedEntities[i]
        end
        if e then
            e.PrimaryPart.Nametag.Enabled = not oldentity.Crouching 
            changetext(e.PrimaryPart.Nametag.Text,e.PrimaryPart.Size.Y/2+1.5)
        end
        if oldentity then
            anihandler.UpdateEntity(oldentity)
        end
    end
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
    chtoup[chunk:GetNString()]= chunk
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
        local coords =  Vector3.new(unpack(i:split(',')))
        datahandler.InsertBlock(coords.X,coords.Y,coords.Z,v)
        addtoup(coords.X,coords.Y,coords.Z)
    end
end)
game.ReplicatedStorage.Events.GetChunk.OnClientEvent:Connect(function(cx,cz,data)
    toload[cx..','..cz] = true
    queued[cx..','..cz] = false
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
    local s= qf.GetSurroundingChunk(cx1,cz1,7)
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