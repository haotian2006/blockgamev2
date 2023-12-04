local RunService = game:GetService("RunService")
local Entity = require(script.Parent)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local Maths = require(game.ReplicatedStorage.Libarys.MathFunctions)
local Settings = require(game.ReplicatedStorage.GameSettings)
local utils = require(script.Parent.Utils)
local DataHandler = require(game.ReplicatedStorage.DataHandler)
local EntityHolder = require(script.Parent.EntityHolder)
local Render = {}
local DEFAULT_ROTATION = Vector2.new(360,360)
local function createAselectionBox(parent,color) 
    local sb = Instance.new("SelectionBox",parent) 
    sb.Visible = DataHandler.HitBoxEnabled 
    sb.Color3 = color or Color3.new(0.023529, 0.435294, 0.972549) 
    sb.Adornee = parent sb.LineThickness = 0.025 
    return sb 
end
local Humanoid
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
    local hitboxSize = Entity.get(data,"Hitbox")
    hitbox.Size = (Vector3.new(hitboxSize.X,hitboxSize.Y,hitboxSize.X) or Vector3.new(1,1,1))*Settings.GridSize 
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
    local model = Render.findModelFrom(self)
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
    local modeldata = utils.getDataFromResource(self,"Model")
    return ResourceHandler.GetEntityModel(modeldata).Model
end

function Render.createModel(self)
    if self.__model then self.__model:Destroy() self.__model = nil end 
    local hitbox = createHitBox(self)
    local model = createEntityModel(self,hitbox)
    hitbox.PrimaryPart.CFrame = CFrame.new(self.Position*Settings.GridSize )
    self.__model = hitbox
    hitbox.Parent = workspace.Entities
    if Entity.isOwner(self,game.Players.LocalPlayer) then
        require(game.Players.LocalPlayer.PlayerScripts.Controller).setCameraTo(self)
    end
    return hitbox
end
function Render.updateHitbox(self,targetH,targetE)
    local model = self.__model
    if not model then return end 
    if not  (Render.checkIfChanged(self,"EyeLevel") or Render.checkIfChanged(self,"Hitbox")) then return end 
    local EntityModel = model:FindFirstChild("EntityModel")
    if not EntityModel then return end 
    local PrimaryPart =   model.PrimaryPart
    targetH = targetH or Entity.getAndCache(self,"Hitbox")
    PrimaryPart.Size = Vector3.new(targetH.X,targetH.Y,targetH.X)*Settings.GridSize 
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
    if not model then return end 
    model.PrimaryPart.CFrame = CFrame.new(self.Position*Settings.GridSize )
end 

function Render.updateRotation(self,bypass)
    local model:Model = self.__model
    if not model or self.IsDead then return end 
    local cR,cHR = Render.checkIfChanged(self,"Rotation"), Render.checkIfChanged(self,"HeadRotation")
    if not (cR or cHR) and not bypass then return end 
    local neck:Motor6D = self.__cachedData["Neck"] or model:FindFirstChild("Neck",true)
    self.__cachedData["Neck"] = neck
    local mainWeld:Motor6D = self.__cachedData["MainWeld"] or model:FindFirstChild("MainWeld",true)
    self.__cachedData["MainWeld"] = mainWeld
    local rotation = self.Rotation or 0
    local headRotation = self.HeadRotation or Vector2.zero
    local normalhRotX =headRotation.X+rotation
    local dir = Maths.calculateLookAt(normalhRotX ,headRotation.Y,self.Position)
    mainWeld.C0 = CFrame.fromOrientation(0,math.rad(rotation+180),0)+mainWeld.C0.Position
    neck.C0 = (Maths.worldCFrameToC0ObjectSpace(neck,CFrame.new(neck.C0.Position,neck.C0.Position+dir)))

end
local Connection 
function Render.update(entity)
    Render.updateRotation(entity)
    Render.updateHitbox(entity)
    Render.updatePosition(entity)
end

return table.freeze(Render)