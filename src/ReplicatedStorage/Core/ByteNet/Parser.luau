--!strict
--!native
--!optimize 2

local types = require(script.Parent.types)

local bufferWriter = require(script.Parent.bufferWriter)
local load = bufferWriter.loadDefault
local dump = bufferWriter.dump
local exportChannel = bufferWriter.export



return function(value: types.dataTypeInterface<any>)

	local writer = value.write
	local reader = value.read

	local exported = {}

	exported.sterilize = function(data)
		load()
		writer(data)
		return dump(exportChannel())
	end

	exported.write = function(data)
		writer(data)
	end

	exported.read = function(incomingBuffer,cursor)
		return reader(incomingBuffer, cursor)
	end

	exported.desterilize = function(incomingBuffer)
		return reader(incomingBuffer, 0)
	end

	return exported
end
