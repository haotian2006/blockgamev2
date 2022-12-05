local entity = {}
entity.__index = entity
local https = game:GetService("HttpService")
local genuuid = https.GenerateGUID
function entity.new(data)

    local self = data or {}
    self.Id = self.Id or genuuid()
    self.Velocity = self.Velocity or {}
    setmetatable(self,entity)
    
    return self
end
function entity.Create(type,data)
    local self = entity.new(data)
    return self
end
function entity:GetVelocity():Vector3
    local x,y,z = 0,0,0
    for i,v in self.Velocity do
        if typeof(v) == "Vector3" then
            x+= v.X
            y+= v.Y
            z+= v.Z
        end
    end
    if x == 0 then
        x = 0.00000001
    end
    if z == 0 then
        z = 0.00000001
    end
    return Vector3.new(x,y,z)
end
function entity:Update()
    local velocity = self:GetVelocity()
end
function entity:GoTo(x,y,z)
    
end
function entity:Jump(Height)
    
end
return entity