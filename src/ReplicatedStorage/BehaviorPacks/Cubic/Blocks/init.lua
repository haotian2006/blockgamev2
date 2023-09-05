local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local crt = behhandler.CreateComponent
local Blocks = {
    
    ['c:Grass'] = {
        components = crt({

        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['c:Dirt'] = {
        components = crt({
        } 
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['c:Sand'] = {
        components = crt({
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['c:Stone'] = {
        components = crt({
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['c:Wood'] = {
        components = crt({
            RotateX = true,
            RotateY = true,
          --  RotateZ = true
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['c:Leaf'] = {
        components = crt({
  
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['c:Water'] = {
        components = crt({
  
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['c:Stair'] = {
        components = crt({
            Hitbox = "Stair",
            Transparency = true,
            RotateY = true,
            RotateZ = true
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['c:Slab'] = {
        components = crt({
            Hitbox = "Slab",
            Transparency = true,
            RotateZ = true
            
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['c:Bedrock'] = {
        components = crt({

        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    DebugPart = {
        components = crt({
            RotateY = true,
            RotateZ = true,
            RotateX = true
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