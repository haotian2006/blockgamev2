local Container = require(game.ReplicatedStorage.Container)
local Crafting = require(game.ReplicatedStorage.Libs.Crafting)
return {
    Crafting = {
        Frames = {
            [1] = {
                OutputOnly = true,
                RequiresGrabAll = true,
                Whitelist = {},
                BlackList = {},
            }
        },
        OnUpdate = function(self,idx,old,new)
            local size = Container.size(self)
            if size == 0 then return end 

            local layout = {}
            for i =3,#self-1 do
                table.insert(layout,self[i] ~= "" and self[i][1] or "")
            end
            local outPut,count,toRemove = Crafting.GetOutResult(layout)
  
            if idx == 1 then 
                if new ~= "" or not toRemove then return end 
                for i,v in toRemove do
                    local value,count_ = Container.getValueAt(self,v+1)
                    Container.set(self, v+1, value, count_-1)
                end 
                
                return
            end


            Container.set(self, 1, outPut or "", count )
        end,
        OnClose = function(self)
            if #self-2 == 0 then return end 
            local toBeReturned = {}
            for i =2,#self-1 do
                local value = self[i]
                Container.set(self, i-1, "")
                if i == 2 or value == "" then
                    continue
                end
                table.insert(toBeReturned,value)
            end
            return toBeReturned
        end
    },
    Holding = {
        Frames = {},
        OnClose = function(self)
            if #self-2 == 0 then return end 
            local toBeReturned = {}
            for i =2,#self-1 do
                local value = self[i]
                Container.set(self, i-1, "")
                if value == "" then
                    continue
                end
                table.insert(toBeReturned,value)
            end
            return toBeReturned
        end
    },
    Inventory = {
        IsMain = true
    }
}