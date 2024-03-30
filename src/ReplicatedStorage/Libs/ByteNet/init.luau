local RunService = game:GetService("RunService")

local Core = game.ReplicatedStorage.Core
local dataTypes = Core.Serializer.dataTypes

local clientProcess = require(script.process.client)
local array = require(dataTypes.array)
local bool = require(dataTypes.bool)
local buff = require(dataTypes.buff)
local cframe = require(dataTypes.cframe)
local float32 = require(dataTypes.float32)
local float64 = require(dataTypes.float64)
local int16 = require(dataTypes.int16)
local int32 = require(dataTypes.int32)
local int8 = require(dataTypes.int8)
local map = require(dataTypes.map)
local nothing = require(dataTypes.nothing)
local optional = require(dataTypes.optional)
local string = require(dataTypes.string)
local struct = require(dataTypes.struct)
local uint16 = require(dataTypes.uint16)
local uint32 = require(dataTypes.uint32)
local uint8 = require(dataTypes.uint8)
local vec2 = require(dataTypes.vec2)
local vec3 = require(dataTypes.vec3)
local any = require(dataTypes.any)


local namespace = require(script.namespaces.namespace)
local definePacket = require(script.packets.definePacket)
local serverProcess = require(script.process.server)
local values = require(script.replicated.values)
local types = require(script.types)

values.start()

if RunService:IsServer() then
	serverProcess.start()
else
	clientProcess.start()
end

return (
	table.freeze({
		definePacket = definePacket,
		defineNamespace = namespace,

		array = array,
		bool = bool(),
		optional = optional,
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
		vec2 = vec2(),
		vec3 = vec3(),
		buff = buff(),
		struct = struct,
		map = map,
		nothing = nothing(),
		any = any(),
	}) :: any
) :: types.ByteNet
