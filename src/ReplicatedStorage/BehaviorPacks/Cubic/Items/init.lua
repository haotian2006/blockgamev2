local Core = require(game.ReplicatedStorage.Core)

 
return {
    ["c:dirt"] = {
        family = "item_block",
        default = {
          
        },
        variants = {},
        events = {}
    },
    ["c:grassBlock"] = {
        family = "item_block",
        default = {
          
        },
        variants = {
            {
                
            }
        }
    },
    ["c:stone"] = {
        family = "item_block",
        default = {
          
        },
        variants = {}
    },
    ["c:leaf"] = {
        family = "item_block",
        default = {
          
        },
        variants = {}
    },
    ["c:wood"] = {
        family = "item_block",
        default = {
          
        },
        variants = {}
    },
    --[[
     BlockMultiplier = {
          {
            Name = "c:grass",
            Type = "Block" | "Family"
            Multiplier = 2
          }
        },
    ]]
    ["c:GodStick"] = {
        default = {
          BlockMultiplier = {
            {
                Name = "c:dirt",
                Type = "Block",
                Multiplier = 20
              },
              {
                Name = "block_base",
                Type = "Family",
                Multiplier = 20
              }

          },
        },
        methods = {
          
        },
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