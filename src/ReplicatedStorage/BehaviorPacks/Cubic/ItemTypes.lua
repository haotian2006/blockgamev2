local types = {}
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local crt = behhandler.CreateComponent
local ModingMods = require(game.ReplicatedStorage.ModdingModules)
export type InputData = {ItemData : {},Index:number,Item:string,InputData:{},Input:string,IsDown:boolean,Controls:{},ItemHandler:{},Player:Player}
--{BlockData = bdata,Index = i,Item = v[1],InputData = data,Input = input,IsDown = isdown,Controls = controls,ItemHandler = itemhand,Player = Player or game.Players.LocalPlayer}
--[[
    {
        maxCount = integer
        type = string
        OnInput = {
            InputName = Inputs       
            
        }
    }
]]
types.Block = {
    maxCount = 64,
    functions = {
       
    },
    Animations = {
        Idle = nil,
        Walk = nil,
        Crouch = nil,
    },
    CanCrouch = nil,
    OnInput = {
        Interact = crt({
            Trigger ={
                Client = "PlaceBlockClient",
                Server = function(entity,data:InputData)
                    local func = behhandler.Getfunction("PlaceBlockServer")
                    if func then func(entity,ModingMods.ItemHandler.GetItemName(data.Item)) end
                end
            }
        },
        'Inputs'
    )
    }
}
return types  