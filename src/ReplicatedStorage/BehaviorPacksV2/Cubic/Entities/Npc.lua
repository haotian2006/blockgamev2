local entity = {
    ["description"] = {
        is_spawnable = false,
        is_summonable = false,
    }, 
    components ={
        MaxNeckRotation = Vector2.new(60,310),
        Name = "Npc",
        EyeLevel = 1.5,
        Hitbox = Vector2.new(0.6,1.79),
        jumpPower = 8.94,
        Speed = 4.317,--4.317 ,--5.612,
        CollideWithEntities = true,
        Health = 20,
        MaxHealth = 20,
        AutoJump = false,
        CrouchLower = 0.3,
        ['c:lookAtPlayer.behavior'] ={
            priority = 20,
            MaxRange = 30,
        },
    },
    component_groups = {
       
    },
    events ={
        OnDeath = function(self)
        
        end
    },
    functions = {

    }

}
return entity