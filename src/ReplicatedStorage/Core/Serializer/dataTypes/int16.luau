local bufferWriter = require(script.Parent.Parent.bufferWriter)
local types = require(script.Parent.Parent.types)

local i16 = bufferWriter.i16
local alloc = bufferWriter.alloc

local int16 = {
	write = function(value: number)
		alloc(2)
		i16(value)
	end,

	read = function(b: buffer, cursor: number)
		return buffer.readi16(b, cursor), 2
	end,
	isType = function(value)
		return typeof(value) == "number"
	end
}

return function(): types.dataTypeInterface<number>
	return int16
end
