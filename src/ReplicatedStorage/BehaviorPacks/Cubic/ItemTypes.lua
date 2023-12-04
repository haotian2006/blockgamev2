--!nocheck
local types = {}
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local crt = behhandler.CreateComponent
local ModingMods = require(game.ReplicatedStorage.ModHandler)
local Types = ModingMods
type InputData = Types.InputData
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
types.Sword = {
    maxCount = 1,
    functions = {
       
    },
    CanCrouch = nil,
    Range = 5.1,
    Damage = 0,
    KnockBackForce = Vector3.one,
    OnInput = {
        Attack = crt({
            Trigger ={
                Client = "SwordAttack",
            }
        },
        'Inputs'
    )
    }
}
return types  