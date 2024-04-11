local Core = require(game.ReplicatedStorage.Core)

return {
    Alias = "item_block",
    events = {
        --[[
        OnEquipped = function(self,entity)
            if not Core.Client then return end 
            local InputService = Core.Client.InputService
            local ItemService = Core.Shared.ItemService
            local BlockService = Core.Shared.BlockService
            local Helper = Core.Client.Helper
            local Mouse = Core.Client.Controller.getMouse()
            InputService.bindFunctionTo("PlaceBlock", function(Action: string, IsDown: boolean, gpe: boolean, keys: {  })  
                if not IsDown then return end 
                local RayData = Mouse.getRay()
                if not RayData.block then return end 
                local blockPos = RayData.grid + RayData.normal
                Helper.insertHoldingBlock(blockPos.X, blockPos.Y, blockPos.Z)
                return true
            end, "Interact", 1)
        end,
        
        OnDequipped = function(self,entity)
            if not Core.Client then return end 
            local Mouse = Core.Client.Controller.getMouse()
            Mouse.setRayLength(nil)
            local InputService = Core.Client.InputService
            InputService.unbindFunction("PlaceBlock")
        end
        ]]
    },
    methods = {
        getBlock = function(Item)
            local ItemService = Core.Shared.ItemService
            local BlockService = Core.Shared.BlockService

            local Block = ItemService.get(Item,"BlockToUse")
            if Block then 
                Block =BlockService.parse(Block)
            else
                local Id = BlockService.getBlockId(ItemService.getName(Item))
                if not Id then return end 
                Block = BlockService.compress(Id,Item[2])
            end
            return Block
        end
    }
}