local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local entity = {
    class = "c:Player",
    components ={
        MaxNeckRotation = Vector2.new(60,80),
        Name = "Player",
        EyeLevel = 1.5,
        Hitbox = Vector2.new(0.6,1.79),
        jumpPower = 4.94, 
        Speed = 4.317,--4.317 ,--5.612,
        CollideWithEntities = true,
        Health = 20,
        MaxHealth = 20,
        AutoJump = false,
        DeathDespawn = false,
        CrouchLower = 0.3,
        Containers = {
            Crafting = {"Crafting",5},
            Holding = 1,
            Inventory = 36
        },
        ["getSpeed.method"] = function(self)
             return EntityHandler.getAndCache(self,"Speed")/2*(self.Crouching and 0.3 or 1)
        end,
        ["c:regen.behavior"] = {
            priority = 3
        },
    }, 
    component_groups = {

    },

    behaviors = {

    },
    
    events ={
    },


}
return entity