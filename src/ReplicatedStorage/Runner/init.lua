local RunService = game:GetService("RunService")
local Runner = {}
local steppedCallbacks =  table.create(100,false)
local heartbeatCallbacks = table.create(100,false)
local ParallelRunner = require(script.Actor.ParallelRunner::ModuleScript)
local DEAFULT_PRIORITY = 10



function Runner.bindToStepped(Name,callback,priority)
    if table.find(steppedCallbacks,Name) then 
        warn(`Name {Name} already Binded`)
        return  
    end 
    priority = priority or DEAFULT_PRIORITY
    if priority> 100 then priority = 100 end 
    if not steppedCallbacks[priority] then
        steppedCallbacks[priority] = callback
    else
        table.insert(steppedCallbacks,priority,Name)
    end
end
 
function Runner.bindToHeartbeat(Name,callback,priority)
    if table.find(heartbeatCallbacks,Name) then 
        warn(`Name {Name} already Binded`)
        return
     end 
    priority = priority or DEAFULT_PRIORITY
    if priority> 100 then priority = 100 end 
    if not heartbeatCallbacks[priority] then
        heartbeatCallbacks[priority] = callback
    else
        table.insert(heartbeatCallbacks,priority,Name)
    end
end

function Runner.runParallel(fx,...)
    return ParallelRunner.RunParallel(fx,...)
end

function Runner.run(fx,...)
    return ParallelRunner.Run(fx,...)
end
RunService.Stepped:Connect(function(time,deltaTime)
    -- debug.profilebegin("RUNNNER STEPPED")
    -- for i=0,1000 do
    --     i+=1
    -- end
    -- debug.profileend()
    for i,v in steppedCallbacks do
        if not v then continue end 
        task.spawn(v,time,deltaTime)
    end
end)
RunService.Heartbeat:Connect(function(deltaTime)
    for i,v in heartbeatCallbacks do
        if not v then continue end 
        task.spawn(v,deltaTime)
    end
end)
return table.freeze(Runner) 