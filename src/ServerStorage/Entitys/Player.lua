local entity = {
    ["description"] = {
        is_spawnable = false,
        is_summonable = false,
    }, 
    components ={
        Name = "Player",
        HitBox = {
            X = 1,
            Y = 2
        },
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