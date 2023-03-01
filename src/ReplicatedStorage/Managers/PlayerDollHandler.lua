local module = {}
module.__index = module
function module.new(frame,modeltouse,FieldOfView,distance,ori)
    local self = setmetatable({},module)
    self.Camera = Instance.new('Camera')
    self.Orientation = ori or CFrame.new()
    self.Camera.FieldOfView = FieldOfView or 60
    self.distance = distance or 15
    self.ToUse =modeltouse
    self.Frame = frame
    self.Frame.CurrentCamera = self.Camera
    self.clone = Instance.new('Part')
    return self 
end
function module:Update()
    local model = self.ToUse or game.Workspace:FindFirstChild(game.Players.LocalPlayer.UserId,true) 
    if not model then
        return 
    end
    local ori = self.Orientation 
    if type(ori) == "number" then
        ori = CFrame.Angles(0,math.rad(ori),0)
    end
	self.clone:Destroy()
	self.clone = model:Clone()
	self.clone.Parent = self.Frame
	self.clone:PivotTo(ori)
	local weld = self.clone:FindFirstChild("MainWeld",true)
	if weld then
		self.Camera.CFrame = CFrame.new(Vector3.new(0,0,0)+weld.C0.LookVector*self.distance,Vector3.new(0,0,0))
	end
end
function module:MakeHeadLookAt(dir)
    
end
return module