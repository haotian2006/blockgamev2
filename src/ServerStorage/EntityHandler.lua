local entity = {}
entity.__index = entity
local https = game:GetService("HttpService")
local genuuid = https.GenerateGUID
local entitydata = game.ServerStorage.Entitys
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
function entity.new(data)
    local self = data or {}
    self.Id = data.Id or genuuid()
    self.Type = data.Type or warn("No Entity Type Giving for:",self.Id) 
    self.Velocity = self.Velocity or {}
    setmetatable(self,entity)
    return self
end
function entity:AddComponent(cpname,cpdata)
    if cpname == "Type" then warn("The Name: 'Type' cannot be used as a component name") end 
    if self[cpname] and type(cpdata) == "table" and cpdata["AddTo"] then
        for i,v in cpdata do
            self[cpname][i] = v
        end
    else
        self[cpname] = cpdata
    end
    return self
end
function entity.Create(type,data)
    local ehand = entitydata:FindFirstChild(type)
    if not ehand then return nil end 
    local self = entity.new({Type = type})
    ehand = require(ehand)
    for cname,cdata in ehand.components do
        self:AddComponent(cname,cdata)
    end
    for cname,cdata in data do
        self:AddComponent(cname.cdata)
    end
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
function entity:Kill()
    
end
function entity:Destroy()
    setmetatable(self,nil) self = nil
end
return entity