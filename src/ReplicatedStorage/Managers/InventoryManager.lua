local manager = {}
local player = game.Players.LocalPlayer
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local runservice = game:GetService("RunService")
local dataHandler = require(game.ReplicatedStorage.DataHandler)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local inventorybrige = bridge.CreateBridge('Inventory')
manager.Uis = {}
function manager.AddItem(entity,Item,count)
    
end
if runservice:IsClient() then   
local PEntity = dataHandler.GetLocalPlayer
function manager.GetFrame()
    return resourcehandler.GetUI("InventoryFrame")
end
else

end
return manager