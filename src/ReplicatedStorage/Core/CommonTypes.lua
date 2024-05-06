export type Connection = {
	Disconnect: (self: any) -> ()
}

export type Signal<T...> = {
	Fire: (self: any, T...) -> (),
	Connect: (self: any, FN: (T...) -> ()) -> Connection,
	Once: (self: any, FN: (T...) -> ()) -> Connection,
	Wait: (self: any) -> T...,
	DisconnectAll: (self: any) -> ()
}

export type ProtectedSignal<T...> = {
	Fire: (self: any, T...) -> (),
	DisconnectAll: (self: any) -> (),
	Event : ProtectedEvent<T...>
}

export type ProtectedEvent<T...> = {
    Connect: (self: any, FN: (T...) -> ()) -> Connection,
    Once: (self: any, FN: (T...) -> ()) -> Connection,
    Wait: (self: any) -> T...,
}

export type Entity = {
    [any]:any,
    Position : Vector3,
    Rotation : number,
    HeadRotation : Vector2,
    Type : string,
    Guid : string,
    died : boolean?,
}


--//InputService
export type Action = string | 'Forward' | 'Left' | 'Right' | 'Back' | 'Jump' | 'Attack' | 'Interact' | 'Crouch' | 'HitBoxes' | 'Freecam' | 'Inventory'

export type ControllerEvent = Signal<EnumItem,boolean,string,{number:string}>
export type TempControllerEvent = ControllerEvent & {
    Destroy: (self: any) -> (),
}


export type RayResults = {
    normal:Vector3,
    entity:Entity?,
    block:number?,
    grid:Vector3,
    hit:Vector3
}




return {}