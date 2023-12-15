local Tasks = {}
local TaskOrder = {

}
local OrderTask = {

}
local callBacks = {}
local TaskData = {

}
local TaskOrderRemote:RemoteEvent = game.ReplicatedStorage.Events.TaskUpdater
local RunService = game:GetService("RunService")
local IS_CLIENT = RunService:IsClient()
local function fixOrderTask()
    table.clear(OrderTask)
    for i,v in TaskOrder do
        OrderTask[v] = i
    end
end

function Tasks.bind(task,callback)
    callBacks[task] = callback
    if not IS_CLIENT then
        table.insert(TaskOrder,task)
        TaskOrderRemote:FireAllClients(TaskOrder)
        fixOrderTask()
    end
end
local cache = {}
function Tasks.clearDataFor(uuid)
    TaskData[uuid] = nil
    cache[uuid] = nil
end
function Tasks.attachDataTo(uuid,task,data,SendToOwner)
    TaskData[uuid] = TaskData[uuid] or {}
    local taskFolder = TaskData[uuid][task] or {}
    TaskData[uuid][task] = taskFolder
    table.insert(TaskData[uuid][task],{data,SendToOwner})
end
function Tasks.encode(uuid,isOwner)
    local data = TaskData[uuid]
    if not data then return end 
    if cache[uuid] and not isOwner then return cache or nil end 
    local newData = {}
    local hasData = false
    for subTask,subData in data do
        local subFolderIndex = OrderTask[subTask]
        local subFolder
        for order,tData in subData do
            if not tData[2] and isOwner then continue end 
            if not subFolder then
                subFolder  = {tostring(subFolderIndex)}
                table.insert(newData,subFolder)
            end
            newData[subTask] = subFolder
            table.insert(subFolder,tData[1])
            hasData = true
        end
    end
    newData = hasData and newData or hasData
    if not isOwner then
        cache[uuid] = newData
    end
    return newData or nil
end
function Tasks.decode(uuid,data)
   for i,tData in data do
        local task = TaskOrder[tonumber(tData[1]) or 1]
        local callback = callBacks[task or 1]
        if not callback then warn(`No CallBack Found For {task}`); continue  end 
        for i,v in tData do
            if i == 1 then continue end 
            callback(uuid,v)
        end
   end
end
if IS_CLIENT then
    TaskOrderRemote.OnClientEvent:Connect(function(Order)
    TaskOrder = Order
    fixOrderTask()
end)
TaskOrderRemote:FireServer()
else
    TaskOrderRemote.OnServerEvent:Connect(function(player)
        TaskOrderRemote:FireClient(player,TaskOrder)
end)
end

return table.freeze(Tasks)