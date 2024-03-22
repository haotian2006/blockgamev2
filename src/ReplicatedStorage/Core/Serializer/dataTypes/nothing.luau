local types = require(script.Parent.Parent.types)

local nothing = {
	write = function() end,

	read = function()
		return nil, 0
	end,
    isType = function(v)
        return true
    end
}

return function(): types.dataTypeInterface<any>
	return nothing
end