local maths = {Point = {},Line = {}}
local Point,Line = maths.Point , maths.Line
export type Line = typeof(setmetatable({}, {})) & {p1:Point,p2:Point,
  DistanceFromPoint: (p:Point) -> number,

}
export type Point = typeof(setmetatable({}, {})) & {x:number,y:number}
 for i,v in math do maths[i] = v end -- insert all of the math functions
Point.__type,Line.__type = Point, Line
Point.__index,Line.__index = Point,Line
--<Point> Class
Point.__tostring = function(self)
    return self.x..','..self.y
end
function maths.newPoint(x:number,y:number):Point
    return setmetatable({x=x,y=y}::Point,Point) 
end
function Point:DistanceFromPoint(p:Point):number
    return math.sqrt((p.x - self.x)^2 + (p.y - self.y)^2)
end
function Point:ToVector2():Vector2
    return Vector2.new(self.x,self.y)
end
--<Line> Class
function maths.newLine(p1:Point,p2:Point):Line
    return setmetatable({p1=p1,p2=p2}::Line,Line) 
end
function Line:CalculateSlopeAndB():(number,number)
    local slope = (self.p1.y-self.p2.y)/(self.p1.x-self.p2.x)
    local b = -((slope*self.p1.x)-self.p1.y)
    return slope,b
end
function Line:Length()
    return math.sqrt((self.p1.x - self.p2.x)^2 + (self.p1.y - self.p2.y)^2)
end
function Line:CalculateMidPoint():Point
    return maths.newPoint((self.p1.x + self.p2.x )/2,(self.p1.y + self.p2.y )/2)
end
function Line:CalculatePointOfInt(L:Line):Point|nil
    local pa,pb,pc,pd = self.p1,self.p2,L.p1,L.p2
    local a1 = pb.y - pa.y local b1 = pa.x - pb.x
    local c1 = a1*(pa.x)+b1*(pa.y)
    local a2 = pd.y - pc.y local b2 = pc.x - pd.x
    local c2 = a2*(pc.x)+b2*(pc.y)
    local det = a1*b2-a2*b1
    if det == 0 then return else
        return maths.newPoint((b2*c1-b1*c2)/det,(a1*c2-a2*c1)/det)
    end 
end
function maths.worldCFrameToC0ObjectSpace(motor6DJoint:Motor6D,worldCFrame:CFrame):CFrame
	local part1CF = motor6DJoint.Part1.CFrame
	local c1Store = motor6DJoint.C1
	local c0Store = motor6DJoint.C0
	local relativeToPart1 =c0Store*c1Store:Inverse()*part1CF:Inverse()*worldCFrame*c1Store
	relativeToPart1 -= relativeToPart1.Position
	
	local goalC0CFrame = relativeToPart1+c0Store.Position
	return goalC0CFrame
end
function maths.angle_between(n:number, a:number ,b:number):boolean 
    n = (360 + (n % 360)) % 360;
	a = (3600000 + a) % 360;
	b = (3600000 + b) % 360;
	local flag = false
	if (a < b) then 
		flag =  a <= n and n <= b 
	else
		flag = a <= n or n <= b
	end 
	return not flag
end
function maths.GetClosestNumber(num:number,tab:{number}):number
    local n 
    for i,v in tab do
        if not n then n = v continue end 
        if math.abs(num - v) < math.abs(num-n) then 
            n = v
        end
    end
    return n
end
function maths.calculateLookAt(xRot,yRot,Position)
    yRot = math.rad(yRot)
    xRot = math.rad(xRot)
    local directionX = math.cos(yRot) * math.sin(xRot)
    local directionY = math.sin(yRot)
    local directionZ = math.cos(yRot) * math.cos(xRot)
    return Vector3.new(directionX,directionY,directionZ).Unit 
end
function maths.normalizeAngle(angle)
    if angle >= 0 and angle < 360 then
        return angle
    end
    angle = angle % 360
    if angle < 0 then
        angle = angle + 360
    end

    return angle
end
function maths.normalizeAngle2(angle)
    if angle >= -180 and angle <= 180 then
        return angle
    end

    angle = angle % 360

    if angle >= 180 then
        angle = angle - 360 
    end
    return angle
end
function maths.convertCWToCCW(angle)
    if angle > 180 then
        angle = angle - 360
    end
    return angle
end
function maths.lerp_angle(a:number, b:number, t:number)--needs fixing
    local gcframe = CFrame.Angles(0,math.rad(a),0)
    local scframe = CFrame.Angles(0,math.rad(b),0)
	local c = scframe:Lerp(gcframe,t)
	local _,y,_ = c:ToEulerAnglesXYZ()
    return math.deg(y)
end
function maths.GetP_YawFromVector3(vector:Vector3)
    local x,y,z = vector.X,vector.Y,vector.Z
    local yRot = math.asin(y)
    local xRot = math.atan2(x, z)

    -- Convert radians to degrees if needed
    xRot = math.deg(xRot)
    yRot = math.deg(yRot)

    return xRot, yRot
end
local EPSILON  = .01
function maths.slerpAngle(angle1, angle2, t)
    if math.abs(angle1-angle2) <=EPSILON then return angle1,true end 
    angle1 = ((angle1 + 180) % 360) - 180
    angle2 = ((angle2 + 180) % 360) - 180
    local angle = angle2 - angle1
    if angle > 180 then
        angle = angle - 360
    elseif angle < -180 then
        angle = angle + 360
    end
    local resultAngle = angle1 + angle * t

    return resultAngle
end
function maths.lerp(start:number,goal:number,value:number):number
    return start + (goal - start) *value
end
function maths.inverselerp(start:number,goal:number,value:number):number
    return (value - start) / (goal - start)
end
function maths.GetXYfromangle(angle:number,radius:number,center:number):number
    local x = radius * math.sin(math.pi * 2 * angle / 360)
    local y = radius * math.cos(math.pi * 2 * angle / 360)
    x,y =math.round(x * 100) / 100,   math.round(y * 100) / 100 
    return center + Vector2.new(x,y)
end
function maths.AngleDifference(angle1:number,angle2:number ):number
    local diff = ( angle2 - angle1 + 180 ) % 360 - 180
    return diff < -180 and diff + 360 or diff
end
function maths.fullToHalf(angle)
    if angle<0 then 
        return(angle + 180) 
    end
    return angle
end
function maths.ReflectAngleAcrossY(dt:number):number
    return (360-dt+180)%360
end
function maths.NegativeToPos(dt:number):number
    return (dt+180)%360
end
function maths.PosToNegative(dt:number):number
    return (dt-180)
end
function maths.GetAngleDL(originalRayVector:number):number
    local new = Vector3.new(1,originalRayVector.Y,1)
    return math.deg(math.atan(new.Unit:Dot(Vector3.new(1,0,1).Unit)))*(originalRayVector.Y/math.abs(originalRayVector.Y))
end
function maths.SpeicalRound(x)
    if x > 0 then
        return math.floor(x)
    else
        return math.ceil(x)
    end
end
return maths