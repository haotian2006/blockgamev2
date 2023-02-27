local entity = require(game.ReplicatedStorage.EntityHandler)
local behhandler = require(game.ServerStorage.BehaviorHandler)
entity.ServerOnly = {
    "ServerOnly","Data","behaviors"
}
entity.OwnerOnly = {
    "inventory" 
}
function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = deepCopy(v)
        end
    copy[k] = v
    end
    return copy
end
function entity.Create(type,data)
    local ehand = behhandler.GetEntity(type)
    if not ehand then return nil end 
    local self = entity.new({Type = type})
    if not self then return end 
    for cname,cdata in ehand.components or {} do
        self:AddComponent(cname,cdata)
    end
    for cname,cdata in data or {} do
        self:AddComponent(cname,cdata)
    end
    return self
end
function entity:GetBehaviorData(beh)
    if self["behaviors"] then
        return self["behaviors"][beh]
    end
end
function entity:CheckIfBehaviorIsSame(b1,b2)
    --print(b1,b2)
    local b1d,b2d = self:GetBehaviorData(b1),self:GetBehaviorData(b2)
    if not b1d or not b2d then return end
    b1,b2 = behhandler.GetBehavior(b1),behhandler.GetBehavior(b2)
    b1,b2 = b1d['bhtype'] or b1['bhtype'] or "deafult",b2d['bhtype'] or b2['bhtype'] or "deafult2"
    b1,b2 = type(b1) == "string" and {b1} or b1,type(b2) == "string" and {b2} or b2
    for i,v1 in b1 do
        for i,v2 in b2 do
            if v2 == v1 then return true end 
        end
    end
end
function entity:BehaviorCanRun(behavior,bhdata,Stop,CanNotBeSelf)
    local bh = behhandler.GetBehavior(behavior)
    local priority =  bhdata["priority"] or bh["priority"] or 10
    local ishighest = true
    local islower = {}
    for bh1,isrunning in self.NotSaved["behaviors"] do
        if self:CheckIfBehaviorIsSame(behavior,bh1) and isrunning then
            if (bh1 == behavior and CanNotBeSelf) then
                ishighest = false
                break
            end 
            if (self.behaviors[bh1]["priority"] or 10) > priority then
                if Stop then
                    islower[bh1] = true
                end
            else
                ishighest = false
                break
            end
        end
    end
    if ishighest and Stop then
        for i,v in islower do
            self.NotSaved["behaviors"][i] = nil
        end
    end
    return ishighest
end
function entity:AddComponent(cpname,cpdata)
    if entity.SpecialNames[cpname]  then warn("The Name: '"..cpname.."' cannot be used as a component name",self) return self end 
    local split = cpname:split(".")
    if split[1] == "behavior" then  self.behaviors = self.behaviors or {} self = self.behaviors  end 
    if self[cpname] and type(cpdata) == "table" and cpdata["AddTo"] then
        for i,v in cpdata do
            if i == "AddTo" then continue end 
            self[cpname][i] = v
        end
    else
        self[cpname] = cpdata
    end
    if split[1] == "behavior" then
        local bhdata = behhandler.GetBehavior(cpname)
        if bhdata and bhdata["RunAtStart"] then task.spawn(bhdata.func,self,cpdata) end 
    end
    return self
end
function entity:UpdateDataServer(newdata)
    if not self.ServerOnly then return end 
    local ServerOnlyChanges = {Position = true,HeadLookingPoint = true,BodyLookingPoint = true,Crouching = true,PlayingAnimations = true,PlayingAnimationOnce = true,Speed = true,CurrentSlot = true,"VeiwMode"}
    for i,v in self.ServerOnly.ClientChanges or {} do
        ServerOnlyChanges[i] = v
    end
    for i,v in newdata do
        if ServerOnlyChanges[i] then
            self[i] = v
        end
    end
    local index = self.CurrentSlot or 1
    local inventory = self.inventory or {}
    self.HoldingItem = inventory[index] or {}
end
function entity:ConvertToClient(player)
    local new = {}
    local HasOwnerShip = player and self.ClientControll == tostring(player.UserId)
    for i,v in self do
        if type(v) ~="function" and not table.find(entity.ServerOnly,i) and (not table.find(entity.OwnerOnly,i) or  HasOwnerShip)  then
            if type(v) =="table" and not v["ServerOnly"] then
                new[i] = deepCopy(v)
            else
                new[i] = v
            end
        end
    end
    new.CurrentHandItem = self:GetItemFromSlot(self.CurrentSlot or 1)
    return new
end
function entity:DoBehaviors(dt)
    for i,v in self.behaviors or {} do
        local beh = behhandler.GetBehavior(i)
        if beh and not beh["RunAtStart"] and not ( beh["CNRIC"] and  self.ClientControll) then
            task.spawn(function()
                beh.func(self,v)
            end)
        end
    end
end
return {}