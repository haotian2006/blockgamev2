--!strict
--!native
--!optimize 2

local types = require(script.Parent.types)

local bufferWriter = require(script.Parent.bufferWriter)
local load = bufferWriter.loadDefault
local dump = bufferWriter.dump
local exportChannel = bufferWriter.export



return function(value: types.dataTypeInterface<any>)


	local exported = {}

	exported.sterilize = function(data)
		local writer = value.write
		load()
		writer(data)
		return dump(exportChannel())
	end

	exported.write = function(data)
		local writer = value.write
		writer(data)
	end

	exported.read = function(incomingBuffer,cursor)
		local reader = value.read
		return reader(incomingBuffer, cursor)
	end

	exported.desterilize = function(incomingBuffer)
		local reader = value.read
		return reader(incomingBuffer, 0)
	end

	return exported
end
