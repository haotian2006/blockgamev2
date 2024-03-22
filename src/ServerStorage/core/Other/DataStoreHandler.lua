local Config = require(game.ReplicatedStorage.WorldConfig)
local DataStoreService = game:GetService("DataStoreService")

local Store = {}

local mockStore = {
    info = {},
    SetAsync = function(self,x,d) 
        self.info[x] = d
    end ,
    UpdateAsync = function() 
    
    end ,
    GetAsync = function(self,k) 
        return self.info[k]
    end ,
}

function Store.canSave()
    return Config.SavingEnabled
end

function Store.getWorldStore(Options)
    return if Config.SavingEnabled then DataStoreService:GetDataStore("WORLD",Config.WorldGuid,Options) else mockStore
end


return Store