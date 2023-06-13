local RunService = game:GetService("RunService")
local BridgeNet = require(game.ReplicatedStorage.BridgeNet)
local modR = BridgeNet.CreateBridge("Modding")
local remote = {remotes = {}}
remote.__index = function(self,key)
    if key == "OnClientEvent" or key == "OnServerEvent" or key == "Event" then
        return self.RecieveEvent.Event
    end
    return remote[key]
end
function remote.GetRemote(Name:string)
   if not remote.remotes[Name] then
        remote.remotes[Name] = setmetatable({
            Name = Name,
            RecieveEvent = Instance.new("BindableEvent"),
    },remote)
   end
   return remote.remotes[Name]
end
function remote:FireClient(player:Player,...)
    if RunService:IsClient() then warn("Cannot Call FireClient On Client") return end
    if  typeof(player) ~="Instance" or (typeof(player) =="Instance" and not player:IsA("Player")) then 
        warn("Player Argument Must Be a Player | Remote "..self.Name)
    end
    modR:FireTo(player,self.Name,...)
end
function remote:FireAllClients(...)
    if RunService:IsClient() then warn("Cannot Call FireAllClients On Client") return end
    modR:FireAll(self.Name,...)
end
function remote:FireServer(...)
    if RunService:IsServer() then warn("Cannot Call FireServer On Server") return end
    modR:Fire(self.Name,...)
end
function remote:Disconnect()
    remote.remotes[self.Name] = nil
    self.RecieveEvent:Destroy()
    setmetatable(self,nil)
 end

modR:Connect(function(...)
    local data = {...}
    local name = ""
    if RunService:IsServer() then
        name = data[2]
        table.remove(data,2)
    else
        name = data[1]
        table.remove(data,1)
    end
    if remote.remotes[name] then
        remote.remotes[name].RecieveEvent:Fire(unpack(data))
    else
        warn(name.." Remote Not Found")
    end
end)
return remote