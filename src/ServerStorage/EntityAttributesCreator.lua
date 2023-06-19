local EntityAttribute = require(game.ReplicatedStorage.Libarys.EntityAttribute)
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local self = {}
self.Attributes = {}
self.Shared = {
    
}
function _ipairs(a, i)
    i = i + 1
    local v = a[i]
    if v then
      return i, v
    end
  end
  
self.Attributes.inventory = {
    new = function(info,comp)
        local newAtt = EntityAttribute.new('inventory',table.create(info or 0,''),self.Attributes.inventory.Methods)
        newAtt:SetComponent(comp)
        return newAtt
    end,
    update = function(self,newinfo,comp)
        local data = self:GetData()
        if #data < newinfo then
            for i = #data+1, newinfo do
                data[i] = ""
            end
        elseif #data > newinfo then
            for i = newinfo+1, #data do
                data[i] = nil
            end
        end
        self:SetComponent(comp)
        return self
    end,
    Methods = { 
        add = function(self,Item,count)
            local count = count
            local itemname = qf.DecompressItemData(Item,'T') 
            local iteminfo = behhandler.GetItem(itemname)
            if not iteminfo then return end 
            local max = iteminfo.maxCount
            --local spliited = qf.DecompressItemData(Item,'T') 
            while count > 0 do
                local i = self:find(Item,nil,true) or self:getEmpty()
                if i then
                    local v = self[i]
                    local add = 0
                    if type(v) == "table"  then
                        if  v[2] < max then
                            add = (max-v[2])
                            if count < add then
                                add = count
                            end
                            self[i][2] += add
                        end
                    else
                        if count <= max then
                            add = count
                        else
                            add = max 
                        end
                        self[i] = {Item,add}
                    end
                    count -= add
                else
                    break
                end
            end
            return count
        end,
        set = function(self,index,id,count)
            index = index or 1
            self[index] = {id,count}
        end,
        setAt = function(self,index,Itemdata,count)
            if index == "Output" then return Itemdata,count,true end 
            index = index or 1
            local Item = qf.DecompressItemData(Itemdata,'T') 
            local iteminfo = behhandler.GetItem(Item)
            if not iteminfo then return end 
            local max = iteminfo.maxCount
            local v = self[index]
            local add = 0
            if type(v) == "table" and v[1] == Itemdata  then
                if  v[2] < max then
                    add = (max-v[2])
                    if count < add then
                        add = count
                    end
                    self[index][2] += add
                    count -= add
                else
                    local a= self[index][2]
                    self[index][2] = count
                    count = a
                end
            elseif type(v) == "table" and v[1] ~= Itemdata then
                local old,c = v[1],v[2]
                v[1] = Itemdata
                v[2] = count
                Itemdata = old
                count = c
            else
                self[index] = {Itemdata,count}
                count= 0
            end
            return Itemdata,count
        end,
        find = function(self,Item:string,Id,CannotBeFull)
            for i,v in self do
                if i == "Output" then continue end 
                if type(v) == "table" then
                    local spliited = v[1]
                    local ItemName = qf.DecompressItemData(spliited,'T') 
                    if not Item:find('T|') then
                        spliited = ItemName
                    end
                    if spliited == Item then
                        if CannotBeFull and v[2] >= behhandler.GetItem(ItemName).maxCount then
                            continue
                        end
                        return i
                    end
                end
            end
        end,
        __iter = function(self)
            return _ipairs,self.Data,0
        end,
        getEmpty = function(self)
            return table.find(self.Data,'')
        end,
        canFit = function(self,Item,Id)
            return self.find(Item,Id,true) or self.getEmpty(self) 
        end
    },
}
self.Attributes.crafting = {
    new = function(info,comp)
        local tbl = table.create(info or 0,'')
        tbl["Output"] = ""
        local newAtt = EntityAttribute.new('crafting',tbl,self.Attributes.crafting.Methods)
        newAtt:SetComponent(comp)
        return newAtt
    end,
    Methods = { 
        add = self.Attributes.inventory.Methods.add,
        set = self.Attributes.inventory.Methods.set,
        setAt = self.Attributes.inventory.Methods.setAt,
        find = self.Attributes.inventory.Methods.find,
        __iter = function(self)
            return next,self.Data,nil
        end,
        getEmpty = self.Attributes.inventory.Methods.getEmpty,
        canFit = self.Attributes.inventory.Methods.canFit,
        __Changed = function(self,key,value)
            local crafting = require(game.ReplicatedStorage.Managers).CraftingManager
            local item,count,id,remove = crafting.GetOutResult(self)
            local it
            if item then
                it = "T|s%"..item
                if id then it ..='/n%'..id end
                self:rawset("Output",{it,count})
            else
                self:rawset("Output","")
            end
            return it,count,remove
        end,
        OnClick = function(self,index,amt,Container)
            if index ~= "Output" then return end
            local item,count,remove = self.__Changed(self,"Output")
            if item then
                if type(Container.HoldingItem) == "table" then
                    if Container.HoldingItem[1] == item then
                        Container.HoldingItem[2] += count
                    else
                        return true
                    end
                end
                for v,i in remove do
                    local currnet = self[i][2]
                    if currnet -1 == 0 then
                        self[i] = ""
                    else
                        self[i] = {self[i][1],currnet -1}
                    end 
                end
                self:rawset("Output","")
                if Container.HoldingItem == "" then
                    Container.HoldingItem = count > 0 and {item,count} or ""
                end
            end
            self:__Changed()
            return true 
        end,
        Sterilize = function(self)
            local data = {}
            local ea = self:Copy()
            for i,v in self.Data do
                data[tostring(i)] =v
            end
            ea.Data = data
            return ea
        end
    },
}
function self.Find(name)
    return self.Attributes[name] or false
end
return self