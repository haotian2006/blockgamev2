local container = {}
local RunService = game:GetService("RunService")
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ItemClass = require(game.ReplicatedStorage.Item)
local Changed = {}

function container.new(type,size,parent,name,callBack)
    local t = table.create(size+1,"")
    t[1] = type 
    t[#t+1] = {__Parent = parent,__Opened = {},__Call = callBack,__Name = name}
    return t
end

function container.fromData(t,parent,name,callBack)
    t[#t+1] = {__Parent = parent,__Opened = {},__Call = callBack,__Name = name}
    return t
end

local function getValue(x)
    if not x then return end 
    if x == "" then 
        return "",0
    end
    return x[1],x[2]
end


local function equals(x,y)
    if x == "" and y == "" then
        return true
    elseif type(x) == "table" and type(y) == "table" then
        return ItemClass.equals(x, y)
    end
    return false
end

local function update(self,idx,old)
    local data = Changed[self] 
    if not data then
        data = {}
        Changed[self]  = data
    end
    data[idx] = true
    
    local call = self[#self].__Call
    if call then
        call(self,idx,old)
    end

    local cData = container.getContainerData(self)
    if not cData or not cData.OnUpdate then return end 
    local new = self[idx+1]
    local oldV,oldC = getValue(old)
    local newV,newC = getValue(new)
    if oldV == newV and oldC == newC then return end 
    cData.OnUpdate(self,idx,old,new)
end

function container.setChangedTable(t)
    Changed = t
end

function container.setParent(self,parent)
    self[#self].__Parent = parent
end
function container.getParent(self)
    return  self[#self].__Parent
end

function container.getName(self)
    return self[#self].__Name or self[1]
end

function container.setOpened(self,player)
   local data = self[#self]
   local Opened = data.__Opened
   if not Opened then
        Opened = {}
        data.__Opened = Opened
   end
   local i = table.find(Opened,player)
   if i then return end 
   table.insert(Opened,player)
end

function container.removeOpen(self,player)
    local data = self[#self]
    local Opened = data.__Opened
    if not Opened then
         Opened = {}
         data.__Opened = Opened
    end
    local i = table.find(Opened,player)
    if not i then return end 
    table.remove(Opened,i)
 end

function container.getOpened(self)
    local data = self[#self]
    local Opened = data.__Opened
    if not Opened then
         Opened = {}
         data.__Opened = Opened
    end
    return Opened
end

function container.getValueAt(self,idx)
    return getValue(self[idx+1])
end

function container.getAllItems(self)
    local Items = {}
    local l = #self
    for i,v in self do
        if i == 1 or i == l or v == "" then continue end 
        table.insert(Items,v)
    end
    return Items
end

function container.clear(self)
    local l = #self
    for i,v in self do
        if i == 1 or i == l or v == "" then continue end 
        self[i] = ""
        update(self, i-1, v)
    end
end

function container.getContainerData(self)
    return BehaviorHandler.getContainer(self[1])  or {Frames ={}}
end

function container.getFrameData(self,idx)
    local containerData = container.getContainerData(self)
    local Frames = containerData.Frames or {}
    return Frames[idx]
end

function container.checkOutOfBounds(self,idx)
    return #self-2 < idx or idx == 0
end

function container.size(self)
    return #self-2
end

function container.playerCanModify(self,player)
    local opened = container.getOpened(self)
    return table.find(opened, player) ~= nil
end

function container.resize(self,newSize)
    local diff = newSize-(#self-2)
    if diff == 0 then return end 
    local func = if diff > 0 then table.insert else table.remove
    for i =1,diff do
        func(self,#self-1,"")
    end
end

--//just sets and retun data at - Does not care if old data is the same 
function container.set(self,idx,item,count)
    if container.checkOutOfBounds(self,idx)then
        error(`Index {idx} is out of bounds for size {#self-2}`) 
        return 
    end 
    idx =( idx or 1) + 1
    local old = self[idx]
    if item == "" or count <= 0 then
        self[idx] = ""
    else
        self[idx] = {item,count}
    end
    update(self,idx-1,old)
    return old
end

function container.setCount(self,idx,count)
    if container.checkOutOfBounds(self,idx)then
        error(`Index {idx} is out of bounds for size {#self-2}`) 
        return 
    end 
   
    local at =  container.get(self, idx)
    if at == "" then
        return
    end

    if count> 0 then
        return container.setAt(self,idx,at[1],at[2]+count)
    end
    container.set(self, idx, at[1], at[2]+count)
    return
end


--//checks if the data at is the same and adds to it instead, if its diffrent override it and return old 
function container.setAt(self,index,Itemdata,count)
    if container.checkOutOfBounds(self,index)then
        error(`Index {index} is out of bounds for size {#self-2}`) 
        return 
    end 
    index = (index or 1)+1
    local max = ItemClass.getMaxCount(Itemdata)
    local v = self[index]
    local oldV = v ~= "" and table.clone(v) or ""
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
    update(self, index-1,oldV)
    if count == 0 then return end  
    return Itemdata,count
end

--//attempt to swap the given item from container1 to container 2, if items are same and not full and canStack then stack it 
function container.swap(container1,container2,from,to,canStack,canBeOutPut)
    if container.checkOutOfBounds(container1,from) or
        container.checkOutOfBounds(container2,to)
        then
        error(`Index(s) out of bounds for size(s) `) 
        return 
    end 
    local item1 = container1[from+1]
    local item2 = container2[to+1]
    local value1,c1 = getValue(item1)
    local value2,c2 = getValue(item2)
    local function swap() --swaps the vars
        local temp = container1
        container1 = container2  
        container2 = temp
        temp = from
        from = to
        to = temp
        temp = item1
        item1 = item2
        item2 = temp
    end
    if value1 == "" and value2 == "" then
        return 
    end
    if container.isOutput(container2,to) then
        swap()
        value1,c1 = getValue(item1)
        value2,c2 = getValue(item2)
    end
    if container.isOutput(container1,from) then
        local FrameData = container.getFrameData(container1, from) or {}
        local RequiresAll = FrameData["RequiresGrabAll"]
        if value2 ~= "" and not ItemClass.equals(value1, value2) then return end 
        if RequiresAll and (c1 + c2 > ItemClass.getMaxCount(value1)) then return end 
        local left,count = container.setAt(container2, to,value1,c1 )
        if not left then 
            container.set(container1, from,"" )
            return
        end 
        container.set(container1, from,left,count )
        return
    end
    if  equals(value1,value2) and canStack then
        if item1[2] >item2[2] then
            swap()
        end
        local left,count = container.setAt(container2, to, item1[1], item1[2])
        if not left then 
            container.set(container1, from,"")
            return
        end 
        container.set(container1, from,left,count )
        return 
    end
    container.set(container1, from,value2,c2 )
    container.set(container2, to,value1,c1 )
end

function container.add(self,Item,count,canBeOutput)
    local max = ItemClass.getMaxCount(Item)
    while count > 0 do
        local i = container.find(self,Item,canBeOutput,true) or container.getEmpty(self)
        if not i then break end 
        i +=1
        local v = self[i]
        local oldV = v ~= "" and table.clone(v) or ""
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
        update(self, i-1,oldV)
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
    local FData = container.getFrameData(self,idx) 
    return if FData and FData["OutputOnly"]  then true else false
end

function container.find(self,Item,canBeOutput,CannotBeFull)
    local size = #self
    for i,v in self do
        if i == 1 or v == '' or i == size  then continue end
        if container.isOutput(self, i-1) and not canBeOutput then continue end 
        local ItemAt = v[1]
        if not ItemClass.equals(ItemAt, Item) then continue end 
        local Count = ItemClass.getMaxCount(Item)
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


--//todo
function container.compress(self,key)
    key = key or {}
    local compressed = {self[1]}
    local function getIdx(x)
        for i,v in key do
            if equals(x,v) then
                return i
            end
        end
        key[#key+1] = x
        return #key
    end
    local last,idx
    local count = 0 
    for i =2,#self do
        if not last then
            last = self[i]
            idx = getIdx(self[i])
            count = 1
        elseif equals(self[i], last) then
            
        end
    end
end

return container