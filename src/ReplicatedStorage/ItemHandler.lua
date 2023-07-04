local itemhand = {}
local qf,beh,reh,data 
local runs = game:GetService("RunService")
function itemhand:Init()
    qf = require(game.ReplicatedStorage.QuickFunctions)
    beh = require(game.ReplicatedStorage.BehaviorHandler)
    reh = require(game.ReplicatedStorage.ResourceHandler)
    data = require(game.ReplicatedStorage.DataHandler)
    return self
end
function itemhand.Decompress(data,only)
    return qf.DecompressItemData(data,only)
end
function itemhand.GetItemData(item)
    return beh.GetItemData(itemhand.Decompress(item,"T") or item )
end
function itemhand.GetItemComponent(item)
    local a =itemhand.Decompress(item,{"T","S"})
    print(a.T,a.S)
    return beh.GetBCFD(a.T,a.S)
end
function itemhand.GetItemType(item)
    local data = itemhand.GetItemData(item)
    return data and data.type,data
end
function itemhand.GetItemName(item)
    return itemhand.Decompress(item,"T")
end
function itemhand.IsA(item,type)  
    local d =itemhand.GetItemData()
    return d and d:IsA(type)
end
function itemhand.GetInputs(item)
    local data = itemhand.GetItemData(item)
    return data and data.OnInput,data
end
function itemhand.handleItemInput(input,isdown,controls,entity,Player)
    local plr = entity 
    if not plr or plr:GetState('Dead') or not plr.inventory  then return end 
    local inv = plr.inventory
    local ovri =false
    for i,v in inv.Data do
        if v == '' then continue end 
        local inputs,bdata = itemhand.GetInputs(v[1])
        if not inputs then continue end
        for inputname,data in inputs do
            local conditions,i = itemhand.CheckConditions(plr,i,input,inputname,data,controls)
            if not conditions or not isdown then continue end 
            task.spawn(function()
                itemhand.trigger(plr,{ItemData = bdata,Index = i,Item = v[1],InputData = data,Input = input,IsDown = isdown,Controls = controls,ItemHandler = itemhand,Player = Player or game.Players.LocalPlayer})
            end)
            ovri = true
        end
    end 
    return ovri
end 
function itemhand.CheckConditions(self,currentslot,input,triggername,data,controls)
    local conditions = {
        self.Ingui and not data.CanActivateInGui,
        currentslot ~= (self.CurrentSlot or 1) and  data.HasToBeInHand,
        data.HasToBeInHotBar and currentslot >9,
        triggername ~= input,
        (function()
            for i,v in data.AlsoHold or {} do if not controls:IsDown(v) then return true end end  
        end)(),
    }
    for i,v in conditions do if v then return nil,i end end
    return true
end
local function trigger(func,ItemData,...)
    if type(func) == "function" then
        func(...)
    elseif type(func) == 'string' then
        if beh.Getfunction(func) then
            beh.Getfunction(func)(...)
        elseif ItemData.functions and ItemData.functions[func] then
            ItemData.functions[func](...)
        end
    end
end
function itemhand.trigger(self,idata)
    local data = idata.InputData
    local id =idata.ItemData
    if data.Trigger then
        if type(data.Trigger) == "function" then
            trigger(data.Trigger,id,self,idata)
        elseif type(data.Trigger) == "table" then
            if data.Trigger.Client and runs:IsClient() then trigger(data.Trigger.Client,id,self,idata)
            elseif data.Trigger.Server and not runs:IsClient() then trigger(data.Trigger.Server,id,self,idata) 
            end

        end
    end
end
return itemhand