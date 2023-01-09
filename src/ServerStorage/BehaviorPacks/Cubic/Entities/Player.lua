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
        Speed = 5.612,
        CanCollideWithEntities = true,
        DoGravity = true,
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