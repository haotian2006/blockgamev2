local manager = {}
local player = game.Players.LocalPlayer
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local runservice = game:GetService("RunService")
local dataHandler = require(game.ReplicatedStorage.DataHandler)
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local inventorybrige = bridge.CreateBridge('Inventory')
manager.Uis = {}
if runservice:IsClient() then   
local PEntity = dataHandler.GetLocalPlayer
function manager.getFrame()
    return resourcehandler.GetUI("InventoryFrame")
end
function manager.createFrame()
    if PEntity() and PEntity().inventory then
        
    end
end
else

end
return manager