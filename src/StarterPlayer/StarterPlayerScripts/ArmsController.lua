local TweenService = game:GetService("TweenService")
local self = {}
local resource = require(game.ReplicatedStorage.ResourceHandler)
local data = require(game.ReplicatedStorage.DataHandler)
local managers = require(game.ReplicatedStorage.Managers)
local hotbarhandler = managers.HotBarManager
local anihandler = require(game.ReplicatedStorage.AnimationController)
local entityhandler = require(game.ReplicatedStorage.EntityHandler)
local lp = game.Players.LocalPlayer
local localentity = data.GetLocalPlayer
local camera = game.Workspace.CurrentCamera
function  self.renderarmitem(dt)
    local entity = localentity()
    local armsframe = self.GetArmsframe()
    if not entity or not armsframe  then return end 
    local Item = entity.HoldingItem or {}
    local entity = self.GetArms()
    if not entity then return nil end 
    local attachment = entity:FindFirstChild("RightAttach",true)
    if not attachment or attachment:FindFirstChild(Item[1] or "") then return nil end 
    local aw = entity.Body["Right Arm"]
    local retracted = aw:FindFirstChild("RT") or Instance.new('BoolValue',aw)
    retracted.Name = 'RT'
    local origaw = resource.GetEntityModelFromData(self.Arms).Body["Right Arm"]
    if Item[1] and Item ~= '' then
        attachment:ClearAllChildren()
        local item = Instance.new("Part")
        item.Size = Vector3.new(1,.1,1)
        item.Parent = attachment
        item.Name = Item[1]
        item.Material = Enum.Material.SmoothPlastic
        local surfacegui = Instance.new('Decal',item)
        surfacegui.Face = Enum.NormalId.Top
        surfacegui.Texture = "http://www.roblox.com/asset/?id=12571457917"
        local a = surfacegui:Clone()
        a.Parent = item
        a.Face = Enum.NormalId.Bottom
        local weld = item:FindFirstChild("HandleAttach") or Instance.new("Motor6D")
        weld.Name = "HandleAttach"
        weld.Part0 = attachment.Parent
        weld.Part1 = item
        weld.C0 = attachment.CFrame*CFrame.new(0,0,-0.5)*CFrame.Angles(0,math.rad(180),0)
        weld.Parent = item
        attachment.Parent.LocalTransparencyModifier = 1
        if not retracted.Value then
            retracted.Value = true
            aw.C0 = origaw.C0*CFrame.new(1,-1.6,-3) *CFrame.Angles(math.rad(90),0,math.rad(20))
        end
    else
        attachment:ClearAllChildren()
        attachment.Parent.LocalTransparencyModifier = 0
        if retracted.Value then
            retracted.Value = false
            aw.C0 = origaw.C0*CFrame.new(.85,-2,-3) *CFrame.Angles(math.rad(130),0,math.rad(20))*CFrame.Angles(0,math.rad(70),0)
        end
    end
end
function  self.PlayAnimation(name,once)
    if not self.Arms then return end 
    if once then
        anihandler.PlayAnimationOnce(self.Arms,name)
    else
        self.Arms.PlayingAnimations[name] = true
    end
end
function self.StopAnimation(name)
    if not self.Arms then return end 
    self.Arms.PlayingAnimations[name] = false
end
function self.Init()
    local entity =  localentity()
    local armsframe = self.GetArmsframe()
    if entity and entity.Entity and armsframe then
        self.Arms = entityhandler.new({Type = "Speical:Arm"})
        self.PlayingAnimations = {}
        armsframe.vp:ClearAllChildren()
        local arms = armsframe.vp:FindFirstChild("PlayerArms") or resource.GetEntity('Speical:Arm').Model:Clone()
        local cam = armsframe:FindFirstChild("Camera") or Instance.new('Camera',armsframe)
        self.cam = cam
        arms.Parent = armsframe.vp
        cam.CFrame = camera.CFrame
        cam.FieldOfView = 60
        armsframe.vp.CurrentCamera = cam
        arms.Parent = armsframe.vp
        arms.Head.CFrame = camera.CFrame
        self.Arms.Entity = arms 
        return true
    end
end
function self.UpdateArms(dt)
    local arms = self.GetArms()
    if not arms or not localentity() or localentity():GetState('Dead') then return end 
    --TweenService:Create(self.cam,TweenInfo.new(.07),{CFrame = camera.CFrame}):Play()
    self.cam.CFrame = camera.CFrame
    local newheadpos = arms.Head.CFrame:Lerp(camera.CFrame,.8)
    local secondheadpos = camera.CFrame- ((camera.CFrame.Position - newheadpos.Position).Unit*.05)
    arms.Head.CFrame = (newheadpos.Position - camera.CFrame.Position).Magnitude <=.05 and newheadpos or secondheadpos 
    anihandler.UpdateEntity(self.Arms)
    self.renderarmitem(dt)
end

function self.GetArmsframe()
    return lp.PlayerGui.Arms
end
function self.GetArms()
    if self.GetArmsframe() then
        return self.GetArmsframe().vp:FindFirstChild("PlayerArms")
    end
end
return self