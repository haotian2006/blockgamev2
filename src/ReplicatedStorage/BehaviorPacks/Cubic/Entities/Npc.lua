local entity = {

    components ={
        MaxNeckRotation = Vector2.new(60,80),
        Name = "Npc",
        EyeLevel = 1.5,
        Hitbox = Vector2.new(0.6,1.79),
        JumpPower = 8.94,
        Speed = 4.317,--4.317 ,--5.612,
        CollideWithEntities = true,
        Health = 20,
        MaxHealth = 20,
        AutoJump = false,
        CrouchLower = 0.3,
        ["c:ManFaceManSwitch.behavior"] = {
            priority = 3
        },
        ['c:lookAtPlayer.behavior'] ={
            priority = 20,
            MaxRange = 30,
        },
    },
    component_groups = {
        ManFaceMan = {
            Speed = 100,
            ['c:ManFaceManSwitch.behavior'] = "NIL",
            ['c:goToPlayer.behavior'] ={
                priority = 1,
                MaxRange = 30,
            },
        }
    },
   
    functions = {

    }

}
return entity