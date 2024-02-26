local Utils = require(game.ReplicatedStorage.EntityHandler.Utils)
local Handler = require(game.ReplicatedStorage.EntityHandler)
local Containter = require(game.ReplicatedStorage.Container)
local Item = require(game.ReplicatedStorage.Item)

return {
    ['c:lookAtPlayer'] = {
        Function = function(entity,info)
           for i,v in Utils.getEntitiesNear(entity,info.MaxRange or 20) do
           -- part.Position = Utils.getEyePosition(v)*3
            Utils.lookAt(entity,v)
            break
           end
        end,
        Type = {"Movement","Turning"},
    }, 
    ['c:ManFaceManSwitch'] = {
        Function = function(entity,info)
           for i,v in Utils.getEntitiesNear(entity,2) do
           -- part.Position = Utils.getEyePosition(v)*3
            --Utils.lookAt(entity,v)
            Handler.addComponent(entity, "ManFaceMan")
            break
           end
        end,
        Type = {},
    }, 
   ['c:Item_Loop'] = {
        Function = function(Entity,info)
            local Alive = Handler.getTemp(Entity,"AliveTime") or 0 
            local isAlive = time()-Alive >=0
            if not isAlive then return end 
            local item = Item.new(Entity.Item, Entity.ItemId)
            local maxCount = Item.getMaxCount(item) or 64
            Entity.ItemCount  = Entity.ItemCount  or 1
            for i,v in Utils.getEntitiesNear(Entity,1.25) do
                if Handler.isType(v, 'Player') then

                    local c = Handler.Container.getContainer(v, "Inventory")
                    if not c then return end 
                    local leftOver = Containter.add(c,Item.new(Entity.Item, Entity.ItemId), Entity.ItemCount or 0) or 0
                    if leftOver>0 then
                        Entity.ItemCount = leftOver
                    else
                        Handler.destroy(Entity)
                    end
                    break
                elseif isAlive and maxCount> Entity.ItemCount and  Handler.isType(v, 'c:Item') and Item.equals(item, v.Item,v.ItemId) then
                    local Alive_ = Handler.getTemp(v,"AliveTime") or 0 
                    if time()-Alive_ <=0 then continue end 
                    if maxCount <= v.ItemCount then continue end 
                    local sum = Entity.ItemCount + v.ItemCount
                    local diffrence = 0
                    if sum > maxCount then
                        sum = maxCount
                        diffrence = maxCount-sum
                    end
                    Handler.set(Entity, "ItemCount", sum)
                    Handler.set(v, "ItemCount", diffrence)
                    if diffrence == 0 then
                        Handler.destroy(v)
                    end
                end
            end
        end,
        Type = {}
   }
} 