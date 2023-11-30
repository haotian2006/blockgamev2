local entity = {
    ['c:Item'] = {
        ["description"] = {
            is_spawnable = false,
            is_summonable = false,
        }, 
        components ={
            MinTpHeight = 9999999,
            JumpHeight = 0,
            Name = "c:Item",
            EyeLevel = .1,
            Hitbox = Vector2.new(0.25,0.25),
            DoGravity = true,
            God = true,
            DisableNameTag = true,
            CanCollideWithEntities = false,

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

}
return entity