local Core = require(game.ReplicatedStorage.Core)

 
return {
    ["c:dirt"] = {
        Family = "c:block",
        Default = {
          
        },
        Variants = {}
    },
    ["c:grassBlock"] = {
        Family = "c:block",
        Default = {
          
        },
        Variants = {
            {
                
            }
        }
    },
    ["c:stone"] = {
        Family = "c:block",
        Default = {
          
        },
        Variants = {}
    },
    ["c:leaf"] = {
        Family = "c:block",
        Default = {
          
        },
        Variants = {}
    },
    ["c:wood"] = {
        Family = "c:block",
        Default = {
          
        },
        Variants = {}
    },
    ["c:GodStick"] = {
        OnEquipped = function(self,entity)
            if not Core.Client then return end 
            local Mouse = Core.Client.Controller.getMouse()
            Mouse.setRayLength(3)
        end,
        
        OnDequipped = function(self,entity)
            if not Core.Client then return end 
            local Mouse = Core.Client.Controller.getMouse()
            Mouse.setRayLength(nil)
        end
    }
}  