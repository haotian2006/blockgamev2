local bufferWriter = require(script.Parent.Parent.bufferWriter)
local types = require(script.Parent.Parent.types)

local u16 = bufferWriter.u16
local writestring = bufferWriter.writestring
local dyn_alloc = bufferWriter.dyn_alloc

local str = {
	-- 2 bytes for the length, then the string

	read = function(b: buffer, cursor: number)
		local length = buffer.readu16(b, cursor)

		return buffer.readstring(b, cursor + 2, length), length + 2
	end,
	write = function(data: string)
		local length = string.len(data)
		dyn_alloc(length + 2)

		u16(length)
		writestring(data)
	end,
	isType = function(value)
		return type(value) == "string"
	end
}

return function(): types.dataTypeInterface<string>
	return str
end
