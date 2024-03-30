local MH = {}
local Worker = {} -- Worker Class
local Workers = {} -- Worker Table
local Index = 0
local deafultAmount = 6 -- deafult amt of workers

Worker.__index = Worker

local threads ={} -- what ids are being used

local mhworkers = Instance.new("Folder") -- folder to hold the works
mhworkers.Name = "WorkerHolder"
mhworkers.Parent = script 

function Worker.new(index)
   local clone = script.Actor:Clone()
   clone.Name = index
   clone.Parent = mhworkers
   clone.Main.Enabled = true -- enable the script
   clone.DataHandler.Event:connect(function(id,...)
        -- when data is returned find the thread associeted with that id and resume it and send data 
        coroutine.resume(threads[id],...)
   end)
   return clone
end

--//gets a worker from the Workers table
function MH:GetWorker()
    if #Workers == 0 then error("TABLE IS EMPTY") end 
    Index +=1
    if Workers[Index] then
        return Workers[Index],Index
    else
        Index = 0
        return self:GetWorker()
    end
end
local id = 0
--//a recursive function that gets an id between 1-32768 that is not being used
--//can be increased if you want
function MH:GetId()
    id += 1
    if threads[id] ~= nil then -- if a id is being used then go next
        return self:GetId()
    elseif id >= 32768 then
        id = 0
        return self:GetId()
    end
    return id 
end
--//runs a task in parallel with data
function MH:DoWork(taskToDo,...)
    local c = self:GetId()
    local worker:Actor,idx = MH:GetWorker()
    worker:SendMessage("M",c,taskToDo,...)
    threads[c] = coroutine.running() -- stores  current thread
    local data =  coroutine.yield() -- yield it and recive the returned data
    threads[c] = nil -- remove thread
    return data
end
--//creates the workers
local init = false
function MH:Init(amt)
    if init then warn("MultiHandler is already initiated") end 
    init = true
    amt = amt or deafultAmount
    for i = 1,amt do
        local worker = Worker.new(i)
        table.insert(Workers,worker)
    end

    return MH
end
return MH
