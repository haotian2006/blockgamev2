local self = {}
local runservice = game:GetService("RunService")
local IsClient = runservice:IsClient()
local Workers = require(game.ReplicatedStorage.Libarys.Worker)
Workers:Init(500)
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
function basicDoWork(data,work)
	local times = #data 
	local newdata = {}
	local ammountdone = 0 
	local thread = coroutine.running()
	for i,v in data do
		task.spawn(function()
			local cdata = Workers:DoWork(work,v)
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
function self.Cull(chunk,ref)
	return Workers:DoWork("Cull",chunk,ref)
end
function self.Compress(data)
	return basicDoWork(data,"Compress")
end
function self.DeCompress(data)
	return basicDoWork(data,"DeCompress")
end

return self 