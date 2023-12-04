local signal = require(game.ReplicatedStorage.Libarys.Signal)
local TS = {}
TS.__index = TS
local TempEvents 
function TS.new(action,t)
    TempEvents = TempEvents or t
    TempEvents[action] = TempEvents[action] or {}
    local Parent = TempEvents[action]
    local new = setmetatable({signal.new(),action},TS)
    table.insert(Parent,new)
    return new
end
function TS.Fire(self,...)
    if not self[1] then error("Event is Dead") end 
    self[1]:Fire(...)
end
function TS.Connect(self, Callback)
    if not self[1] then error("Event is Dead") end 
    return self[1]:Connect(Callback)
end

function TS.Once(self, Callback)
    if not self[1] then error("Event is Dead") end 
	return self[1]:Once(Callback)
end

function TS.Wait(self)
    if not self[1] then error("Event is Dead") end 
	return self[1]:Wait()
end

function TS.Destroy(self)
    local parent = TempEvents[self[2]]
    local idx = table.find(parent,self)
    if idx then 
        table.remove(parent,idx)
    end
	table.clear(self[1])
    if #parent == 0 then
        TempEvents[self[2]] = nil
    end
    table.clear(self)
end
return TS