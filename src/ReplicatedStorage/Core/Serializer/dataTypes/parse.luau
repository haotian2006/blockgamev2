local bufferWriter = require(script.Parent.Parent.bufferWriter)
local types = require(script.Parent.Parent.types)


-- thanks jack :p
return function(
	dataType: types.dataTypeInterface<any>,
    Ster:(any)->(any),
    Dester:(any)->(any)
): types.dataTypeInterface<{ [any]: any }>
	-- Cache these functions to avoid the overhead of the index


	return {
		read = function(b: buffer, cursor: number)
			local Read = dataType.read
            local v,l = Read(b, cursor)
            if Dester then
                v = Dester(v)
            end
		    return v,l
		end,
		write = function(value:any)
			local Write = dataType.write
            if Ster then
                value = Ster(value)
            end
            Write(value)
			
		end,
		isType = function(value)
			return true
		end
	}
end
