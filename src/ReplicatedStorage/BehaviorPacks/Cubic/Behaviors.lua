local Utils = require(game.ReplicatedStorage.EntityHandler.Utils)
local Handler = require(game.ReplicatedStorage.EntityHandler)
local Container = require(game.ReplicatedStorage.Handler.Container)
local Item = require(game.ReplicatedStorage.Handler.Item)
local CollisionHandler = require(game.ReplicatedStorage.CollisionHandler)

return {
    ['c:lookAtPlayer'] = {
        Function = function(entity,info)
           for i,v in Utils.getEntitiesNear(entity,info.MaxRange or 20) do
            if not Handler.isType(v, 'Player') then
                continue
            end
           -- part.Position = Utils.getEyePosition(v)*3
            Utils.lookAt(entity,v)
            break
           end
        end,
        Type = {"Movement","Turning"},
        CanBeDead = false,
    }, 
    ['c:regen'] = {
        Function = function(entity,info)
        
        end,
        Type = {"Movement","Turning"},
    }, 
    ['c:ManFaceManSwitch'] = {
        Function = function(entity,info)
           for i,v in Utils.getEntitiesNear(entity,2) do
            if not Handler.isType(v, 'Player') then
                continue
            end
           -- part.Position = Utils.getEyePosition(v)*3
            --Utils.lookAt(entity,v)
            Handler.addComponent(entity, "ManFaceMan")
            break
           end
        end,
        Type = {},
    }, 
    ['c:MoveUpIfInBlock'] = {
        Function = function(Entity,info)
            local pos = Entity.Position
            local Block = CollisionHandler.getBlock(pos.X, pos.Y, pos.Z)
            if Block and Block>0 then
    
                Handler.setVelocity(Entity,"MoveOutOfBlock",Vector3.new(0,5,0))
            else
                Handler.setVelocity(Entity,"MoveOutOfBlock",Vector3.new(0,0,0))
            end
        end,
        Type = {},
    },

    ['c:Item_Loop'] = {
            Function = function(Entity,info)
                local Alive = Handler.getTemp(Entity,"AliveTime") or 0 
                local isAlive = time()-Alive >=0
                if not isAlive then return end 
                local item = Item.new(Entity.ItemId, Entity.ItemVariant)
                local maxCount = Item.getMaxCount(item) or 64
                Entity.ItemCount  = Entity.ItemCount  or 1
                for i,v in Utils.getEntitiesNear(Entity,1.25) do
                    if Handler.isType(v, 'Player') and not Handler.isDead(v) then

                        local c = Handler.Container.getContainer(v, "Inventory")
                        if not c then return end 
                        local leftOver = Container.add(c,Item.new(Entity.ItemId, Entity.ItemVariant), Entity.ItemCount or 0) or 0
                        if leftOver>0 then
                            Entity.ItemCount = leftOver
                        else
                            Handler.destroy(Entity)
                        end
                        break
                    elseif isAlive and maxCount> Entity.ItemCount and  Handler.isType(v, 'c:Item') and Item.equals(item, v.ItemId,v.ItemVariant) then
                        local Alive_ = Handler.getTemp(v,"AliveTime") or 0 
                        if time()-Alive_ <=0 then continue end 
                        if maxCount <= v.ItemCount then continue end 
                        local sum = Entity.ItemCount + v.ItemCount
                        local difference = 0
                        if sum > maxCount then
                            sum = maxCount
                            difference = maxCount-sum
                        end
                        Handler.set(Entity, "ItemCount", sum)
                        Handler.set(v, "ItemCount", difference)
                        Handler.setDespawnTime(Entity, nil)
                        if difference == 0 then
                            Handler.destroy(v)
                        end
                    end
                end
            end,
            Type = {}
    }
} 