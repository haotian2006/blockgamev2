local bufferWriter = require(script.Parent.Parent.bufferWriter)
local types = require(script.Parent.Parent.types)

local u16 = bufferWriter.u16
local copy = bufferWriter.copy
local dyn_alloc = bufferWriter.dyn_alloc

local buff = {
	read = function(b: buffer, cursor: number)
		local length = buffer.readu16(b, cursor)
		local freshBuffer = buffer.create(length)

		-- copy the data from the main buffer to the new buffer with an offset of 2 because of length
		buffer.copy(freshBuffer, 0, b, cursor + 2, length)

		return freshBuffer, length + 2
	end,
	write = function(data: buffer)
		local length = buffer.len(data)
		dyn_alloc(length + 2)

		-- write the length of the buffer, then the buffer itself
		u16(length)
		copy(data)
	end,
	isType = function(value)
		return typeof(value) == "buffer"
	end
}

return function(): types.dataTypeInterface<buffer>
	return buff
end
