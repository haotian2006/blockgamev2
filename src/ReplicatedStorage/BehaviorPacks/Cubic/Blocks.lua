local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local Blocks = {
    

    ['c:grassBlock'] = {
        family = "block_base",
        default = {
            BreakTime = .5
        },
        variants = {},
        
    },
    ['c:foodBlock'] = {

    },
    ['c:purpleOre'] = {

    },
    ['c:dirt'] = {
        BreakTime = 1
    },

    ['c:stone'] = {
        BreakTime = 0
    },

    ['c:wood'] = {

    },
    ['c:leaf'] = {
      
    },

    ['c:sand'] = {
       
    },
  
}
return Blocks 