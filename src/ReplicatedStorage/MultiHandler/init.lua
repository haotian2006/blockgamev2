local self = {}
local workersmodule = require(game.ReplicatedStorage.WorkerThreads)
local runservice = game:GetService("RunService")
local IsClient = runservice:IsClient()
local https = game:GetService("HttpService")
local memory = script.GlobalMemory
local libarystosend = {
	game.ReplicatedStorage.QuickFunctions
	,not IsClient and game.ServerStorage.GenerationHandler or nil,
	game.ReplicatedStorage.GameSettings,
	game.ReplicatedStorage.RenderStuff.Culling,
	game.ReplicatedStorage.Libarys.compressor, 
	game.ReplicatedStorage.BehaviorHandler,
	game.ReplicatedStorage.ResourceHandler,
	game.ReplicatedStorage.Libarys.Debris,
	game.ReplicatedStorage.Libarys.MathFunctions,
	game.ReplicatedStorage.WorkerThreads,
	script.GlobalMemory,
	game.ReplicatedStorage.RenderStuff.Render,
	game.ReplicatedStorage.CollisonHandler,
	game.ReplicatedStorage.RenderStuff.GreedyMesh
}
local libarydata = {}
local Workers
local LargeWorkers 
function  self:Init()
	for i,v in libarystosend do libarydata[v.Name] = require(v) end 
	 Workers = workersmodule.New(game.ReplicatedStorage.MultiHandler.FunctionsToMultiThread,"Handler",300,libarystosend,{ResourceHandler = {Blocks = require(game.ReplicatedStorage.ResourceHandler).Blocks}})
	 LargeWorkers = workersmodule.New(game.ReplicatedStorage.MultiHandler.FunctionsToMultiThread,"LargeHandler",1,libarystosend)
	 return self
end
-- local DWorkers = workersmodule.New(game.ReplicatedStorage.MultiHandler.FunctionsToMultiThread,"DHandler",100,{
-- 	game.ReplicatedStorage.QuickFunctions,
-- 	game.ReplicatedStorage.compressor,
-- 	not IsClient and game.ServerStorage.GenerationHandler,
-- 	game.ReplicatedStorage.GameSettings,
-- 	game.ReplicatedStorage.RenderStuff,

-- })

local compressor = require(game.ReplicatedStorage.Libarys.compressor)
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
			local cdata = self.DoSmt("GenerateTerrain",v,cx,cz)
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
function self.Compress(data)
	local times = #data or 3
	local newdata = {}
	local ammountdone = 0 
	local thread = coroutine.running()
	for i,v in ipairs(data) do
		task.spawn(function()
			local cdata = self.DoSmt("Compress",v)
			newdata[i] = cdata
			ammountdone +=1
			if ammountdone == times then
				coroutine.resume(thread)
			end
		end)
	end
	if ammountdone ~= times then
		coroutine.yield()
	end
	return newdata
end
function self.DeCompress(data)
	local times = #data or 3
	local newdata = {}
	local ammountdone = 0 
	local thread = coroutine.running()
	for i,v in ipairs(data) do
		task.spawn(function()
			local cdata = self.DoSmt("DeCompress",v)
			newdata[i] = cdata
			ammountdone +=1
			if ammountdone == times then
				coroutine.resume(thread)
			end
		end)
	end
	if ammountdone ~= times then
		coroutine.yield()
	end
	return newdata
end
function  self.Render(cx,cz,data)
	return self.DoSmt("Render",cx,cz,data)
end
function self.HideBlocks(cx,cz,chunks,times)
	times = times or 3
	local newdata = {}
	local thread = coroutine.running()
	local ammountdone = 0 
	--local sterilise = game:GetService("HttpService"):JSONEncode(chunks)
	local data = self.divide(chunks[1],times)
	for i,v in data do
		task.spawn(function()
			local hideblocks = require(game.ReplicatedStorage.RenderStuff.Culling)
			--task.desynchronize()
		--	local cdata = self.LargeSend("HideBlocks",{3},2,cx,cz,v,false)
			local cdata = hideblocks.HideBlocks(cx,cz,chunks,v,libarydata)
			--local cdata = self.DoSmt("HideBlocks",cx,cz,sterilise,v)
			--local cdata = self.DDoSmt("HideBlocks",cx,cz,true,true)
			for e,c in cdata do
				newdata[tostring(e)] = c
			end
			--task.synchronize()
			ammountdone +=1
			if ammountdone == #data then
				coroutine.resume(thread)
			end
		end)
	end
	if ammountdone ~= #data then 	coroutine.yield() end
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