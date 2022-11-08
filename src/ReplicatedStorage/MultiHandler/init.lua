local self = {}
local workersmodule = require(game.ReplicatedStorage.WorkerThreads)
local runservice = game:GetService("RunService")
local IsClient = runservice:IsClient()
local https = game:GetService("HttpService")
local libarystosend = {
	game.ReplicatedStorage.QuickFunctions
	,not IsClient and game.ServerStorage.GenerationHandler or nil,
	game.ReplicatedStorage.GameSettings,
	game.ReplicatedStorage.RenderStuff.Culling,
	game.ReplicatedStorage.compressor, 

}
local Workers = workersmodule.New(game.ReplicatedStorage.MultiHandler.FunctionsToMultiThread,"Handler",500,libarystosend)
local LargeWorkers = workersmodule.New(game.ReplicatedStorage.MultiHandler.FunctionsToMultiThread,"LargeHandler",100,libarystosend)
-- local DWorkers = workersmodule.New(game.ReplicatedStorage.MultiHandler.FunctionsToMultiThread,"DHandler",100,{
-- 	game.ReplicatedStorage.QuickFunctions,
-- 	game.ReplicatedStorage.compressor,
-- 	not IsClient and game.ServerStorage.GenerationHandler,
-- 	game.ReplicatedStorage.GameSettings,
-- 	game.ReplicatedStorage.RenderStuff,

-- })

local compressor = require(game.ReplicatedStorage.compressor)
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
				newdata[tostring(e)] = c
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
	local genhand = require(game.ServerStorage.GenerationHandler)
	times = times or 3
	local newdata = {}
	local thread = coroutine.running()
	local ammountdone = 0
	local data = genhand.GenerateTable(cx,cz)
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
function self.HideBlocks(cx,cz,chunks,times)
	times = times or 3
	local newdata = {}
	local thread = coroutine.running()
	local ammountdone = 0 
	--local sterilise = compressor.compresslargetable(chunks[1],5)
	for i,v in ipairs(self.divide(chunks[1],times)) do
		task.spawn(function()
		--	local cdata = self.LargeSend("HideBlocks",{3},2,cx,cz,v,false)
			local cdata = self.DoSmt("HideBlocks",cx,cz,chunks,v)
			--local cdata = self.DDoSmt("HideBlocks",cx,cz,true,true)
			for e,c in cdata do
				newdata[tostring(e)] = c
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
function self.GenerateWorms(cx,cz)
	return self.DoSmt("GenerateWorms",cx,cz)
end
function self.CreatePart(ammount,times)
	times = times or 3
	local newdata = {}
	local thread = coroutine.running()
	local ammountdone = 0
	local data = {}
	local cir = 1
	while ammount ~= 0  do
		data[cir] = data[cir] or 0
		data[cir] +=1
		ammount-=1
		cir = cir==times and 1 or cir+1
	end
	
	for i,v in pairs(data) do
		task.spawn(function()
			local cdata = self.DoSmt("CreatePart",v)
			for e,c in cdata do
				table.insert(newdata,c)
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
function self.LargeSend(func,indexs,times,...)
	local workertouse = LargeWorkers:GetNextWorker()
	local dots = {...}
	local newdata = {}
	for i,v in indexs do
		local data = dots[v]
		newdata[v] = self.divide(data,times) 
		dots[v] = ""
	end
	for i =1,times do
		local datatosend = {}
		for c,v in newdata do
			datatosend[tostring(c)] = v[i]
		end
		if i == times then
			table.insert(dots,{'handler',func})

			return  workertouse:Invoke(datatosend,unpack(dots))
		else
			workertouse:Invoke(datatosend)
		end
	end
end
function self.DoSmt(func,...)
    local dots = {...}
    table.insert(dots,{'handler',func})
    return Workers:DoWork(unpack(dots))
end
return self 