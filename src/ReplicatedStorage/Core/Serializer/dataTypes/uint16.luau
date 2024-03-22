local bufferWriter = require(script.Parent.Parent.bufferWriter)
local types = require(script.Parent.Parent.types)

local u16 = bufferWriter.u16
local alloc = bufferWriter.alloc

local uint16 = {
	write = function(value: number)
		alloc(2)
		u16(value)
	end,

	read = function(b: buffer, cursor: number)
		return buffer.readu16(b, cursor), 2
	end,
	isType = function(value)
		return type(value) == "number"
	end
}

return function(): types.dataTypeInterface<number>
	return uint16
end
