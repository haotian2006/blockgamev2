local stuff = {}
local runservice = game:GetService("RunService")
local IsClient = runservice:IsClient()
function stuff.divide(original,times,destroy)
	local tables = {}
	for i =1,times do
		tables[i] = {}
	end
	local length = 0
	for i,v in pairs(original)do
		length +=1
		for t =times,1,-1 do
			if length%t ==0 then
				tables[t][i] = v
				break
			end
		end
		if destroy then
			original[i] = nil
		end
	end
	return tables
end
function  stuff.HideBlocks(M,...)
	local func = M.Culling.HideBlocks
	local dot = {...}
	table.insert(dot,M)
	return func(unpack(dot))
end
function stuff.CreatePart(M,Ammount)
	local parts = {}
	for i =1,Ammount do
		table.insert(parts,Instance.new("Part"))
	end
	return parts
end
function stuff.CompressItemData(M,data)
    local functions = M.QuickFunctions.CompressItemData
    local newdata = {}
    for i,v in data do
        newdata[tostring(i)] = functions(v)
    end
    return newdata
end
function stuff.DecompressItemData(M,data)
    local functions = M.QuickFunctions.DecompressItemData
    local newdata = {}
    for i,v in data do
		if typeof(v) == "table" then
       		newdata[tostring(i)] = functions(unpack(v))
		else
			newdata[tostring(i)] = functions(v)
        end
    end
    return newdata
end
function stuff.GenerateWorms(M,cx,cz)
    local functions = M.GenerationHandler.runfunctionfrommuti
	return  functions(M,"CreateWorms",cx,cz)

end

function stuff.GenerateTerrain(M,data,cx,cz)
    local functions = M.GenerationHandler.runfunctionfrommuti
    local newdata = {}
	local index = 0
    for i,v in data do
		local x,z = unpack(i:split(','))
		local isblock = false
		for y = 60,0,-1 do
			local v = M.QuickFunctions.convertchgridtoreal(cx,cz,x,y,z,true)
			index+=1
			local isair = (not functions(M,"IsAir",v.X,v.Y,v.Z)) and true
			newdata[x..','..y..','..z] =  isblock or isair or nil
			isblock = isblock or isair
		end
		--v = M.QuickFunctions.cv3type("vector3",i) 'T|s%C:Dirt'
		--if index%500 == 0 then task.wait() end
    end
    return newdata
end

local queue = {}

function stuff.LargeHandler(M,combine,...)
	local whichonetocall = ""
	local dots = {...}
	for i,v in combine do
		local i = tonumber(i)
		queue[i] = queue[i] or {}
		for cc,vv in v do
			queue[i][cc] = vv
		end
	end
	for i,v in ipairs(dots) do
		if type(v) == "table" and v[1] and v[2] and v[1] == "handler" then
			whichonetocall = v[2]
			table.remove(dots,i)
			continue
		end		
	end
	if stuff[whichonetocall] and next({...}) then
		for i,v in queue do
			dots[i] = v
		end
		queue = {}
		return stuff[whichonetocall](M,unpack(dots))
	end
end
function stuff.Handler(M,...)
	local whichonetocall
	local dots = {...}
	for i,v in ipairs(dots) do
		if type(v) == "table" and v[1] and v[2] and v[1] == "handler" then
			whichonetocall = v[2]
			table.remove(dots,i)
			continue
		end		
	end
	if stuff[whichonetocall] then
		return stuff[whichonetocall](M,unpack(dots))
	end
end
return stuff