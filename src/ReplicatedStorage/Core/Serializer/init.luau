-- THIS IS A MODIFYED VERSION OF BYTENET MADE FOR TABLE TO BUFFER CONVERSION BY HAOTIAN2006
-- ORIGINAL VERSION BY ffrostfall https://devforum.roblox.com/t/Serializer-an-advanced-networking-library-w-buffer-serialization-strict-luau-and-absurd-optimization-031/2733365

local array = require(script.dataTypes.array)
local bool = require(script.dataTypes.bool)
local buff = require(script.dataTypes.buff)
local cframe = require(script.dataTypes.cframe)
local float32 = require(script.dataTypes.float32)
local float64 = require(script.dataTypes.float64)
local int16 = require(script.dataTypes.int16)
local int32 = require(script.dataTypes.int32)
local int8 = require(script.dataTypes.int8)
local map = require(script.dataTypes.map)
local optional = require(script.dataTypes.optional)
local string = require(script.dataTypes.string)
local struct = require(script.dataTypes.struct)
local specialStruct = require(script.dataTypes.specialStruct)
local uint16 = require(script.dataTypes.uint16)
local uint32 = require(script.dataTypes.uint32)
local uint8 = require(script.dataTypes.uint8)
local vec2 = require(script.dataTypes.vec2)
local vec3 = require(script.dataTypes.vec3)
local any = require(script.dataTypes.any)
local nothing = require(script.dataTypes.nothing)
local Parse = require(script.dataTypes.parse)
local Parser = require(script.Parser)
local types = require(script.types)
local Writter = require(script.bufferWriter)


export type Serializer =  {
	
	wrap : <T>(Value: T) -> types.Parser<T>,
	writter : typeof(Writter),
	Types: DataTypes
}

export type DataTypes = types.DataTypes

return ( 
	table.freeze({
		wrap = Parser,
		writter = Writter,
		Types = table.freeze({

			bool = bool(),

			uint8 = uint8(),
			uint16 = uint16(),
			uint32 = uint32(),
			int8 = int8(),
			int16 = int16(),
			int32 = int32(),
			float32 = float32(),
			float64 = float64(),
			cframe = cframe(),
			string = string(),
			nothing = nothing(),
			any = any(),
			vec2 = vec2(),
			vec3 = vec3(), 
			buff = buff(),
			
			parse = Parse,
			array = array,
			optional = optional,
			struct = struct,
			specialStruct = specialStruct,
			map = map,

			entity = require(game.ReplicatedStorage.EntityHandler.Parser)(),
			item = require(game.ReplicatedStorage.Handler.Item.Parser)(),
			container = require(game.ReplicatedStorage.Handler.Container.Parser)(),
		})
	}) :: any
) :: Serializer
