local entity = {
    ['C:Item'] = {
        ["description"] = {
            is_spawnable = false,
            is_summonable = false,
        }, 
        components ={
            Name = "C:Item",
            EyeLevel = .1,
            Hitbox = Vector2.new(0.25,0.25),
            DoGravity = true,
            God = true,
            DisableNameTag = true
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