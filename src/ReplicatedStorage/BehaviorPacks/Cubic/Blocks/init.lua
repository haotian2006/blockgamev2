local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local crt = behhandler.CreateComponent
local Blocks = {
    
    ['C:Grass'] = {
        components = crt({

        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['C:Dirt'] = {
        components = crt({
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['C:Stone'] = {
        components = crt({
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['C:Stair'] = {
        components = crt({
            Hitbox = "Stair"
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['C:Slab'] = {
        components = crt({
            Hitbox = "Slab",
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['C:Bedrock'] = {
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