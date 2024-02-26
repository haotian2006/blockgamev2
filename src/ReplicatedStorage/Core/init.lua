local ReplicatedStorage = game.ReplicatedStorage
local RunService = game:GetService("RunService")

local ISCLIENT = RunService:IsClient()

local Modules = {

}

local Server = {}
local Shared = {
    Ray = "CollisionHandler.Ray",
    ItemService = "Item",
    BlockService = "Block"
}
local Client = {
    InputService = "InputHandler",
    Controller = "Controller",
    Helper = "Helper",
    ResourceHandler = ReplicatedStorage.ResourceHandler,
}


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


export type Action = string | 'Foward' | 'Left' | 'Right' | 'Back' | 'Jump' | 'Attack' | 'Interact' | 'Crouch' | 'HitBoxs' | 'Freecam' | 'Inventory'
export type ControllerEvent = Signal<EnumItem,boolean,string,{number:string}>
export type TempControllerEvent = ControllerEvent & {
    Destroy: (self: any) -> (),
}

export type InputService = {
    createTemporyEventTo : (Action:Action) -> TempControllerEvent,
    getOrCreateEventTo : (Action:Action) -> ControllerEvent,
    destroyAllEventsFor : (Action:Action) -> (),
    bindToRender : (Name:string,callback:(dt:number)->()) -> (),
    unbindFromRender : (Name:string) -> (),
    bindFunctionTo : (Name:string, callback:(Action:Action,IsDown:boolean,gpe:boolean,keys:{})->boolean,Action:Action,Priority:number) ->(),
    unbindFunction : (Name:string) -> (),
    isDown : (Name:Action) -> boolean,
    inGui : () -> boolean
}

export type ResourceHandler = {
    getAsset : (name:string) ->any,
    getBlockData : (name:string,id:number?) -> {},
    getEntityModel : (name:string) -> {
        Model :Model,
        Animations : {},
    }
}

export type ClientHelper = {
    insertBlock : (x:number,y:number,z:number,block:number) -> ()
}

export type Mouse = {
    getRay : () -> {
        Block : number,
        BlockPosition : Vector3,
        HitPosition : Vector3,
        Normal : Vector3,
    },
    setRayLength : (Length:number) -> (),
    setHighlighting : (Value:boolean) ->(),
    getHighlighting : () -> boolean,
    update : () -> (),

}
type x<t> = {
    t
}
local y:x<number> = {
     1
}
local y = {}::{x<number>}
export type Controller = {
    getMouse : () -> Mouse
}

export type Ray = {
    cast : (Start:Vector3,Direction:Vector3) -> (number,Vector3,Vector3,Vector3)
}

export type Item = {
    string|number|{}
}

export type ItemInfo = {
    Name : string,
    DisplayName : string,
    Id : number,
    Icon : string|(Item:Item)->string,
    Texture : string|{}|(Item:Item)->(string|{}),
    Mesh : BasePart,
    RenderHand : boolean,
    AllData : {},
}

export type ItemClass = {
    new: (Name:string,Id:number) -> Item,
    equals: (Item1:Item,Item2:Item|string,Id:number?) -> boolean,
    getDataFrom: (Name:string,Id:number) -> {},
    getData:(Item:Item) -> {},
    getMaxCount:(Item:Item) -> number,
    get : (Item:Item,Key:string) -> any,
    getItemInfoR : (Item:Item) -> ItemInfo,
    createItemModel : (Item:Item) -> (BasePart?,ItemInfo)
}

export type BlockClass = {
    exists : (Str:string) ->boolean,
    getBlockId : (Str:string) -> number?,
    getBlock : (Id:number) -> string?,
    compress : (BlockId:number,Rotation:number?,Variant:number?) -> number,
    decompress : (PackedValue:number) -> (number,number,number),
    decompressCache : (PackedValue:number) -> (number,number,number),
    parse : (Data:number|{}) -> number
}


export type Client = {
    InputService : InputService,
    Controller : Controller,
    Helper : ClientHelper,
    ResourceHandler : ResourceHandler,
}

export type Shared = {
    Ray : Ray,
    ItemService : ItemClass,
    BlockService : BlockClass,
}

export type Server = {

}

export type core = {
    Client:Client?,
    Server:Server?,
    Shared:Shared,
}


function Modules.init()
    local function requireFromPath(parent,path)
        local pass,data = pcall(function(...)  
            if typeof(path) == "Instance" then
                return require(path)
            end
            local splitted = string.split(path,".")
            local path = parent 
            for _,next_ in splitted do
                path = path[next_]
            end
            return require(path)
        end)
        
        return pass,data
    end
    if ISCLIENT then
        local PlayerScript = game:GetService("Players").LocalPlayer.PlayerScripts
        Modules.Client = {}
        for i,v in Client do
            local pass,data = requireFromPath(PlayerScript, v)
            if not pass then
                warn(`Client {i} Could not be found for path {v} error: {data}`)
            else
                Modules.Client[i] = data
            end
        end
    else
        Modules.Server = {}
        for i,v in Server do
            local pass,data = requireFromPath(game:GetService("ServerStorage"), v)
            if not pass then
                warn(`Server {i} Could not be found for path {v} error: {data}`)
            else
                Modules.Server[i] = data
            end
        end
    end
    Modules.Shared = {}
    for i,v in Shared do
        local pass,data = requireFromPath(game.ReplicatedStorage, v)
        if not pass then
            warn(`Shared: {i} Could not be found for path {v} error: {data}`)
        else
            Modules.Shared[i] = data
        end
    end

    Modules[`{"init"}`] = nil -- to get pass typechecking  
    table.freeze(Modules)
end

return Modules::core