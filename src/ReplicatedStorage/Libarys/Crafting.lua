local Crafting = {}

local behhandler = require(game.ReplicatedStorage.BehaviorHandler)
local ItemHandler = require(game.ReplicatedStorage.Item)

local Recipies = {}
local Categories = {}
local function f(co,i)
    if not co[i] then return "" end 
    return co[i] ~= "" and {co[i],i} or ""
end

local function parseOrder(Order) 
	for i,v in Order do
		if type(v) == "table" then
			if type(v[1]) == "number" then
				v = table.clone(v)
				v[1] = ItemHandler.getNameFromIndex(v[1])
				Order[i] = v
			end
		end
	end
end

function Crafting.GetOutResult(Order)
	parseOrder(Order)
	
	local shape = {
		{},
		{},
		{}
	}
	local ItemToLookFor = nil
	local Is2X2 = false
	for i,v in Order do 
        if v ~= "" then 
            ItemToLookFor = v 
            break  
        end 
    end
    if not ItemToLookFor then return end 
	if #Order == 4 then
		Is2X2 = true
		shape[1] = {f(Order,1),f(Order,2)}
		shape[2] = {f(Order,3),f(Order,4)}
	else
		shape[1] = {f(Order,1),f(Order,2),f(Order,3)}
		shape[2] = {f(Order,4),f(Order,5),f(Order,6)}
		shape[3] = {f(Order,7),f(Order,8),f(Order,9)}
	end
	local noSpaces = table.clone(shape)
	Crafting.RemoveSpaces(noSpaces)
	for i,v in Categories[ItemToLookFor[1]] or {} do
		if v["Is3x3"] and Is2X2 then continue end 
		local item,count,remove = Crafting.CompareShapes(v,noSpaces)
		if not count then
			item,count,remove = Crafting.CompareShapes(v,shape)
		end
		if count then
			return item,count,remove
		end
	end
    return 
end
function Crafting.CompareShapes(CraftData,Shape)
	local key,shape = CraftData.Key,CraftData.Shape
	local ids = {}
	local needtocheck = 0
    local remove = {}
	for _,row in shape do
		for _,str in row:split('') do
			if str ~= "" and str ~= ' ' then 
				needtocheck +=1
			end
		end
	end
	--if not a then print(needtocheck) end 
	for col,row in Shape do
		if not shape[col] then continue end 
        local patternAt = shape[col]
		for i,Item in row do
			local pattern = patternAt:sub(i,i)
			if pattern == ' ' then 
                pattern = '' 
            end 
			pattern = pattern or ""
			Item = Item or ""

			if (pattern == "" or Item == "") and pattern ~= Item then 
                return 0 
            elseif Item == pattern then 
                continue  
            end 
			local Data = key[pattern]
			local Name,Id = Item[1][1],Item[1][2]
			if not Data then return 1 end 
			if Data.Item ~= Name then return 2 end 
			if Data.Id == "same" then
				ids[pattern] = ids[pattern] or Id 
				if ids[pattern] and ids[pattern] ~= Id then return 3 end
			elseif Data.Id and Data.Id ~= Id then
				return  4
			end
            table.insert(remove,Item[2])
			needtocheck -=1
		end
	end
	--if not a then print(needtocheck) end
	if needtocheck ~= 0 then
		return 6
	end
	local Result = CraftData.Result or {}
    local item,count,id = Result.Item,Result.Count or 1,ids[Result.Id] or Result.Id
    return  ItemHandler.new(item, id),count,remove
end
function Crafting.RemoveSpaces(shape)
	local function checkisempty(i)
		for i,v in shape[i] do 
            if v and v ~= "" then
                 return false 
            end 
        end 
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
	for _, row in shape do
		table.remove(row, lowestindex)
	end
	if checkisempty(2) and checkisempty(3) then 
        shape[2],shape[3] = {},{}
	elseif checkisempty(3) then 
        shape[3] = {} 
    end 
	if checkisempty(1) then 
        table.remove(shape,1) 
        shape[3] = {} 
    end
	return math.max(lowestindex , 0)
end
function Crafting.Init()
    for i,v in behhandler.getAllData().Crafting or {} do
        if v.Type == "Crafting" or not v.Type then
            Recipies[i] = v
            for key,item in v.Key or {} do
                item = item.Item
                Categories[item] = Categories[item] or {}
                Categories[item][i] = v
            end
        end
    end
    return Crafting
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
return Crafting