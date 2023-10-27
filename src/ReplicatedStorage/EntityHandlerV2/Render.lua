local Entity = require(script.Parent)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local Maths = require(game.ReplicatedStorage.Libarys.MathFunctions)
local utils = require(script.Parent.Utils)
local Render = {}
local DEFAULT_ROTATION = Vector2.new(360,360)
function Render.updateModel(self)
    local model = self.__model
end 
function convert_and_clamp_angle(angle, new_min, new_max)
    -- Convert the angle to the range [-180, 180]
    local converted_angle = (angle - 180) % 360 - 180

    -- Clamp the converted angle to the new range [-50, 50]
    if converted_angle < new_min then
        return new_min
    elseif converted_angle > new_max then
        return new_max
    else
        return converted_angle
    end
end
local xX = 0
function Render.updateRotation(self)
    local model:Model = self.__model
    local Resource = ResourceHandler.GetEntity(self.Type)
    local maxNeckRot = Resource.NeckRotation or DEFAULT_ROTATION
    if not model or self.IsDead then return end 
    local neck:Motor6D = self.__cachedData["Neck"] or model:FindFirstChild("Neck",true)
    self.__cachedData["Neck"] = neck
    local mainWeld:Motor6D = self.__cachedData["MainWeld"] or model:FindFirstChild("MainWeld",true)
    self.__cachedData["MainWeld"] = mainWeld
   -- self.Rotation = 0
   -- self.HeadRotation = Vector2.new(0,0)
    local rotation = self.Rotation or 0
    local headRotation = self.HeadRotation or Vector2.zero
    local maxHX = maxNeckRot.X
    local minHX = 360-maxHX
    -- if maxHX < minHX then
    --     local temp = minHX
    --     minHX = maxHX
    --     maxHX = temp
    -- end
    --[[
    local _,mainWeldDegree  = mainWeld.C0:ToOrientation()
    mainWeldDegree = math.deg(mainWeldDegree)
    local _,xdegree = neck.C0:ToEulerAnglesYXZ()
    xdegree = math.deg(xdegree)]]
    local normalhRotX = Maths.normalizeAngle(headRotation.X+rotation)
 --   print(xdegree,hRotX)
 --[[
    local hRotX = convert_and_clamp_angle(normalhRotX-mainWeldDegree,-maxHX,maxHX)
   -- print(normalhRotX,mainWeldDegree,normalhRotX-mainWeldDegree,"1111")
    hRotX = Maths.fullToHalf(hRotX)
    print(hRotX,normalhRotX)
    local headX =headRotation.X
    if headRotation.X-hRotX > 0 then
        xdegree = math.deg(xdegree)
        headX = rotation+(headRotation.X)
        rotation+=headRotation.X-hRotX
      --  print(headRotation.X-hRotX,headRotation,hRotX,"|||",ohRotX,ohRotX2)
    else
        headX = normalhRotX
    end]]
   -- print(hRotX + rotation+( headRotation.X-hRotX),rotation-( headRotation.X-hRotX))
    local dir = Maths.calculateLookAt(normalhRotX ,headRotation.Y,self.Position)
  --  print(headRotation.X,hRotX,hRotX + rotation)
    neck.C0 = (Maths.worldCFrameToC0ObjectSpace(neck,CFrame.new(neck.C0.Position,neck.C0.Position+dir)))
   mainWeld.C0 = CFrame.fromOrientation(0,math.rad(Maths.normalizeAngle(rotation)+180),0)+mainWeld.C0.Position
  -- _,xdegree  = mainWeld.C0:ToEulerAnglesXYZ()
   --print(math.deg(xdegree),Maths.normalizeAngle(rotation))
     xX = Maths.normalizeAngle(xX - (self.t and  .3 or -.3))
   -- print(xX,Maths.normalizeAngle(rotation),rotation)
    -- self.HeadRotation = Vector2.new(xX,0)
   -- print(xX)
    utils.rotateHeadTo(self,Vector2.new(xX,0))

end

return Render