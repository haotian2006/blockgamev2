local maths = {Point = {},Line = {}}
local Point,Line = maths.Point , maths.Line
export type Line = typeof(setmetatable({}, {})) & {p1:Point,p2:Point}
export type Point = typeof(setmetatable({}, {})) & {x:number,y:number}
Point.__type,Line.__type = Point, Line
Point.__index,Line.__index = Point,Line
--<Point> Class
Point.__tostring = function(self)
    return self.x..','..self.y
end
for i,v in math do maths[i] = v end -- insert all of the math functions
function maths.newPoint(x:number,y:number):Point
    return setmetatable({x=x,y=y}::Point,Point) 
end
function Point:DistanceFromPoint(p:Point):number
    return math.sqrt((p.x - self.x)^2 + (p.y - self.y)^2)
end
function Point:Vector2():Vector2
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
function Line:Length(self)
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
	
	local goalC0CFrame = relativeToPart1+c0Store.Position--New orientation but keep old C0 joint position
	return goalC0CFrame
end
function maths.angle_between(n, a, b) 
	n = (360 + (n % 360)) % 360;
	a = (3600000 + a) % 360;
	b = (3600000 + b) % 360;
    return not (function() if (a < b) then return  a <= n and n <= b end return a <= n or n <= b
    end)()
end
function maths.GetClosestNumber(num,tab)
    local n 
    for i,v in tab do
        if not n then n = v continue end 
        if math.abs(num - v) < math.abs(num-n) then 
            n = v
        end
    end
    return n
end
function maths.ReflectAngleAcrossY(dt)
    return (360-dt+180)%360
end
function maths.NegtiveToPos(dt)
    return (dt+180)%360
end
return maths