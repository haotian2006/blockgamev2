local bufferWriter = require(script.Parent.Parent.bufferWriter)
local types = require(script.Parent.Parent.types)

local f32 = bufferWriter.f32
local alloc = bufferWriter.alloc

local float32 = {
	write = function(value: number)
		alloc(4)
		f32(value)
	end,

	read = function(b: buffer, cursor: number)
		return buffer.readf32(b, cursor), 4
	end,
	isType = function(value)
		return typeof(value) == "number"
	end
}

return function(): types.dataTypeInterface<number>
	return float32
end
