local entity = {
    ['c:Item'] = {
        components ={
            MaxNeckRotation = Vector2.new(60,310),
            Name = "Player",
            EyeLevel = 0,
            Hitbox = Vector2.new(0.3,.3),
            Health = 10000,
            MaxHealth = 10000,
            DespawnTime = 300,
            ["c:Item_Loop.behavior"] = {
                
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
    },
   ["Special:Arm"] = {
        components ={
            EyeLevel = 1.5,
            Hitbox = Vector2.new(0.6,1.79),

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