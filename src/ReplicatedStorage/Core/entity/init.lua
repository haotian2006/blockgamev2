local Types = require(script.Parent.Serializer.types)
local CommonTypes = require(script.Parent.CommonTypes)

type Entity = CommonTypes.Entity

export type EntityHandler = {
    

    getAndCache : (self: Entity, key : string) -> any,
    getHitbox :(self:Entity) ->Vector3,
    get : (self: Entity, key : string) -> any,
    set : (self:Entity, key :string) ->(),
    rawSet : (self:Entity, key :string) ->(),
    isType : (self:Entity, type : string) -> boolean,
    new :(type:string,GUID:number?) -> Entity,
    getPropertyChanged : (self:Entity,property:string) -> CommonTypes.ProtectedEvent<any>
}

export type FieldTypes = {
    getIndexFromField : (Field:string) -> number?,
    getKeyFromIndex : (Index:number) -> string?,
    getParserFromField : (Field:string) -> Types.Parser<any>
}

return {}