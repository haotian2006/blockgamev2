local entity = {
    ["description"] = {
        is_spawnable = false,
        is_summonable = false,
    }, 
    components ={
        Name = "Player",
        EyeLevel = 1.5,
        Hitbox = Vector2.new(0.6,1.8),
        JumpHeight = 1.25,
        JumpV = 5;
        Speed = 2,
        CanCollideWithEntities = true,
        AutoJump = true,
        DoGravity = true,
        Health = 20,
        MaxHealth = 20,
        inventory = 36,
        ok = "deafult",
        ['behavior.Random_Stroll'] ={
            priority = 1, 
            maxXZ = 6,
            maxy = 0,
            interval = 120,  
        },
        ['behavior.LookAtPlayer'] ={
            priority = 20,
            MaxRange = 30,
        },
         ['behavior.GoToPlayer'] = {MaxRange = 6,priority = 2,interval = 1,},
         ['behavior.AttackPlayer'] = {MaxRange = 3,priority = 2,},
    },
    component_groups = {
        A = {
            ok = 'A',
            Speed = 3,
            inventory = 10,
        },
        B = {
            ok = 'B',
            Speed = 1,
            inventory = 12,
        }
    },
    events ={
        OnDeath = function(self)
        
        end
    },
    functions = {

    }

}
return entity