local gameSettings = require(game.ReplicatedStorage.GameSettings)
return {
    RegionSize = gameSettings.RegionSize,
    Actors = 2, 

    --//Debris
    MaxTimeDebris = 5,
    --//Looping
    MaxCarver = 15,
    MaxBuild = 15,
    MaxFeature = 15,
    MaxResume = 300,

    StructureRange = 10,

    OnClose = false,
    HasToCompress = false,
} 