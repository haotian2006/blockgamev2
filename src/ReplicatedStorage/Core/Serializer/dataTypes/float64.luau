local bufferWriter = require(script.Parent.Parent.bufferWriter)
local types = require(script.Parent.Parent.types)

local f64 = bufferWriter.f64
local alloc = bufferWriter.alloc

local float64 = {
	write = function(value: number)
		alloc(8)
		f64(value)
	end,

	read = function(b: buffer, cursor: number)
		return buffer.readf64(b, cursor), 8
	end,
	isType = function(value)
		return typeof(value) == "number"
	end
}

return function(): types.dataTypeInterface<number>
	return float64
end
