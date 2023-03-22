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
    Methods = { 
        add = function(self,Item,count)
            local count = count
            local iteminfo = behhandler.GetItem(Item)
            if not iteminfo then return end 
            local max = iteminfo.maxCount
            local spliited = qf.DecompressItemData(Item,'Type') 
            for i,v in ipairs(self.Data) do
                if count <= 0 then break end 
                if type(v) == "table" then
                    local spliited = qf.DecompressItemData(v[1],'Type') 
                    if spliited == Item then
                        if  v[2] < max then
                            local add = (max-v[2])
                            if count < add then
                                add = count
                            end
                            self[i][2] += add
                            count -= add
                        end
                    end
                else
                    local add = 0
                    if count <= max then
                        add = count
                    else
                        add = max 
                    end
                    self[i] = {qf.CompressItemData({Type = Item}),add}
                    count -= add
                end
            end
            return count
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
            return _ipairs,self:GetData(),0
        end,
        getEmpty = function(self)
            return table.find(self.Data,'')
        end
    },
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
    end
}
function self.Find(name)
    return self.Attributes[name] or false
end
return self