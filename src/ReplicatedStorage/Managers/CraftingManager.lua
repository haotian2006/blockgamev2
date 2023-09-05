local c = {}
local player = game.Players.LocalPlayer
local resourcehandler = require(game.ReplicatedStorage.ResourceHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local runservice = game:GetService("RunService")
local dataHandler = require(game.ReplicatedStorage.DataHandler)
local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local PEntity = dataHandler.GetLocalPlayer
local mouse = player and player:GetMouse()
local UserInput = game:GetService('UserInputService')
c.Recipies = {}
c.Categories = {}
local function cn(co,i)
    return co[i] ~= "" and {co[i][1],co[i][2],i} or ""
end
function c.GetOutResult(craftingobject)
	local shape = {
		{},
		{},
		{}
	}
	local ItemToLookFor = nil
	local Is2X2 = false
	for i,v in craftingobject do if v ~= "" then ItemToLookFor = qf.DecompressItemData(v[1],"T") break  end end
	if craftingobject:len() == 4 then
		Is2X2 = true
		shape[1] = {cn(craftingobject,1),cn(craftingobject,2)}
		shape[2] = {cn(craftingobject,3),cn(craftingobject,4)}
	elseif craftingobject:len() == 9 then
		shape[1] = {cn(craftingobject,1),cn(craftingobject,2),cn(craftingobject,3)}
		shape[2] = {cn(craftingobject,4),cn(craftingobject,5),cn(craftingobject,6)}
		shape[3] = {cn(craftingobject,7),cn(craftingobject,8),cn(craftingobject,9)}
	end
	local olds,news = shape,qf.deepCopy(shape)
	c.RemoveSpaces(news)
	for i,v in c.Categories[ItemToLookFor] or {} do
		if v["3x3Only"] and Is2X2 then continue end 
		local key,shape = v.key,v.shape
		local item,count,id,remove = c.CompareShapes(v,news,true)
		if not count then
			item,count,id,remove = c.CompareShapes(v,olds)
		end
		if count then
			return item,count,id,remove
		end
	end
end
function c.CompareShapes(v,t2,a)
	local key,shape = v.key,v.shape
	local ids = {}
	local needtocheck = 0
    local remove = {}
	for i,v in shape do
		for ii,vv in v:split('') do
			if vv ~= "" and vv ~= ' ' then 
				needtocheck +=1
			end
		end
	end
	--if not a then print(needtocheck) end 
	for col,row in t2 do
		if not shape[col] then continue end 
		for i,v in row do
			local it = shape[col]:sub(i,i)
			if it == ' ' then it = '' end 
			it = (not it) and "" or it
			v = (not v) and '' or v
			if (it == "" or v == "") and it ~= v then return 0 elseif it == v then continue  end 
			local dit = key[it]
			local data = qf.DecompressItemData(v[1] or {},{"T","I"}) or {}
			local type,id = data.T,tostring(data.I)
			if not dit then return 1 end 
			if dit.Item ~= type then return 2 end 
			dit.Id = tostring(dit.Id)
			if dit.Id =="same" then
				ids[it] = ids[it] or id 
				if ids[it] and ids[it] ~= id then return 3 end
			elseif dit.Id and dit.Id ~= id then
				return  4
			end
            table.insert(remove,v[3])
			needtocheck -=1
		end
	end
	--if not a then print(needtocheck) end
	if needtocheck == 0 then
		local r = v.result or {}
		local item,count,id = r.Item,r.Count or 1,ids[r.Id] or tonumber(r.Id)
		return  item,count,id,remove
	end

	return 6
end
function c.RemoveSpaces(shape)
	local function checkisempty(i)
		for i,v in shape[i] do if v and v ~= "" then return false end end 
		return true
	end 
	local lowestindex = 4
	for _, row in shape do
		for i, v in row do
			if v ~= "" and (not row[i-1] or row[i-1] == "") then
				lowestindex = math.min(lowestindex, i-1)
				break
			end
		end
	end
	for _, row in ipairs(shape) do
		table.remove(row, lowestindex)
	end
	if checkisempty(2) and checkisempty(3) then shape[2],shape[3] = {},{}
	elseif checkisempty(3) then shape[3] = {} end 
	if checkisempty(1) then table.remove(shape,1); shape[3] = {} end
	return math.max(lowestindex , 0)
end
function c:Init()
    for i,v in behhandler.Crafting or {} do
        if v.type == "Crafting" then
            c.Recipies[i] = v
            for key,item in v.key or {} do
                item = item.Item
                c.Categories[item] = c.Categories[item] or {}
                c.Categories[item][i] = v
            end
        end
    end
    return c
end
--[[ *recipie example
Test = {
    type = "Crafting",
    key = {
        d = {
            Item ='c:Dirt',
            Id = "same" -- any,same
            }
    },
    shape = {
        "d",
        "d"
    },
    result = {
        Item = 'c:Grass'
        Id = "d" -- this will have the id of d
    }

}

]]
return c