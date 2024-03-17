


export type channelData = {
	cursor: number,
	size: number,
	buff: buffer,
}

-- Used internally for serializing and deserializing all data types
export type dataTypeInterface<T> = {
	write: (value: T) -> (),
	read: (b: buffer, cursor: number) -> (T, number),
	isType : (value: T) -> (),
}



export type Parser<T> = {
	sterilize:(data: T) ->buffer, 
	desterilize:(data:buffer) ->T, 
}

-- Library type
export type DataTypes = {
	struct: <T>(format: T) -> dataTypeInterface<T>,
	specialStruct: <T>(format: T,order:{}) -> dataTypeInterface<T>,
	bool: boolean,
	array: <T>(value: T) -> { dataTypeInterface<T> },
	optional: <T>(value: T) -> dataTypeInterface<T>?,
	any:dataTypeInterface<any>,
	uint8: dataTypeInterface<number>,
	uint16: dataTypeInterface<number>,
	uint32: dataTypeInterface<number>,
	int8: dataTypeInterface<number>,
	int16: dataTypeInterface<number>,
	int32: dataTypeInterface<number>,
	float32: dataTypeInterface<number>,
	float64: dataTypeInterface<number>,
	string: dataTypeInterface<string>,
	vec3: dataTypeInterface<Vector3>,
	vec2: dataTypeInterface<Vector2>,
	buff: dataTypeInterface<buffer>,
	cframe: dataTypeInterface<CFrame>,
	map: <K, V>(key: K, value: V) -> { [dataTypeInterface<K>]: dataTypeInterface<V> },
	
	entity:dataTypeInterface<any>,
	item:dataTypeInterface<any>,
	container:dataTypeInterface<any>,

}

return nil
