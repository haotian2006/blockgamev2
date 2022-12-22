local entity = {}
entity.__index = entity
local https = game:GetService("HttpService")
local genuuid = function()  return https:GenerateGUID(false) end 
local entitydata = game.ServerStorage.Entitys
local CollisionHandler = require(game.ReplicatedStorage.CollisonHandler)
local behhandler = require(game.ServerStorage.BehaviorHandler)
local function interpolate(startVector3, finishVector3, alpha)
    local function currentState(start, finish, alpha)
        return start + (finish - start)*alpha

    end
    return Vector3.new(
        currentState(startVector3.X, finishVector3.X, alpha),
        currentState(startVector3.Y, finishVector3.Y, alpha),
        currentState(startVector3.Z, finishVector3.Z, alpha)
    )
end
local SpecialNames = {
    Data = true,
    Type = true,
    Velocity = true,
    NotSaved = true,
    Id = true,
}
function entity.CheckIfBehaviorIsSame(b1,b2)
    b1,b2 = type(b1) == "string" and {b1} or b1,type(b2) == "string" and {b2} or b2
    for i,v1 in b1 do
        for i,v2 in b2 do
            if v2 == v1 then return true end 
        end
    end
end
function entity.new(data)
    local self = data or {}
    self.Id = data.Id or genuuid()
    self.Position = data.Position or Vector3.new()
    self.Type = data.Type or warn("Failed To Create Entity | No Entity Type Giving for:",self.Id) self:Destroy()
    if not data.Type then return end 
    self.Velocity = self.Velocity or {}
    self.Data = data.Data
    self.NotSaved = {}
    setmetatable(self,entity)
    return self
end
function entity.Create(type,data)
    local ehand = behhandler.GetEntity(type)
    if not ehand then return nil end 
    local self = entity.new({Type = type,Model = type})
    if not self then return end 
    for cname,cdata in ehand.components or {} do
        self:AddComponent(cname,cdata)
    end
    for cname,cdata in data or {} do
        self:AddComponent(cname,cdata)
    end
    return self
end
function entity:BehaviorCanRun(behavior,bhdata)
    local bh = behhandler.GetBehavior(behavior)
    local type,piority = bhdata.bhtype or bh.bhtype or "deafult", bhdata.piority or behavior.piority or 10

end
function entity:AddComponent(cpname,cpdata)
    if SpecialNames[cpname]  then warn("The Name: '"..cpname.."' cannot be used as a component name",self) return self end 
    local split = cpname:split(",")
    if split[1] == "behavior" then  self.behaviors = self.behaviors or {} self = self.behaviors end 
    if self[cpname] and type(cpdata) == "table" and cpdata["AddTo"] then
        for i,v in cpdata do
            self[cpname][i] = v
        end
    else
        self[cpname] = cpdata
    end
    return self
end
function entity:ConvertToClient()
    local new = {}
    for i,v in self do
        if type(v) ~="function" and i ~= "ServerOnly" then
            new[i] = v
        end
    end
    return new
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
        x = -0.00000001
    end
    if z == 0 then
        z = -0.00000001
    end
    return Vector3.new(x,y,z)
end
function entity:DoBehaviors()
    for i,v in entity.behaviors or {} do
        
    end
end
function entity:Update(dt)
  --  local newp = CollisionHandler.entityvsterrain(self,self:GetVelocity())--self.Position + self:GetVelocity()--
 --   self.Position = newp--interpolate(self.Position,newp,dt) 
end
function entity:GoTo(x,y,z)
    
end
function entity:Jump(Height)
    
end
function entity:Kill()

    self:Destroy()
end
function entity:Destroy()
    setmetatable(self,nil) self = nil
end
return entity