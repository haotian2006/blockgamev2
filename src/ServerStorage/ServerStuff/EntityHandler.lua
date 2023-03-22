local entity = require(game.ReplicatedStorage.EntityHandler)
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local bridgeNet = require(game.ReplicatedStorage.BridgeNet)
local HarmEvent = bridgeNet.CreateBridge('OnEntityHarmed')
local settings = require(game.ReplicatedStorage.GameSettings)
local EAC = require(game.ServerStorage.EntityAttributesCreator)
entity.ServerOnly = {
    "ServerOnly","Data"
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
         self:AddComponents(cname,cdata,true)
    end
    for cname,cdata in data or {} do
        self:AddComponents(cname,cdata)
    end
    return self
end
function entity:GetBehaviorData(beh)
    if self then
        return self[beh]
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
            if (self[bh1]["priority"] or 10) > priority then
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
function entity:GetComponentGroupData(name)
    local ehand = behhandler.GetEntity(self.Type)
    if name == true then return ehand.components end 
    if not ehand.component_groups or not ehand.component_groups[name] then return end 
    return ehand.component_groups[name]
end
function entity:CompareComponents(c1,c2)
    local i1,i2 = table.find(self.Componets,c1),table.find(self.Componets,c2)
    if not i2 then return c1 elseif not i1 then return c2 end 
    if not i1 or i1 > i2 then return c2 elseif not i2 or i1 < i2 then return c1 end 
end
function entity:AddComponentGroup(name,index)
    self.Componets = self.Componets or {}
    local cgdata = self:GetComponentGroupData(name)
    if cgdata then
        table.insert(self.Componets,index or 1,name)   
        for i,v in cgdata do
            if not EAC.Find(i) or self:CompareComponents(name,self[i]:GetComponent()) == name then continue end 
            local value,beh = self[i]
            self:UpdateComponets(i,v,name)
        end
    end
end
function entity:RemoveComponentGroup(name)
    self.Componets = self.Componets or {}
    local index = table.find(self.Componets,name)
    if index then
        for i,v in self:GetComponentGroupData(name) or {} do
            if EAC.Find(i) then
                local data,comp = self:IndexFromComponets(i,{name})
                if data == nil then
                    self[i] = nil
                    continue
                end
                self:UpdateComponets(i,data,comp)
            end
        end
        table.remove(self.Componets,index)
    end
end

function entity:AddComponents(cpname,cpdata,IsFromcomp)
    if entity.SpecialNames[cpname]  then warn("The Name: '"..cpname.."' cannot be used as a component name",self) return self end 
    if IsFromcomp then
        local EACd = EAC.Find(cpname)
        if EACd then
            self[cpname] = EACd.new(cpdata,IsFromcomp)
        end
        return 
    end
    if self[cpname] and type(cpdata) == "table" and cpdata["AddTo"] then
        if rawget(self,cpname) == nil then
            self[cpname] = cpdata
        end
        for i,v in cpdata do
            if i == "AddTo" then continue end 
            self[cpname][i] = v
        end
    else
        self[cpname] = cpdata
    end
    return self
end
function entity:UpdateComponets(cpname,cpdata,IsFromcomp)
    if rawget(self,cpname) == nil then return self:AddComponents(cpname,cpdata,IsFromcomp) end 
    local EACd = EAC.Find(cpname)
    if EACd then
        if EACd.update then
            self[cpname] = EACd.update(self[cpname],cpdata,IsFromcomp)
        else
            self[cpname] = EACd.new(self[cpname],cpdata,IsFromcomp)
        end
    end
end
function entity:DropItem(name,count)
    local dir = self.headdir.Unit
    local item = entity.Create('Cubic:Item',{Position = self:GetEyePosition(),Item = name,Count = count })
    self:GetData().AddEntity(item)
    item:KnockBack(Vector3.new(dir.X*3,dir.Y/1.2,dir.Z*3)+Vector3.new(0,.2,0),.2)
end
function entity:UpdateDataServer(newdata)
    if not self.ServerOnly then return end 
    local ServerOnlyChanges = {Position = true,headdir = true,bodydir = true,HeadLookingPoint = true,BodyLookingPoint = true,Crouching = true,PlayingAnimations = true,Speed = true,CurrentSlot = true,VeiwMode = true,CurrentStates = true}
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
    for i,v in self:GetAllData('behavior') or {} do
        local beh = behhandler.GetBehavior(i)
        if beh and not ( beh["CNRIC"] and  self.ClientControll) then
            task.spawn(function()
                beh.func(self,v)
            end)
        end
    end
end
function entity:SetBehaviorValue(name,value)
    self.NotSaved["behaviors"] = self.NotSaved["behaviors"] or {}
    self.NotSaved["behaviors"][name] = value
end
function entity:Damage(amt)
    if not self.Health or entity.God then return end 
    self.Health -= amt
    if self.Health <= 0 then
        self:SetState("Dead",true) 
        self.PlayingAnimations = {}
        self:SetNetworkOwner()
    end
    HarmEvent:FireAllInRange(settings.gridToreal(self.Position),
    settings.gridToreal(settings.GetDistFormChunks(settings.MaxEntityRunDistance)),
    self.Id, 
    amt
    )
end
function entity:Kill()
    self:SetState("Dead",true) 
end
return {}