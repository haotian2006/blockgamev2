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
    ['C:Sand'] = {
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
    ['C:Wood'] = {
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
    ['C:Leaf'] = {
        components = crt({
  
        }
        ,'BlockComp'),
        events ={
            OnTouched = function(self,entity,side)
                
            end
        }
    },
    ['C:Water'] = {
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
    ['C:Slab'] = {
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
    ['C:Bedrock'] = {
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