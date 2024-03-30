local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Entities = require(script.entity)
local Serializer = require(script.Serializer)
local SerializerTypes = require(script.Serializer.types)
local CommonTypes = require(script.CommonTypes)

local ISCLIENT = RunService:IsClient()
local Modules = {
    Shared = {
        Serializer = require(script:FindFirstChild("Serializer"))
    },
    DataTypes = Serializer.Types,
    Initiated = false
}

local Server = {}
local Shared = {
    Ray = "CollisionHandler.Ray",
    ItemService = "Item",
    BlockService = "Block",
    EntityService = "EntityHandler",
    DataService = "Data"
    
}
local Client = {
    InputService = "InputHandler",
    Controller = "Controller",
    Helper = "Helper",
    ResourceHandler = ReplicatedStorage:FindFirstChild("ResourceHandler"),
    ClientService = "core.ClientManager"
}

export type dataTypeInterface<T> = SerializerTypes.dataTypeInterface<T>
export type Serializer = Serializer.Serializer

export type Entity = CommonTypes.Entity
export type EntityService = Entities.EntityHandler

export type Connection = CommonTypes.Connection

export type Signal<T...> = CommonTypes.Signal<T...>

export type ProtectedSignal<T...> = CommonTypes.ProtectedSignal<T...>
export type ProtectedEvent<T...> = CommonTypes.ProtectedEvent<T...>



export type Action = string | 'Foward' | 'Left' | 'Right' | 'Back' | 'Jump' | 'Attack' | 'Interact' | 'Crouch' | 'HitBoxes' | 'Freecam' | 'Inventory'

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
    getRay : () -> RayResults,
    setRayLength : (Length:number) -> (),
    setHighlighting : (Value:boolean) ->(),
    getHighlighting : () -> boolean,
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

export type RayResults = {
    normal:Vector3,
    entity:Entity?,
    block:number?,
    grid:Vector3,
    hit:Vector3
}

export type Ray = {
    cast : (Start:Vector3,Direction:Vector3) -> RayResults
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
    createItemModel : (Item:Item) -> (BasePart?,ItemInfo),
    getName : (Item:Item) -> string,
    getIndexFromName : (name:string) -> number,
    getNameFromIndex : (idx:number) -> string,
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

export type ClientService = {
    SendRespawnEvent : ()->(),
}

export type DataService = {
    getPlayerEntity: ()->Entity?,
}

export type Client = {
    awaitModule:(module:string)->{},
    InputService : InputService,
    Controller : Controller,
    Helper : ClientHelper,
    ResourceHandler : ResourceHandler,
    ClientService : ClientService
}

export type Shared = {
    awaitModule:(module:string)->{},
    Ray : Ray,
    ItemService : ItemClass,
    BlockService : BlockClass,
    EntityService : Entities.EntityHandler,
    Serializer : Serializer.Serializer,
    DataService : DataService,

}

export type Server = {
    awaitModule:(module:string)->{},
}



export type Types =  {
    entity:Entity
}

export type core = {
    Client:Client?,
    Server:Server?,
    Shared:Shared,
    await:(core:"Client"|"Server"|"Shared") -> {Client|Server|Shared},
    Initiated : boolean,

}


local toResume = {}
local Init = false
local function awaitWrapper(toWait)
    return function(module)
        if not Init then
            local running = coroutine.running()
            table.insert(toResume,running)
            coroutine.yield()
          end
          return toWait[module] 
    end
end



Modules.await = awaitWrapper(Modules)
Modules.Shared.awaitModule = awaitWrapper(Modules.Shared)

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
            Modules.Client.awaitModule = awaitWrapper(Modules.Client)
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
            Modules.Server.awaitModule = awaitWrapper(Modules.Server)
        end
    end
    for i,v in Shared do
        local pass,data = requireFromPath(game.ReplicatedStorage, v)
        if not pass then
            warn(`Shared: {i} Could not be found for path {v} error: {data}`)
        else
            Modules.Shared[i] = data
        end
    end


    Modules.Initiated = true
    Init = true
    for i,v in toResume do
        task.spawn(v)
    end
    Modules[`{"init"}`] = nil -- to get pass typechecking  
    table.freeze(Modules)
end

return Modules::core