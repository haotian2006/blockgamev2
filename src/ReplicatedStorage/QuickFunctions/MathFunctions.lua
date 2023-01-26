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
function maths.CalculatePointA(o:Vector2,b:Vector2,c:Vector2):Vector2
    local d = Vector2.new(o.X,c.Y)
    local cb,od,dc = (b-c).Magnitude,(o-d).Magnitude,(d-c).Magnitude
    local scale = 1+cb/od
    --DF + 2DF = 12
    --scaleDA = DC
    local ad = dc/scale
    print(ad)
end
return maths