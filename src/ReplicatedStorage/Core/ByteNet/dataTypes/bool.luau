local bufferWriter = require(script.Parent.Parent.bufferWriter)
local types = require(script.Parent.Parent.types)

local btrue = bufferWriter.btrue
local bfalse = bufferWriter.bfalse
local alloc = bufferWriter.alloc

local bool = {
	--[[
		1 = true
		0 = false
		
		Write and read based off a uint8
	]]
	read = function(b: buffer, cursor: number)
		return buffer.readu8(b, cursor) == 1, 1
	end,
	write = function(value: boolean)
		alloc(1)

		if value then
			btrue()
		else
			bfalse()
		end
	end,
	isType = function(value)
		return type(value) == "boolean"
	end
}

return function(): types.dataTypeInterface<boolean>
	return bool
end
