local Core = require(game.ReplicatedStorage.Core)

 
return {
    ["c:dirt"] = {
        family = "c:item_block",
        default = {
          
        },
        variants = {},
        events = {}
    },
    ["c:grassBlock"] = {
        family = "c:item_block",
        default = {
          
        },
        variants = {
            {
                
            }
        }
    },
    ["c:stone"] = {
        family = "c:item_block",
        default = {
          
        },
        variants = {}
    },
    ["c:leaf"] = {
        family = "c:item_block",
        default = {
          
        },
        variants = {}
    },
    ["c:wood"] = {
        family = "c:item_block",
        default = {
          
        },
        variants = {}
    },
    ["c:GodStick"] = {
        events = {
            OnEquipped = function(self,entity)
                if not Core.Client then return end 
                local Mouse = Core.Client.Controller.getMouse()
                Mouse.setRayLength(3)
            end,
            
            OnDequipped = function(self,entity)
                if not Core.Client then return end 
                local Mouse = Core.Client.Controller.getMouse()
                Mouse.setRayLength(nil)
            end,
        },
        MaxCount = 1,
    },
    ["c:LongStick"] = {
        events = {
            OnEquipped = function(self,entity)
                if not Core.Client then return end 
                local Mouse = Core.Client.Controller.getMouse()
                Mouse.setRayLength(100)
            end,
            
            OnDequipped = function(self,entity)
                if not Core.Client then return end 
                local Mouse = Core.Client.Controller.getMouse()
                Mouse.setRayLength(nil)
            end,
        },
        MaxCount = 1,
    }
}  