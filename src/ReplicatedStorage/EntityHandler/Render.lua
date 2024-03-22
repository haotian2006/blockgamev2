--!nocheck
local RunService = game:GetService("RunService")
local Entity = require(script.Parent)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local Maths = require(game.ReplicatedStorage.Libarys.MathFunctions)
local Settings = require(game.ReplicatedStorage.GameSettings)
local utils = require(script.Parent.Utils)
local Data = require(game.ReplicatedStorage.Data)
local ItemClass = require(game.ReplicatedStorage.Item)
local Render = {}
local Player = game:GetService("Players").LocalPlayer
local ClientUtils = require(script.Parent.ClientUtils)
local Core = require(game.ReplicatedStorage.Core)

local DEFAULT_ROTATION = Vector2.new(360,360)
local function createAselectionBox(parent,color) 
    local sb = Instance.new("SelectionBox",parent) 
    sb.Visible = false
    sb.Transparency = .9
    sb.Color3 = color or Color3.new(0.023529, 0.435294, 0.972549) 
    sb.Adornee = parent sb.LineThickness = 0.025 
    return sb 
end
local Humanoid

local function CreateTexture(texture,face) 
 
    local new = Instance.new("Decal")
    new.Texture = type(texture) == "string" and texture or texture.Texture
    new.Face = face
    return new
end 

local sides = {Right = true,Left = true,Top = true,Bottom = true,Back = true,Front =true}
local function createItemModel(Item)
    local itemdata = ItemClass.getItemInfoR(Item)
    if not itemdata  then return end 
    local stuff = {}
    local texture = itemdata.Texture
    local mesh = itemdata.Mesh 
    if not mesh then return end 
    mesh = mesh:Clone()
    if not texture then return mesh,itemdata end 
    if type(texture) == "function" then
        texture = texture(Item)
    end
    if mesh:IsA("MeshPart") and type(texture) == "string" then 
        (mesh::MeshPart).TextureID = texture
        return mesh
    end
    if type(texture) == "table" then
        for i,v in texture do
            table.insert(stuff,CreateTexture(v,i))
        end
    elseif type(texture) == "userdata" or type(texture) == "string" then
        for v in sides do
            table.insert(stuff,CreateTexture(texture,v))
        end
    end
    for i,v in stuff do
        v.Parent = mesh
    end
    return mesh,itemdata
end

local function CreateHumanoid(model)
    if Humanoid then 
        local Humanoidc = Humanoid:Clone() 
        Humanoidc.Parent = model
        return Humanoidc
    end
    local h = Instance.new("Humanoid")
    for i,v in Enum.HumanoidStateType:GetEnumItems() do
        if v ~= Enum.HumanoidStateType.None then
            h:SetStateEnabled(v,false)        
        end
    end
    Instance.new('Animator',h)
    Humanoid = h
    h.Parent = model
    return h
end
local function createEye(offset,hitbox)
    local eye = Instance.new("Part",hitbox.Parent)
    eye.Size = Vector3.new(hitbox.Size.X,0,hitbox.Size.Z)
    eye.Name = "Eye"
    eye.Transparency = 1
    local weld = Instance.new("Motor6D",eye)
    weld.Part0 = hitbox
    weld.Part1 = eye
    weld.Name = "EyeWeld"
    weld.C0 = offset and CFrame.new(Vector3.new(0,offset/2,0)*Settings.GridSize) or CFrame.new()
    return eye
end


local function createHitBox(data)
    local model = Instance.new("Model")
    local hitbox = Instance.new("Part",model)
    local hitboxSize = Entity.getHitbox(data)
    hitbox.Size = (hitboxSize or Vector3.new(1,1,1))*Settings.GridSize 
    local eye = createEye(Entity.get(data,"EyeLevel"),hitbox)
    createAselectionBox(hitbox)
    createAselectionBox(eye,Color3.new(1, 0, 0)).Parent = hitbox
    hitbox.CanCollide = false
    hitbox.Anchored = true
    hitbox.Transparency = 1
    hitbox.Name = "Hitbox"
    model.Name = data.Guid
    model.PrimaryPart = hitbox
    return model
end

local function createEntityModel(self,hitbox)
    local model = ClientUtils.getAndCache(self, "Model")
    if not model then return end 
    if type(model) == "function" then
        model = model(self)
    end
    if not model then return end 
    model = model:Clone()
    local humanoid = model:FindFirstChildWhichIsA("Humanoid")  or CreateHumanoid(model)
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new('Animator',humanoid)
    humanoid.Name = "AnimationController"
    humanoid.RigType = Enum.HumanoidRigType.R6
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.RequiresNeck = false
    humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    model.Parent = hitbox
    model.Name = "EntityModel"
    local weld = Instance.new("Motor6D",hitbox.PrimaryPart)
    weld.Name = "EntityModelWeld"
    weld.Part0 = hitbox.PrimaryPart
    weld.Part1 = model.PrimaryPart
    return model
end


function Render.renderHolding(self,holding,special)

    local Item = holding or self.Holding or ""
    local Name = type(Item) == "table" and ItemClass.tostring(Item) or ""
    local entity = self.__model
    if not entity then return  end 
    local cache = Entity.getCache(self)
    local attachment = cache["RENDER_RightAttach"]
    if not attachment then
        attachment =     entity:FindFirstChild("RightAttach",true)
        cache["RENDER_RightAttach"] = attachment
    end
    
    if not attachment or attachment:FindFirstChild(Name or "") then return Name  end 

    local function  createPlaceHolder()
        local item = Instance.new("Part")
        item.Size = Vector3.new(1,.1,1)
        item.Parent = attachment
        item.Name = Name

        local surfacegui = Instance.new("SurfaceGui",item)
        surfacegui.Face = Enum.NormalId.Top
        local txt = Instance.new('TextLabel',surfacegui)
        txt.Size = UDim2.new(1,0,1,0)
        txt.TextScaled = true
        txt.Text = Name
        local a = surfacegui:Clone()
        a.Parent = item
        a.Face = Enum.NormalId.Bottom
        a.TextLabel.Rotation = 180

        local weld = item:FindFirstChild("HandleAttach") or Instance.new("Motor6D")
        weld.Name = "HandleAttach"
        weld.Part0 = attachment.Parent
        weld.Part1 = item
        weld.C0 = attachment.CFrame*CFrame.new(0,0,-0.5)*CFrame.Angles(0,math.rad(-90),0)
        weld.Parent = item
        return item,nil
    end

    local function createitem()
        local mesh,data = createItemModel(Item)
        if not mesh then return end 
        mesh.Parent = attachment
        mesh.Name = Name
        local handle = mesh:FindFirstChild("Handle",true) or mesh 
        local weld = mesh:FindFirstChild("HandleAttach",true) or Instance.new("Motor6D")
        weld.Name = "HandleAttach"
        weld.Part0 = attachment.Parent
        weld.Part1 = mesh
        weld.C0 = attachment.CFrame
        weld.C1 = handle.CFrame
        weld.Parent = mesh
        return mesh,data
    end
    
    attachment:ClearAllChildren()
    if Item and Item ~= '' then
        if special then
            special()
        end
        local item,ItemData = createitem() 
        if not Item then 
            item,ItemData =  createPlaceHolder()
        end 
        if special then
            special(item)
            return item,ItemData
        end
        if self.__CameraMode == "First" or (self.__CameraMode == nil and Entity.isOwner(self, Player)) then
            Render.setTransparencyOfModel(item.Parent,1)
        end
        return item,ItemData
    end
    return 
end

function Render.setTransparencyOfModel(model,t)
    for i,v:BasePart|Texture|Decal in model:GetDescendants() do
        if v:IsA("Texture") or v:IsA("Decal") then
            v.Transparency = t
        end
        if not v:IsA("BasePart") or v.Transparency == 1 then continue end 
        v.LocalTransparencyModifier = t
    end
end

function Render.setTransparency(entity,value)
    local model = entity.__model
    if not model then return end 
    Render.setTransparencyOfModel(model, value)
end

function  Render.checkIfChanged(self,key)
    if not self.__old then self.__old = {} end 
    local current = Entity.getAndCache(self,key)
    if self.__old[key] ~= current then
        self.__old[key] = current
        return true
    end
    return false
end
function Render.findModelFrom(self)
    return ClientUtils.getAndCache(self, "Model")
end

function Render.createModel(self)
    if self.__model then self.__model:Destroy() self.__model = nil end 
    local hitbox = createHitBox(self)
    createEntityModel(self,hitbox)
    --hitbox.PrimaryPart.CFrame = CFrame.new(self.Position*Settings.GridSize )
    --hitbox:PivotTo( CFrame.new(self.Position*Settings.GridSize ))
    self.__model = hitbox
    if Entity.isOwner(self,game.Players.LocalPlayer) and  Core.Client then
        Core.Client.Controller.getCamera().bindToEntity(self)
    end
    Render.renderHolding(self)

    if Data.getPlayerEntity() == self then
       -- Render.setTransparency(self,1) 
    end
    hitbox.Parent = workspace.Entities
    return hitbox
end

function Render.updateHitbox(self,targetH,targetE)
    local model = self.__model
    if not model then return end 
    if not  (Render.checkIfChanged(self,"EyeLevel") or Render.checkIfChanged(self,"Hitbox")) then return end 
    local EntityModel = model:FindFirstChild("EntityModel")
    if not EntityModel then return end 
    local PrimaryPart =   model.PrimaryPart
    targetH = targetH or Entity.getHitbox(self)
    PrimaryPart.Size = targetH*Settings.GridSize 
    local MiddleOffset = PrimaryPart.Size.Y-(PrimaryPart.Size.Y/2+EntityModel.PrimaryPart.Size.Y/2)
    local pos =PrimaryPart.Position 
    EntityModel.PrimaryPart.CFrame = CFrame.new(pos.X,pos.Y-MiddleOffset,pos.Z)
    local weld = PrimaryPart:FindFirstChild("EntityModelWeld")
    weld.C0 = CFrame.new(0,-MiddleOffset,0)
    
    local eyeweld = model:FindFirstChild("Eye"):FindFirstChild("EyeWeld")
    local offset = targetE or Entity.get(self,"EyeLevel")
    if not eyeweld then return end 
    eyeweld.C0 = offset and CFrame.new( Vector3.new(0,offset/2,0)*3) or CFrame.new()
    task.delay(.05,function()
        Render.updateRotation(self,true)
        Render.updatePosition(self)
    end) -- werid bug with head rotation
end

function Render.updatePosition(self)
    local model = self.__model
    if not model or not model.PrimaryPart then return end 
    model.PrimaryPart.CFrame = CFrame.new((self.Position)*Settings.GridSize )
end 

function Render.updateRotation(self,bypass)
    local model:Model = self.__model
    if not model or self.IsDead then return end 
    local cR,cHR = Render.checkIfChanged(self,"Rotation"), Render.checkIfChanged(self,"HeadRotation")
    if not (cR or cHR) and not bypass then return end 
    local neck:Motor6D = self.__cachedData["Neck"] or model:FindFirstChild("Neck",true)
    self.__cachedData["Neck"] = neck
    local mainWeld:Motor6D = self.__cachedData["MainWeld"] or model:FindFirstChild("MainWeld",true)
    if not mainWeld then return end 
    self.__cachedData["MainWeld"] = mainWeld
    local rotation = self.Rotation or 0
    local headRotation = self.HeadRotation or Vector2.zero
    local normalhRotX =headRotation.X+rotation
    local dir = Maths.calculateLookAt(normalhRotX ,headRotation.Y,self.Position)
    local mainc0 = CFrame.fromOrientation(0,math.rad(rotation+180),0)+mainWeld.C0.Position
    if mainc0 == mainc0 then
        mainWeld.C0 = mainc0
    end
    local neckC0 =  (Maths.worldCFrameToC0ObjectSpace(neck,CFrame.new(neck.C0.Position,neck.C0.Position+dir)))
    if neckC0 == neckC0 then
        neck.C0 = neckC0
    end

end
local Connection 
function Render.update(entity)
    Render.updateRotation(entity)
    Render.updateHitbox(entity)
    Render.updatePosition(entity)
    local Update = ClientUtils.getAndCache(entity, "Update")
    if not Update then return end 
    Update(entity)
end

return table.freeze(Render)