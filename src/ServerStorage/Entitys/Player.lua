local entity = {
    ["description"] = {
        is_spawnable = false,
        is_summonable = false,
    }, 
    components ={
        Name = "Player",
        HitBox = Vector2.new(0.6,1.8),
        CanJump = true,
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