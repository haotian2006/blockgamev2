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
    }

}
return Blocks