local manager = {}
local ContainerManager = require(game.ReplicatedStorage.Container)
local IS_SERVER = game:GetService("RunService"):IsServer()
local ServerContainer 
if IS_SERVER then
    ServerContainer = require(game.ServerStorage.core.ServerContainer)
end
function manager.init(self)
    local Containers = {}
    for i,v in self.__components do
        for Container,data in v.Containers or {} do
            if Containers[Container] then continue end 
            Containers[Container] = data
        end
    end
    for Container,data in self.__main.Containers or {} do
        if Containers[Container] then continue end 
        Containers[Container] = data
    end
    self.__containers = {}
    for i,v in Containers do 
        self.__containers[i] = ContainerManager.new(i, v,self.Guid,self.__containerUpdate)
        if IS_SERVER then
            ServerContainer.registerNewContainer(self.Guid,  self.__containers[i])
        end
    end
end

function manager.getContainer(self,name)
    if not  self.__containers then return end 
    return   self.__containers[name]
end

function manager.changedComponets(self)
    local Containers = {}
    for i,v in self.__components do
        for Container,data in v.Containers or {} do
            if Containers[Container] then continue end 
            Containers[Container] = data
        end
    end 
    for Container,data in self.__main.Containers or {} do
        if Containers[Container] then continue end 
        Containers[Container] = data
    end
    local my = self.__containers or {}

    for i,v in Containers do
        local myC = my[i]
        if not myC and v ~= "NIL" then
            my[i] = ContainerManager.new(i, v,self.Guid)
            if IS_SERVER then
                ServerContainer.registerNewContainer(self.Guid,  my[i])
            end
            continue
        elseif  v == "NIL" then
            if IS_SERVER then
                ServerContainer.setUpdateData(myC,false)
            end
            continue
        end
        local size = ContainerManager.size(myC)
        if size ~= v then
            ServerContainer.setUpdateData(myC,v)
            ContainerManager.resize(self, v)
        end
    end
end

return manager