local Types = require(script.Parent.Types)
local Serializer = require(script.Parent.Serializer)
local StatsService = require(script.StatsService)
local Entity = require(script.Entity)

type RayResults = Types.RayResults
type Item = Types.Item
type ItemInfo = Types.ItemInfo
type Entity = Types.Entity

export type Ray = {
    cast : (Start:Vector3,Direction:Vector3) -> RayResults
}

export type ItemClass = {
    new: (Name:string,Id:number) -> Item,
    equals: (Item1:Item,Item2:Item|string,Id:number?) -> boolean,
    getDataFrom: (Name:string,Id:number) -> {},
    getData:(Item:Item) -> {},
    getMaxCount:(Item:Item) -> number,
    get : (Item:Item,Key:string) -> any,
    getItemInfoR : (Item:Item) -> ItemInfo,
    createItemModel : (Item:Item) -> (BasePart?,ItemInfo),
    getName : (Item:Item) -> string,
    getIndexFromName : (name:string) -> number,
    getNameFromIndex : (idx:number) -> string,
}

export type BlockClass = {
    exists : (Str:string) ->boolean,
    getBlockId : (Str:string) -> number?,
    getBlock : (Id:number) -> string?,
    compress : (BlockId:number,Variant:number?,Rotation:number?) -> number,
    decompress : (PackedValue:number) -> (number,number,number),

    parse : (Data:number|{}) -> number
}

export type EntityService =  Entity.EntityHandler

export type DataService = {
    getPlayerEntity: ()->Entity?,
}

export type Shared = {
    awaitModule:(module:string)->{},
    Ray : Ray,
    ItemService : ItemClass,
    BlockService : BlockClass,
    EntityService : EntityService,
    Serializer : Serializer.Serializer,
    DataService : DataService,
    StatsService : StatsService.Stats

}

return {}