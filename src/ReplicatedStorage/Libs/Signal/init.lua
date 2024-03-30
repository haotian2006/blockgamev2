local Signal = {}

local Good = require(script.Good)
local Fast = require(script.Fast)
local Protected = require(script.Protected)



function Signal.new(IsFast)
    return if IsFast then Fast.new() else Good.new()
end

function Signal.protected()
	return Protected.new()
end

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

export type Protected<T...> = {
	Fire: (self: any, T...) -> (),
	DisconnectAll: (self: any) -> (),
	Event : {
		Connect: (self: any, FN: (T...) -> ()) -> Connection,
		Once: (self: any, FN: (T...) -> ()) -> Connection,
		Wait: (self: any) -> T...,
	}
}


return Signal:: {new: (isFast:boolean?) -> Signal<...any>,protected:() -> Protected<...any>}