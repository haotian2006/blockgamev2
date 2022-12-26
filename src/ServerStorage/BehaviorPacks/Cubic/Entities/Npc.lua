local entity = {
    ["description"] = {
        is_spawnable = false,
        is_summonable = false,
    }, 
    components ={
        Name = "Player",
        EyeLevel = 1.5,
        HitBox = Vector2.new(0.6,1.8),
        JumpHeight = 1.25,
        Speed = 2,
        CanCollideWithEntities = true,
        AutoJump = true,
        ['behavior.Random_Stroll'] ={
            priority = 1,
            maxXZ = 5,
            maxy = 0,
            interval = 120,  
        },
        ['behavior.LookAtPlayer'] ={
            priority = 10,
            MaxRange = 10,
        },
        -- ['behavior.GoToPlayer'] = {
        --     MaxRange = 10,
        --     priority = 2,
        --     interval = 120,
        -- },
        --["behavior.Fall"] = {} 
    },
    component_groups = {

    },
    events ={
        OnDeath = {
            
        }
    },
    functions = {

    }

}
return entity