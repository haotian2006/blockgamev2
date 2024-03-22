

local types = require(script.Parent.Parent.types)

local bufferWriter = require(script.Parent.Parent.bufferWriter)

type structData = {
	[string]: number,
}
local END = 65533
return function(input: {
	[string]: types.dataTypeInterface<any>,
},Order:{string} ): types.dataTypeInterface<any>

	local indexValueTypePairs: {
		[number]: types.dataTypeInterface<any>,
	} = {}
	local indexKeyPairs: { [number]: string } = Order
	local KeyIndexPairs = {}
	for i,v in indexKeyPairs do
		indexValueTypePairs[i] = input[v]
		KeyIndexPairs[v] = i
	end

	return {
		read = function(b, cursor)
			local constructed = {}
			local structCursor = cursor

			while true do
				local key = buffer.readu16(b, structCursor)
				structCursor+=2
				if key == END then break end 
				local valueType,KeyName = indexValueTypePairs[key],indexKeyPairs[key]
				if not valueType then
					warn("Hole Detected In SpecialStruct, Cannot Continue ")

					return constructed,structCursor - cursor
				end
				local value, vlength = valueType.read(b, structCursor)
				structCursor+=vlength
				constructed[KeyName] = value
			end

			return constructed, structCursor - cursor
		end,
		write = function(structValue)
			for i,v in structValue do
				local idx = KeyIndexPairs[i]
				bufferWriter.u16(idx)
				local valueType = indexValueTypePairs[idx]
				valueType.write(v)
			end
			bufferWriter.u16(END)
		end,
		isType = function(value)
			return type(value) == "table"
		end
	}
end
