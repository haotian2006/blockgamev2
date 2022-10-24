local self = {}
local workersmodule = require(game.ReplicatedStorage.WorkerThreads)
local runservice = game:GetService("RunService")
local IsClient = runservice:IsClient()
local Workers = workersmodule.New(game.ReplicatedStorage.MultiHandler.FunctionsToMultiThread,"Handler",100,{
	game.ReplicatedStorage.QuickFunctions
	,not IsClient and game.ServerStorage.GenerationHandler

})
function self.divide(original,times,destroy)
	local tables = {}
	for i =1,times do
		table.insert(tables,{})
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
		if  destroy then
			original[i] = nil
		end
	end
	return tables
end
function self.GlobalGet(func,data,times)
	times = times or 3
	local newdata = {}
	local thread = coroutine.running()
	local ammountdone = 0
	for i,v in ipairs(self.divide(data,times)) do
		task.spawn(function()
			local cdata = self.DoSmt(func,v)
			for e,c in cdata do
				newdata[e] = c
			end
			ammountdone +=1
			if ammountdone == times then
				coroutine.resume(thread)
			end
		end)
	end
	coroutine.yield()
	return newdata
end
function self.GetTerrain(cx,cz,times)
	if IsClient then return end
	times = times or 3
	local newdata = {}
	local thread = coroutine.running()
	local ammountdone = 0
	local data = require(game.ServerStorage.GenerationHandler).GenerateTable(cx,cz,100)
	for i,v in ipairs(self.divide(data,times)) do
		task.spawn(function()
			local cdata = self.DoSmt("GenerateTerrain",v)
			for e,c in cdata do
				newdata[e] = c
			end
			ammountdone +=1
			if ammountdone == times then
				coroutine.resume(thread)
			end
		end)
	end
	coroutine.yield()
	return newdata
end
function self.DoSmt(func,...)
    local dots = {...}
    table.insert(dots,{'handler',func})
	local c = unpack(dots)
    return Workers:DoWork(unpack(dots))
end
return self 