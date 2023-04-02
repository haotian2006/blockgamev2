local entity = {
    ["description"] = {
        is_spawnable = false,
        is_summonable = false,
    }, 
    components ={
        Name = "Player",
        EyeLevel = 1.5,
        HitBox = Vector2.new(0.6,1.8),
        inventory = 36,
        JumpHeight = 1.25,
        Speed = 4.317 ,--5.612,
        CanCollideWithEntities = true,
        DoGravity = true,
        Health = 20,
        MaxHealth = 20,
        StateInfo = {
            Sprinting = {Speed = 1.3},
            Walking = {Speed = 1},
            Sneaking = {Speed = 0.3},
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