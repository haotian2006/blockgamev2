local BehaviorManager = {}
local EntityHandler = require(game.ReplicatedStorage.EntityHandler)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local SPECIALKEY = "↓BE🌟"
local DEAFULT_PRIORITY = 200
function BehaviorManager.checkIsBehavior(key)
    local length = #key
    if key:sub(length-7) ~= "behavior" then return false end 
    return key:sub(1,length-9)
end
function BehaviorManager.get(self,name)
    return EntityHandler.getAndCache(self,`{name}.behavior`)
end
function BehaviorManager.getAndCacheAll(self)
    local selfCache = EntityHandler.getCache(self)
    if selfCache[SPECIALKEY] then
        return selfCache[SPECIALKEY]
    end
    local BehaviorsFound = {}
    local Behaviors = {}
    local function loopAndInsert(t)
        for key:string,value in t do
            if type(key) ~= "string" then continue end 
            local name = BehaviorManager.checkIsBehavior(key)
            if not name or BehaviorsFound[name] then continue end
            BehaviorsFound[name] = value
            table.insert(Behaviors,{name,value.priority or DEAFULT_PRIORITY})
        end
    end
    
    for key,data in self.__components do
        loopAndInsert(data)
    end
    loopAndInsert(self.__main)

    table.sort(Behaviors,function(a,b)
        return a[2]<b[2]
    end)
    for index, value in Behaviors do
        Behaviors[index] = value[1]
    end
    selfCache[SPECIALKEY] = Behaviors
    return Behaviors
end
function BehaviorManager.getType(name)
    local data = BehaviorHandler.getEntityBehavior(name)
    if not data then return end 
    local type = data.Type 
    if not type then return end 
    return type 
end
local function contains(object1,object2)
    if type(object1) == "table" and type(object2) == "table" then
        for i,v in object1 do
            if table.find(object2,v) then return true end 
        end
    elseif  type(object1) == "table" then
        for i,v in object1 do
            if v == object2 then return true end 
        end
    elseif  type(object2) == "table" then
        for i,v in object2 do
            if v == object1 then return true end 
        end
    else
        return object1 == object2
    end
end
function BehaviorManager.setRuning(self,name,isRunning)
    local runningBehavior = self.__running or {}
    self.__running  = runningBehavior
    runningBehavior[name] = isRunning or nil
end
function BehaviorManager.isRunning(self,name,checkSameType)
    local runningBehavior = self.__running or {}
    self.__running  = runningBehavior
    if runningBehavior[name] then return true,name end 
    if not checkSameType then return  end
    local cType = BehaviorManager.getType(name)
    if not cType then return end 
    for i,v in runningBehavior do
        local iType = BehaviorManager.getType(i)
        if not iType then continue end 
        if contains(cType,iType) then return i end 
    end
end
function BehaviorManager.run(self)
    for i,name in BehaviorManager.getAndCacheAll(self) do
        local func = BehaviorHandler.getEntityBehavior(name) or {}
        if not func.Function then continue end   
        local data = BehaviorManager.get(self,name)
        if not data then continue end 
        func.Function(self,data)
    end
end
local Init = false
local EntityHolder = require(game.ReplicatedStorage.EntityHandler.EntityHolder)
local Runner = require(game.ReplicatedStorage.Runner)
function BehaviorManager.Init()
    if Init then return end 
    Init = true
    Runner.bindToStepped("Behavior",function(step,dt)
        for uuid,entity in EntityHolder.getAllEntities() do
            task.spawn(BehaviorManager.run,entity)
        end
    end,4)
end
return BehaviorManager