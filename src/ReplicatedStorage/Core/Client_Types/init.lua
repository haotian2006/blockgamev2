local CommonTypes = require(script.Parent.Types)

type TempControllerEvent = CommonTypes.TempControllerEvent
type Action = CommonTypes.Action
type ControllerEvent = CommonTypes.ControllerEvent
type RayResults = CommonTypes.RayResults
type Entity = CommonTypes.Entity

export type InputService = {
    createTemporaryEventTo : (Action:Action) -> TempControllerEvent,
    getOrCreateEventTo : (Action:Action) -> ControllerEvent,
    destroyAllEventsFor : (Action:Action) -> (),
    bindToRender : (Name:string,callback:(dt:number)->()) -> (),
    unbindFromRender : (Name:string) -> (),
    bindFunctionTo : (Name:string, callback:(Action:Action,IsDown:boolean,gpe:boolean,keys:{})->boolean,Action:Action,Priority:number) ->(),
    unbindFunction : (Name:string) -> (),
    isDown : (Name:Action) -> boolean,
    inGui : () -> boolean
}

export type ResourceService = {
    getAsset : (name:string) ->any,
    getBlockData : (name:string,id:number?) -> {},
    getEntityModel : (name:string) -> {
        Model :Model,
        Animations : {},
    }
}

export type ClientHelper = {
    insertHoldingBlock : (x:number,y:number,z:number) -> ()
}

export type Mouse = {
    getRay : () -> RayResults,
    setRayLength : (Length:number) -> (),
    setHighlighting : (Value:boolean) ->(),
    isHighlighting : () -> boolean,
    update : () -> (),
}

export type Camera = {
    bindToEntity : (Entity:Entity?) -> (),
    setPos : (pos:Vector3) ->(),
    getCFrame : () -> CFrame,
    setMode : (Mode: "First"|"Second"|"Third") -> (),
    getMode : () -> "First"|"Second"|"Third"
}

export type Controller = {
    getMouse : () -> Mouse,
    getCamera : () -> Camera
}

export type ClientService = {
    SendRespawnEvent : ()->(),
}

export type Client = {
    awaitModule:(module:string)->{},
    InputService : InputService,
    Controller : Controller,
    Helper : ClientHelper,
    ResourceService : ResourceService,
    ClientService : ClientService
}

return {}