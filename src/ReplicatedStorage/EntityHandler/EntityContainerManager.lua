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
    if next(Containers) == nil then return end 
    self.__containers = {} 
    for i,v in Containers do 
        local count,name =v,i
        if type(v) == "table" then
            name,count = v[1],v[2]
        end
        self.__containers[i] = ContainerManager.new(name, count,self.Guid,i,self.__containerUpdate)
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
    local my = self.__containers 
    if not my then
        manager.init(self)
        return
    end

    for i,v in Containers do
        local myC = my[i]
        local count,name =v,i
        if type(v) == "table" then
            name,count = v[1],v[2]
        end
        if not myC and count ~= "NIL" then
            my[i] = ContainerManager.new(name, count,self.Guid,i,self.__containerUpdate)
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
        if size ~= count then
            ServerContainer.setUpdateData(myC,count)
            ContainerManager.resize(self, count)
        end
    end
end

function manager.OnDeath(self)
    if not  self.__containers  then return end 
    if IS_SERVER then
        for i,v in  self.__containers  do
            ServerContainer.removeAll(self.Guid)
        end
    end
end

return manager