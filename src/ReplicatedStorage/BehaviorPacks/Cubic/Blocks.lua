local behhandler = require(game.ReplicatedStorage.BehaviorHandler)

local Core = require(game.ReplicatedStorage.Core)

local Blocks = {
    

    ['c:grassBlock'] = {
        family = "block_base",
        default = {
            BreakTime = .5
        },
        variants = {},
        events = {
            onInteract = function(coords,block,entity)
                if Core.Client then
                    local Client = Core.Client
                    local InputService = Client.InputService

                    if InputService.isDown("Crouch") then
                        return InputService.isDown("Crouch")
                    end
                   ( game.ReplicatedStorage.Events.DoSmt::RemoteEvent):FireServer()

                    task.spawn(function()
                        task.wait(1)
                        require(game:GetService("Players").LocalPlayer.PlayerScripts.core.Ui.ContainerHandler).open("ChestFrame")
                    end)
                end

            end
        }
        
    },
    ['c:foodBlock'] = {

    },
    ['c:purpleOre'] = {

    },
    ['c:dirt'] = {
        BreakTime = 1
    },

    ['c:plank'] = {
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