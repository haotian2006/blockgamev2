local ServerContainer = {}

local RunService = game:GetService("RunService")

local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ItemClass = require(game.ReplicatedStorage.Item)
local Container = require(game.ReplicatedStorage.Container)
local Data = require(game.ReplicatedStorage.Data)
local EntityUtils = require(game.ReplicatedStorage.EntityHandler.Utils)

local Events = game:GetService("ReplicatedStorage").Events.Container
local Send:RemoteEvent = Events.Send
local Update:RemoteEvent = Events.Update
local Request:RemoteFunction = Events.Request
local Changed = {}

Container.setChangedTable(Changed)

local LoadedContainers = {
--    ["102743637"] = {
--         Crafting = {
--             "Crafting",
--             {ItemClass.new("c:GrassBlock"),63},
--             "",
--             "",
--             "",
--             {ItemClass.new("c:Dirt"),2},
--             {__Parent = "102743637",__Opened = {}}
--         },
--         Holding = {
--             "Holding",
--             {ItemClass.new("c:GrassBlock"),2},
--             {__Parent = "102743637",__Opened = {}}
--         }
--    } 
}

function ServerContainer.registerNewContainer(uuid,Container)
    LoadedContainers[uuid] =  LoadedContainers[uuid] or {}

    LoadedContainers[uuid][Container[1]] =  Container
end

function ServerContainer.removeContainer(uuid,Container)
   if not LoadedContainers[uuid] then return end 
   LoadedContainers[uuid][Container] = nil 
end

function ServerContainer.removeAll(uuid)
     LoadedContainers[uuid] = nil
 end

function ServerContainer.getAllContainersFor(uuid)
    uuid = tostring(uuid)
    return LoadedContainers[uuid]
end

function ServerContainer.getContainer(uuid,name)
    uuid = tostring(uuid)
    local allContainersForName = LoadedContainers[uuid]
    if not allContainersForName then return end 
    return allContainersForName[name]
end

function ServerContainer.getContainerFrom(player:Player,path)
    if type(path) == "string" then
        return ServerContainer.getContainer(player.UserId, path)
    end
    return ServerContainer.getContainer(path[1], path[2])
end

function ServerContainer.getFrame(uuid,name,id)
    uuid = tostring(uuid)
    local allContainersForName = LoadedContainers[uuid]
    if not allContainersForName or not allContainersForName[name] then return end 
    return allContainersForName[name][id]
end

function ServerContainer.split(player,from,idx)
    local click = ServerContainer.getContainerFrom(player,from)
    local Holding = ServerContainer.getContainerFrom(player,"Holding")
    if not Holding or not click then return end 

    if Container.checkOutOfBounds(click, idx) then
        error(`Index {idx} is out of bounds for size {#click-2}`) 
    end

    local HoldingItem,Hvalue = Container.getValueAt(Holding,1)
    local FrameItem,Fvalue = Container.getValueAt(click,idx)

    local FrameData = Container.getFrameData(click, idx) or {}
    if HoldingItem == "" and FrameItem == "" then return end 
    local IsOutput = Container.isOutput(click, idx)
    local RequiresAll = FrameData["RequiresGrabAll"]
    if HoldingItem == "" then

        local half = if not RequiresAll then (Fvalue+1)//2 else Fvalue
        Fvalue -= half
        Container.set(click, idx, Fvalue == 0 and "" or FrameItem, Fvalue)
        Container.set(Holding, 1, FrameItem, half)
    elseif (ItemClass.equals(FrameItem, HoldingItem) or FrameItem == "") then
        if RequiresAll then
            local max = ItemClass.getMaxCount(HoldingItem)
            local total = Hvalue + Fvalue
            if total > max or FrameItem == "" then return end 
            Container.set(click, idx, "")
            Container.set(Holding, 1, FrameItem, total)
            return
        elseif IsOutput then
            if ItemClass.getMaxCount(HoldingItem) <= Hvalue or FrameItem == ""  then
                return
            end
            local half = (Fvalue+1)//2
            Fvalue -= half
            local item,extra = Container.setAt(Holding, 1, FrameItem, half)
            if item then
                Fvalue += extra
            end
            Container.set(click, idx, Fvalue == 0 and "" or FrameItem, Fvalue)
            
            return
        end
        local newCount = Hvalue -1
        local item = Container.setAt(click, idx, HoldingItem, 1)
        if item then
            Container.set(click, idx, FrameItem, Hvalue)
            Container.set(Holding, 1, FrameItem, Fvalue)
        elseif newCount == 0 then
            Container.set(Holding,1,"")
        else
            Container.set(Holding, 1, HoldingItem, newCount)
        end
    elseif not RequiresAll then
        Container.swap(Holding, click, 1, idx, true)
    end
end

function ServerContainer.place(player,c1,c2,from,to)
    c1 = ServerContainer.getContainerFrom(player,c1)
    c2 = ServerContainer.getContainerFrom(player,c2)
    Container.swap(c1, c2, from, to, true)
end

function ServerContainer.getContainerAt()
    
end

function ServerContainer.close(player,path)
    local container = ServerContainer.getContainerFrom(player,path)
    local parent = Container.getParent(container)
    if parent == tostring(player.UserId) then return end 
    Container.removeOpen(container, player)

end

function ServerContainer.EntityClose(entity)
    local container = entity.__containers
    if not container then return end 
    local tobePushedBack = {}
    local main 
    for i,v in container do
        local data = Container.getContainerData(v)
        if data.IsMain then main = v end 
        if not data.OnClose then
            continue
        end
        for i,v in data.OnClose(v,entity) or {} do
            table.insert(tobePushedBack,v)
        end
    end
    if not main then
        --//DropAll
        --// I do not remember what to do here
        return
    end
    for i,v in tobePushedBack do
        if v == "" then continue end 
        local extra = Container.add(main, v[1], v[2])
        if extra and extra >0 then
            EntityUtils.dropItem(entity, v[1], extra,10)
        end
        --//Drop Extra
    end
end

function ServerContainer.playerCloseUi(player)
    local entity = Data.getEntity(tostring(player.UserId))
    if not entity then return end 
    ServerContainer.EntityClose(entity)
end

local currentIdk = {}
function ServerContainer.setUpdateData(c,data)
    currentIdk[c] = data
end

local rate = 1/20
local time = 0
game:GetService("RunService").Heartbeat:Connect(function(dt)
    time += dt
    if time<rate then return end 
    time = 0
    local toUpdate = {}
    for c,changedStuff in Changed do
        local parent = Container.getParent(c)
        local players = Container.getOpened(c)
        local changed = {parent,c[1]}
        for i,v in changedStuff do
            table.insert(changed,{i,Container.get(c, i)})
        end
        if currentIdk[c] then
            table.insert(changed,{s = currentIdk[c]})
        end
        for i,plr in players do
            toUpdate[plr] = toUpdate[plr] or {}
            local plrStuff = toUpdate[plr]
            table.insert(plrStuff,changed)
        end
    end
    table.clear(Changed)
    table.clear(currentIdk)
    for plr,update in toUpdate do
        task.spawn(Update.FireClient,Update,plr,update)
    end
end)

local function Throw(player,which)
    local Entity = Data.getEntity(tostring(player.UserId))
    if not Entity then return end 
    local Container_ = Entity.__containers["Holding"]
    local Item = Container_[2]
    if Item == "" then return end 
    local count = Item[2]
    if which == 2 then
        count = Item[2]>0 and 1 or 0
    end
    Container.set(Container_, 1, Item[1], Item[2]-count)
    if count == 0 then return end 
    EntityUtils.dropItem(Entity,Item[1],count)
end

local tasks ={
    ServerContainer.place,
    ServerContainer.split, 
    ServerContainer.playerCloseUi,
    Throw
}

Send.OnServerEvent:Connect(function(player,task,...)
    local Entity = Data.getEntity(tostring(player.UserId))
    if not Entity then return end 
    if not EntityUtils.isOwner(Entity, player) then return end 
    if not tasks[task] then return end
    tasks[task](player,...)
end)

Request.OnServerInvoke = function(player,uuid,container)
    uuid = tostring(uuid)
    local c = LoadedContainers[uuid] and LoadedContainers[uuid][container]
    if not c then return nil end 
    Container.setOpened(c, player)
    if not c then return end 
    local cloned = table.clone(c)
    cloned[#cloned] = nil
    return cloned
end

return ServerContainer