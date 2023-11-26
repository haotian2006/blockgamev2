local Tasks = {}
local TaskOrder = {

}
local OrderTask = {

}
local callBacks = {}
local TaskData = {

}
local BridgeNet = require(game.ReplicatedStorage.BridgeNet)
local TaskOrderRemote = BridgeNet.CreateBridge("EntityTaskOrder")
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
        TaskOrderRemote:FireAll(TaskOrder)
        fixOrderTask()
    end
end
function Tasks.clearDataFor(uuid)
    TaskData[uuid] = nil
end
function Tasks.attachDataTo(uuid,task,data,SendToOwner)
    TaskData[uuid] = TaskData[uuid] or {}
    local taskFolder = TaskData[uuid][task] or {}
    TaskData[uuid][task] = taskFolder
    table.insert(TaskData[uuid][task],{data,SendToOwner})
end
local cache = {}
function Tasks.encode(uuid,isOwner)
    local data = TaskData[uuid]
    if not data then return end 
    if cache[uuid] and not isOwner then return cache end 
    local newData = {}
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
        end
    end
    if not isOwner then
        cache[uuid] = newData
    end
    return newData
end
function Tasks.decode(uuid,data)
   for i,tData in data do
        local task = TaskOrder[tonumber(tData[1])]
        local callback = callBacks[task or 1]
        if not callback then warn(`No CallBack Found For {task}`) continue  end 
        for i,v in tData do
            if i == 1 then continue end 
            callback(v)
        end
   end
end
if IS_CLIENT then
    TaskOrderRemote:Connect(function(Order)
    TaskOrder = Order
    fixOrderTask()
end)
TaskOrderRemote:Fire()
else
    TaskOrderRemote:Connect(function(player)
        TaskOrderRemote:FireTo(player,TaskOrder)
end)
end

return Tasks