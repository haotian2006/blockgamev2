local WorkerManager = {}
local Worker = {}
WorkerManager.__index = WorkerManager

local mhworkers = Instance.new("Folder") 
mhworkers.Name = "GeneratorWorkers"
mhworkers.Parent = game.ServerScriptService 

function Worker.new(index)
    local clone = script.Parent.Actor:Clone()
    clone.Name = index
    clone.Parent = mhworkers
    clone.Main.Enabled = true -- enable the script
    return clone
end

function WorkerManager:GetWorker()
    local Workers = self.Workers
    if #Workers == 0 then error("TABLE IS EMPTY") end 
    self.WorkerIndex +=1
    local Index = self.WorkerIndex
    if Workers[Index] then
        return Workers[Index],Index
    else
        self.WorkerIndex = 0
        return self:GetWorker()
    end
end

function WorkerManager:GetId()
    self.id += 1
    local id = self.id
    if self.threads[id] ~= nil then -- if a id is being used then go next
        return self:GetId()
    elseif id >= 9999999 then
        self.id = 0
        return self:GetId()
    end
    return id 
end

function WorkerManager:DoWork(taskToDo,...)
    local c = self:GetId()
    local worker:Actor,idx = self:GetWorker()
    worker:SendMessage("M",c,taskToDo,...)
    self.threads[c] = coroutine.running() 
    local data =  {coroutine.yield()} 
    self.threads[c] = nil 
    return unpack(data)
end

function WorkerManager.create(name,amt,...)
    local Bindable = Instance.new("BindableEvent")
    Bindable.Name = name
    Bindable.Parent = script
    local self = setmetatable({id =0,WorkerIndex=0,threads = {},Workers = {}},WorkerManager)
    Bindable.Event:connect(function(id,...)
        coroutine.resume(self.threads[id],...)
   end)
   for i =1,amt do
        local worker = Worker.new(i)
        table.insert(self.Workers,worker)
        worker:SendMessage("Init",Bindable,...)
   end
   return self
end
return WorkerManager