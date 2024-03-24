local Config = {}

local Info = {
    Seed = 3456713,
    WorldGuid = "1sa",
    SavingEnabled = false,
}
Info.__index = Info
Info.__newindex = Info

local Synchronizer = require(game.ReplicatedStorage.Synchronizer)
local Loading = Instance.new("BindableEvent")

function Config.load()
     
end

local initAlready = false

Synchronizer.setClientModifier("WorldConfig", function(data)
    local cloned = table.clone(data)
    cloned.Seed = nil
    cloned.WorldGuid = nil
    return cloned
end)

function Config.Init()
    if initAlready then return end 
    initAlready = true
    if Synchronizer.isActor() then
        Info = Synchronizer.getDataActor("WorldConfig")
    elseif Synchronizer.isClient() then
        Info = Synchronizer.getDataClient("WorldConfig")
    else
        Info.__index = nil
        Info.__newindex = nil
        Synchronizer.setData("WorldConfig",table.clone(Info))
    end
    local t = Loading
    Loading = nil
    t:Fire()
    Info.__index = Info
    Info.__newindex = Info
    setmetatable(Config,Info)
    return Config
end

return setmetatable(Config, Info)