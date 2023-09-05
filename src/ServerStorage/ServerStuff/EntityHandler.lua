local entity = require(game.ReplicatedStorage.EntityHandler)
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local bridgeNet = require(game.ReplicatedStorage.BridgeNet)
local HarmEvent = bridgeNet.CreateBridge('OnEntityHarmed')
local settings = require(game.ReplicatedStorage.GameSettings)
local data = require(game.ReplicatedStorage.DataHandler)
local EAC = require(game.ServerStorage.EntityAttributesCreator)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local entityatr = require(game.ReplicatedStorage.Libarys.EntityAttribute)
local LEntity = data.GetLoadedEntitys()
entity.ServerOnly = {
    "ServerOnly","Data","NotSaved"
}
entity.OwnerOnly = {
    "inventory" ,"Container","Velocity"
}
local function deepCopy(original)
    local copy = {}
    for k, v in original do
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
        if entity.rawGet(self,cpname) == nil then
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
    if entity.rawGet(self,cpname)  == nil then return self:AddComponents(cpname,cpdata,IsFromcomp) end 
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
    local dir = self.Headdir.Unit
    local item = entity.Create('c:Item',{Position = self:GetEyePosition(),Item = name,Count = count })
    self:GetData().AddEntity(item)
    item:KnockBack(Vector3.new(dir.X*3,dir.Y/1.2,dir.Z*3)+Vector3.new(0,.2,0),.2)
end
-- local p = Instance.new("Part",workspace)
-- p.Anchored = true
-- p.Size = Vector3.new(1,5,1)
-- local h = Instance.new("Highlight",p)
-- h.Adornee = p
function entity:UpdateDataServer(newdata)
    if not self.ServerOnly then return end 
    local oldingui = self.Ingui
    local ServerOnlyChanges= self:GetServerChanges()
    local dec = {}
    if newdata.ENCODE then
        dec = self:DECODE(newdata.ENCODE)
        for i,v in dec do
            newdata[i] = v
        end
        newdata.ENCODE = nil
    else
        newdata = self:DECODE(newdata)
    end
    for i,v in newdata do
        if not ServerOnlyChanges[i] then continue end 
        if type(v) == "table" then
            if v.__type == "EntityAttribute" then
                self[i]:Update(v)
            else
                for i1,v1 in v do
                    if v == "__NULL__" then
                        self[i][i1] = nil
                    else
                        self[i][i1] = v1
                    end
                end
            end
            continue
        end
        self[i] = v
    end
    if oldingui and not self.Ingui then
        require(game.ReplicatedStorage.Managers.UIContainerManager).OnCloseGui(self)
    end
    local index = self.CurrentSlot or 1
    local inventory = self.inventory or {Data = {}}
    self.HoldingItem = inventory[index] or {}
end
data.OldData = {interval = 0}
local function finddiffrences(t1,t2,c)
    c = c or {}
    if type(t1) == "table" and type(t2) == "table" then
        local checkedindexs = {}
        for i,v in t1 do
            checkedindexs[i] = true
            if not qf.CompareTables(v,t2[i]) then
                table.insert(c,i)
            end
        end
        for i,v in t2 do
            if checkedindexs[i] then continue end
            if not qf.CompareTables(v,t1[i]) then
                table.insert(c,i)
            end
        end
    else 
        return not t1 == t2
    end
    return #c ~= 0 and c 
end
local lastint = {}  
function entity:ConvertToClient(player,interval)
    local ToSend = {}
    local playerLoaded = LEntity.Get(player)
    local found =  playerLoaded:Find(self.Id)
    local HasOwnerShip = player and self.ClientControl == tostring(player.UserId)
    for i,v in self.__P do 
        if type(v) =="function" or table.find(entity.ServerOnly,i)  then continue end 
        if not HasOwnerShip and table.find(entity.OwnerOnly,i) then continue end
        if found  then
            if type(v) == "table" and type(v.GetUpdated) == "function"then
                ToSend[i] = v:GetUpdated()
                continue
            elseif not self:IsUpdated(i) then
                continue
            end
        end
        if type(v) ~= "table"then ToSend[i] = v continue end 
        if  type(v["Sterilize"]) == "function" then
            ToSend[i] = v:Sterilize()
        else
            ToSend[i] = deepCopy(v)
        end
    end
    if found  then
        for i,v in self.__Update do
            if self.__P[i] == nil then
                ToSend[i] = "__NULL__"
            else
                ToSend[i] = self.__P[i]
            end
        end
    end

    local changed,encoded = self:ENCODE(ToSend,found)
    local nextIsnotnil = next(ToSend) ~= nil
    ToSend =  nextIsnotnil and ToSend or (changed and encoded) or {}
    if  nextIsnotnil then
        ToSend.ENCODE = encoded
        ToSend.Id = found or self.Id
    elseif changed then
        ToSend[5] = found or self.Id
    end
    ToSend.__Last = nil
    return ToSend
end
function entity:ConvertToClientOLD(player,inteval)
    local new = {Container = {}}
    local found =  not table.find(data.loadedentitysforplayer[tostring(player.UserId)] or {},self.Id)
    if data.OldData.interval ~= inteval or not data.OldData[self.Id] or  found or tostring(player.UserId) == self.Id  then
    local HasOwnerShip = player and self.ClientControl == tostring(player.UserId)
    local d 
    if data.OldData.interval == inteval and data.OldData[self.Id] and not HasOwnerShip then
         d = data.OldData[self.Id][2] or {}
    elseif data.OldData.interval == inteval  then
        local old = not found and lastint[self.Id] and lastint[self.Id][3] or {}
        d = finddiffrences(old,self) or {}
    else
        local old = not found and data.OldData[self.Id] and data.OldData[self.Id][3] or {}
        d = finddiffrences(old,self) or {}
    end
    --if self.Id == "Npc1" then print(table.concat(data.loadedentitysforplayer[tostring(player.UserId)] or {},'/')) end 
    for i,v in self do 
        if i == "Container" then continue end 
        if type(v) ~="function" and not table.find(entity.ServerOnly,i) and (not table.find(entity.OwnerOnly,i) or  HasOwnerShip) and table.find(d,i)  then
            if type(v) =="table" and not v["ServerOnly"] then
                if v.__type == "EntityAttribute" or  type(v["Sterilize"]) == "function" then
                    new[i] = v:Sterilize()
                else
                    new[i] = deepCopy(v)
                end
            else
                new[i] = v
            end
        end
    end
    if HasOwnerShip then 
        for i,v in self.Container or {} do
            if type(v) ~="function" and not table.find(entity.ServerOnly,i) and (not table.find(entity.OwnerOnly,i) or  HasOwnerShip)  then
                if type(v) =="table" and not v["ServerOnly"] then
                    if v.__type == "EntityAttribute" then
                        new.Container[i] = v:Sterilize()
                    else
                        new.Container[i] = deepCopy(v)
                    end
                else
                    new.Container[i] = v
                end
            end
        end
    end
    new.CurrentHandItem = self:GetItemFromSlot(self.CurrentSlot or 1)
    if not HasOwnerShip then 
        new.NotSaved = nil
        new["Container"] = nil
        new["CurrentHandItem"] = nil
    end
    if data.OldData.interval ~= inteval then
        lastint = data.OldData
        data.OldData = {interval = inteval}
    end
    if not data.OldData[self.Id] and (not HasOwnerShip or #game.Players:GetPlayers() == 1) then
        data.OldData[self.Id] = {new,d,qf.deepCopy(self)}
    end
    else
        new = data.OldData[self.Id][1]
    end 
    if self.Type == "c:Item" then
      --  print(new)
    end
    return new
end
function entity:DoBehaviors(dt)
    for i,v in self:GetAllData('behavior') or {} do
        local beh = behhandler.GetBehavior(i)
        if beh and not ( beh["CNRIC"] and  self.ClientControl) then
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
function entity:GetEvent(name)
    local events = behhandler.GetEntity(self.Type)
    if events and events.events then
        return events.events[name]
    end
end
function entity:Damage(amt)
    if not self.Health or entity.God then return end 
    self.Health -= amt
    if self.Health <= 0 then
        self:SetState("Dead",true) 
        self.PlayingAnimations:Clear()
        self:SetNetworkOwner()
        if type(self:GetEvent('OnDeath') or true ) =='function' then
            self:GetEvent('OnDeath')(self)
        end
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