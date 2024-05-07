local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Client_Type = require(script.Client_Types)
local Shared_Type = require(script.Shared_Types)
local Server_Type = require(script.Server_Types)


local ISCLIENT = RunService:IsClient()
local Modules = {
    Shared = {
        Serializer = require(script:FindFirstChild("Serializer"))
    },



    Initiated = false
}

local Server = {}
local Shared = {
    Ray = "CollisionHandler.Ray",
    ItemService = "Handler.Item",
    BlockService = "Handler.Block",
    EntityService = "Handler.EntityHandler",
    DataService = "Data",
    StatsService = "Libs.Stats"
    
}
local Client = {
    InputService = "InputHandler",
    Controller = "Controller",
    Helper = "Helper",
    ResourceService = ReplicatedStorage:FindFirstChild("ResourceHandler"),
    ClientService = "core.ClientManager"
}



export type Client = {
    awaitModule:(module:string)->{},
}&Client_Type.Client

export type Shared = Shared_Type.Shared
export type Server = {
    awaitModule:(module:string)->{},
}


export type core = {
    Client:Client?,
    Server:Server?,
    Shared:Shared,
    await:(core:"Client"|"Server"|"Shared") -> {Client|Server|Shared},
    Initiated : boolean,


    Self : ModuleScript,
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