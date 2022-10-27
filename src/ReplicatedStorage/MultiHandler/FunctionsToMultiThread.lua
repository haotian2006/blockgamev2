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
	local func = M.RenderHandler.HideBlocks
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
function stuff.CompressBlockData(M,data)
    local functions = M.QuickFunctions.CompressBlockData
    local newdata = {}
    for i,v in data do
        newdata[tostring(i)] = functions(v)
    end
    return newdata
end
function stuff.DecompressBlockData(M,data)
    local functions = M.QuickFunctions.DecompressBlockData
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
function stuff.GenerateTerrain(M,data)
    local functions = M.GenerationHandler.IsAir
    local newdata = {}
    for i,v in data do
		newdata[tostring(i)] = (not functions(v.X,v.Y,v.Z)) and v or nil
    end
    return newdata
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