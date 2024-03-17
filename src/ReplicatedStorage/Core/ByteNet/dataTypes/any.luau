local bufferWriter = require(script.Parent.Parent.bufferWriter)
local types = require(script.Parent.Parent.types)
local alloc = bufferWriter.alloc
local u8 = bufferWriter.u8
local bool = require(script.Parent.bool)
local buff = require(script.Parent.buff)
local cframe = require(script.Parent.cframe)
local float64 = require(script.Parent.float64)

local string = require(script.Parent.string)
local optional = require(script.Parent.optional)
local vec2 = require(script.Parent.vec2)
local vec3 = require(script.Parent.vec3)


local DataTypes = {
	{typeof(nil),optional(bool())},
	{type(1),float64()},
	{type(true),bool()},
	{typeof(""),string()},
	{typeof(buffer.create(0)),buff()},
	{typeof(CFrame.new()),cframe()},
	{typeof(Vector3.new()),vec3()},
	{typeof(Vector2.new()),vec2()},
}

local keyPairs = {}
local keyIndex = {}
local indexPairs = {}
local indexName = {}

for i,v in DataTypes do
	keyIndex[v[1]] = i
	keyPairs[v[1]] = v[2]
	indexPairs[i] =v[2]
 	indexName[i] = v[1]
end

local float32 = {
	write = function(value)
		local type = typeof(value)
		local dataType,idx = keyPairs[type],keyIndex[type]
		if not type then
			dataType = indexPairs[1]
			idx = 1
			idx = nil
		end
		alloc(1)
		u8(idx)
		dataType.write(value)
	end,

	read = function(b: buffer, cursor: number)
		local idx = buffer.readu8(b, cursor)
		cursor+=1
		local dataType =  indexPairs[idx]
		local value,l = dataType.read(b,cursor)
		return value,l+1

	end,
	isType = function(value)
		return true
	end
}

return function(): types.dataTypeInterface<number>
	return float32
end
