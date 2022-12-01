local entity = {}
entity.__index = entity
local https = game:GetService("HttpService")
local genuuid = https.GenerateGUID
function entity.new(data)
    local self = setmetatable({},entity)
    return self
end
function entity.Create(type,data)
    local uuid = genuuid()
    local self = entity.new(data)
end
function entity:GoTo(x,y,z)
    
end
function entity:Jump(Height)
    
end

return entity