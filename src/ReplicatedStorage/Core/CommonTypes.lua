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


return {}