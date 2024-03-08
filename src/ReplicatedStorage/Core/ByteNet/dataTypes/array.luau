local bufferWriter = require(script.Parent.Parent.bufferWriter)
local types = require(script.Parent.Parent.types)

local u16 = bufferWriter.u16
local alloc = bufferWriter.alloc

--[[
	Create a new array with the given dataTypeInterface
]]
return function(valueType: types.dataTypeInterface<any>)


	return {
		read = function(b: buffer, cursor: number)
			local valueRead = valueType.read

			local arrayLength = buffer.readu16(b, cursor)
			local arrayCursor = cursor + 2
			local array = {}
 
			for _ = 1, arrayLength do
				local item, length = valueRead(b, arrayCursor)
				table.insert(array, item)

				arrayCursor += length
			end

			return array, arrayCursor - cursor
		end,
		write = function(value: any)
			local valueWrite = valueType.write

			alloc(2)
			u16(#value) -- write length, 2 bytes

			for _, item in value do
				-- add the length of the item to the cursor
				valueWrite(item)
			end
		end,
		isType = function(value)
			return type(value) == "table"
		end

	}
end
