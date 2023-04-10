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
    update = function(olddata,newinfo,comp)
        local data = olddata:GetData()
        if #data < newinfo then
            for i = #data+1, newinfo do
                data[i] = ""
            end
        elseif #data > newinfo then
            for i = newinfo+1, #data do
                data[i] = nil
            end
        end
        olddata:SetComponent(comp)
        return olddata
    end,
    Methods = { 
        add = function(self,Item,count)
            local count = count
            local iteminfo = behhandler.GetItem(Item)
            if not iteminfo then return end 
            local max = iteminfo.maxCount
            --local spliited = qf.DecompressItemData(Item,'Type') 
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
                        self[i] = {qf.CompressItemData({Type = Item}),add}
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
            index = index or 1
            local Item = qf.DecompressItemData(Itemdata,'Type') 
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
                self[index] = {qf.CompressItemData({Type = Item}),count}
                count= 0
            end
            return Itemdata,count
        end,
        find = function(self,Item,Id,CannotBeFull)
            for i,v in self do
                if type(v) == "table" then
                    local spliited = qf.DecompressItemData(v[1],'Type') 
                    if spliited == Item then
                        if CannotBeFull and v[2] >= behhandler.GetItem(Item).maxCount then
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
function self.Find(name)
    return self.Attributes[name] or false
end
return self