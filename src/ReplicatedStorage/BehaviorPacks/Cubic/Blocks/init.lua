local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local crt = behhandler.CreateComponent
local Blocks = {
    
    ['Cubic:Grass'] = {
        components = crt({

        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['Cubic:Dirt'] = {
        components = crt({
            Hitbox = "Stair"
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['Cubic:Stone'] = {
        components = crt({
            Hitbox = "Slab",
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['Cubic:Bedrock'] = {
        components = crt({

        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    Null = {
        components = crt({

        }
        ,'BlockComp'),
        events ={
        }
    }

}
return Blocks