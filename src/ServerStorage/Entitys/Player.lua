local entity = {
    ["description"] = {
        is_spawnable = false,
        is_summonable = false,
    }, 
    components ={
        Name = "Player",
        EyeLevel = 1.45,
        HitBox = Vector2.new(0.6,1.8),
        CanJump = true,
        JumpHeight = 1.25,
        Speed = 5.612
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