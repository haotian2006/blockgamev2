local entity = {
    ["description"] = {
        is_spawnable = false,
        is_summonable = false,
    }, 
    components ={
        Name = "Player",
        EyeLevel = 1.5,
        HitBox = Vector2.new(0.6,1.8),
        CanJump = true,
        JumpHeight = 1.25,
        Speed = 5.612,
        ['behavior.Random_Stroll'] ={
            priority = 1,
            maxXZ = 20,
            interval = 20,  
        } 
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