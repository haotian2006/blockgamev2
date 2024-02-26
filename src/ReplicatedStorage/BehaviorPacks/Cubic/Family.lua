local Core = require(game.ReplicatedStorage.Core)

return {
    ["c:block"] = {
        OnEquipped = function(self,entity)
            if not Core.Client then return end 
            local InputService = Core.Client.InputService
            local ItemService = Core.Shared.ItemService
            local BlockService = Core.Shared.BlockService
            local Helper = Core.Client.Helper
            local Mouse = Core.Client.Controller.getMouse()
            InputService.bindFunctionTo("PlaceBlock", function(Action: string, IsDown: boolean, gpe: boolean, keys: {  })  
                if not IsDown then return end 
                local Block = ItemService.get(self,"BlockToUse")
                if Block then 
                    Block =BlockService.parse(Block)
                else
                    local Id = BlockService.getBlockId(self[1])
                    if not Id then return end 
                    Block = BlockService.compress(Id,nil,self[2])
                end
                local RayData = Mouse.getRay()
                if not RayData.Block then return end 
                local Blockpos = RayData.BlockPosition + RayData.Normal
                Helper.insertBlock(Blockpos.X, Blockpos.Y, Blockpos.Z, Block)
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
    }
}