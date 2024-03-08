local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)

local runContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

type structData = {
	[string]: number,
}

return function(input: {
	[string]: types.dataTypeInterface<any>,
}): types.dataTypeInterface<any>
	-- This is used in the reading/writing parts, and isn't used in the initialization code
	-- It's used to store the index-value pairs and the index-key pairs
	-- Index being the position of the value in the array, and the key being the key in the struct dictionary
	local indexValueTypePairs: {
		[number]: types.dataTypeInterface<any>,
	} = {}
	local indexKeyPairs: { [number]: string } = {}

	--[[
		Array should look like {
			[index (1)] = value
			[index (2)] = value
		}

		Index value type is {
			[index (1)] = int32
		}

		Index key is {
			[index (1)] = "structField"
		}
	]]

	local serializedStruct = {}

	local sorted = {}
	for key in input do
		table.insert(sorted,key)
	end
	table.sort(sorted)
	-- Convert the struct to an array
	local count = 0
	for _,key in sorted do
		count += 1
		serializedStruct[key] = count

		-- Store the index-value pairs and the index-key pairs as a shortcut for serializing n all that
		indexValueTypePairs[count] = input[key]
		indexKeyPairs[count] = key
	end

	return {
		read = function(b, cursor)
			local constructed = {}
			local structCursor = cursor

			for index, valueType in indexValueTypePairs do
				local value, length = valueType.read(b, structCursor)

				constructed[indexKeyPairs[index]] = value

				structCursor += length
			end

			return constructed, structCursor - cursor
		end,
		write = function(structValue)
			for index, valueType in indexValueTypePairs do
				valueType.write(structValue[indexKeyPairs[index]])
			end
		end,
		isType = function(value)
			return type(value) == "table"
		end
	}
end
