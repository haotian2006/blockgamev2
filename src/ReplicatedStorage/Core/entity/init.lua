local Types = require(script.Parent.ByteNet.types)
export type Entity = {
    [any]:any,
    Position : Vector3,
    Rotation : number,
    HeadRotation : Vector2,
    Type : string,
    Guid : string,
}


export type EntityHandler = {
    

    getAndCache : (self: Entity, key : string) -> any,
    getHitbox :(self:Entity) ->Vector3,
    get : (self: Entity, key : string) -> any,
    set : (self:Entity, key :string) ->(),
    rawSet : (self:Entity, key :string) ->(),
    isType : (self:Entity, type : string) -> boolean,
    new :(type:string,GUID:number?) -> Entity,
}

export type FieldTypes = {
    getIndexFromField : (Field:string) -> number?,
    getKeyFromIndex : (Index:number) -> string?,
    getParserFromField : (Field:string) -> Types.Parser<any>
}

return {}