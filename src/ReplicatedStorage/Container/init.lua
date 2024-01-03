local container = {}
local RunService = game:GetService("RunService")
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ItemClass = require(game.ReplicatedStorage.Item)
local IS_CLIENT = RunService:IsClient()

function container.new(type,size)
    local t = table.create(size+1,"")
    t[1] = type 
    return t
end


function container.getContainerData(self)
    return BehaviorHandler.getContainer(self[1])  or {}
end

--//just sets and retun data at - Does not care if old data is the same 
function container.set(self,idx,item,count)
    idx =( idx or 1) + 1
    local old = self[idx]
    self[idx] = {item,count}
    return old
end

--//checks if the data at is the same and adds to it instead, if its diffrent override it and return old 
function container.setAt(self,index,Itemdata,count)
    index = (index or 1)+1
    local max = ItemClass.getMaxCount(Itemdata)
    local v = self[index]
    local add = 0
    local equals = if type(v) == "table" then ItemClass.equals(v[1], Itemdata) else nil
    if equals then
        if  v[2] < max then
            add = (max-v[2])
            if count < add then
                add = count
            end
            self[index][2] += add
            count -= add
        else
            local a= self[index][2]
            self[index][2] = count
            count = a
        end
    elseif equals == false then
        local old,c = v[1],v[2]
        v[1] = Itemdata
        v[2] = count
        Itemdata = old
        count = c
    else
        self[index] = {Itemdata,count}
        count= 0
    end
   -- self:UP()
    if count == 0 then return end  
    return Itemdata,count
end

function container.add(self,Item,count,canBeOutput)
    local max = ItemClass.getMaxCount(Item)
    while count > 0 do
        local i = container.find(self,Item,canBeOutput,true) or container.getEmpty(self)
        if not i then break end 
        i +=1
        local v = self[i]
        local add = 0
        if type(v) == "table"  then
            if  v[2] >= max then continue end 
            add = (max-v[2])
            if count < add then
                add = count
            end
            self[i][2] += add
        else
            if count <= max then
                add = count
            else
                add = max 
            end
            self[i] = {Item,add}
        end
        count -= add
    end
    return if count ~=0 then count else nil
end

function container.get(self,idx)
    return self[idx+1]
end

function container.getEmpty(self)
    for i,v in self do
        if v ~= "" or container.isOutput(self, i-1) then continue end 
        return i-1
    end
    return
end

function container.isOutput(self,idx)
    local CData = container.getContainerData(self)
    return if CData[idx] and CData[idx]["OutputOnly"] then true else false  
end

function container.find(self,Item,canBeOutput,CannotBeFull)
    local CData = container.getContainerData(self)
    for i,v in self do
        if i == 1 or v == '' then continue end 
        local frameData =  CData[i-1] 
        if frameData and frameData["OutputOnly"] and not canBeOutput then continue end 
        local ItemAt = v[1]
        if not ItemClass.equals(ItemAt, Item) then continue end 
        local Count = ItemClass.getData(Item)
        if CannotBeFull and v[2] >= (Count or 64) then
            continue
        end
        return i-1
    end
    return nil
end

function container.findSpot(self,Item,canbeOutput)
    return container.find(self, Item, canbeOutput, true) or container.getEmpty(self)
end

return container