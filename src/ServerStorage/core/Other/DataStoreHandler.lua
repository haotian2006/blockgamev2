local Config = require(game.ReplicatedStorage.WorldConfig)
local DataStoreService = game:GetService("DataStoreService")

local Store = {}

function Store.getWorldStore(Options)
    return DataStoreService:GetDataStore("WORLD",Config.WorldGuid,Options)
end

return Store