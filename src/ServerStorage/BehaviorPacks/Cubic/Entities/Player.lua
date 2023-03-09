local entity = {
    ["description"] = {
        is_spawnable = false,
        is_summonable = false,
    }, 
    components ={
        Name = "Player",
        EyeLevel = 1.5,
        HitBox = Vector2.new(0.6,1.8),
        inventory = table.create(36,""),
        JumpHeight = 1.25,
        Speed = 4.317 ,--5.612,
        CanCollideWithEntities = true,
        DoGravity = true,
        Health = 20,
        MaxHealth = 20,
        StateInfo = {
            Sprinting = 1.3,
            Walking = 1,
            Sneaking = 0.3,
            Stopping = 0,
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