local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local AllData = BehaviorHandler.getAllData()
local Block = require(game.ReplicatedStorage.Block)
local Features = game.ServerStorage.Generation.generation.features
local Biomes = {}
local StructureMain = require(Features.structures)
local OresMain = require(Features.ore)
local FoilageMain = require(Features.foliage)
local WormsMain = require(Features.caves.perlineWorms)

local Registry = {}
local Registered = {
    Biomes = Biomes::Biome,
    Structures = {}:: StructureMain.Structure,
    Ores = {}:: OresMain.Ore,
    Foliage = {}:: FoilageMain.Foliage
}

export type Biome = {
    Alias :string,

    Elevation : number,
    Factor : number,
    NoiseScale : number,
    SurfaceScale : number,

    SecondaryLength : number,
    Caves: boolean,
    MainBlock : number,
    SurfaceBlock : number,
    SecondaryBlock : number,
    Structures : StructureMain.Structure,
    Ores : OresMain.Ore,
    Foliage : FoilageMain.Foliage
}

local Order = {
    "Foliage","Ores","Structures","Biomes"
}

local parseFunc = {}

function parseFunc.Foliage(data,name)
    if name and Registered.Foliage[name] then return Registered.Foliage[name] end
    local parsed = FoilageMain.parse(data)
    if name then
        Registered.Foliage[name] = parsed
    end
    return parsed 
end

function parseFunc.Ores(data,name)
    if name and Registered.Ores[name] then return Registered.Ores[name] end
    local parsed = OresMain.parse(data)
    if name then
        Registered.Ores[name] = parsed
    end
    return parsed 
end

function parseFunc.Structures(data,name)
    if name and Registered.Structures[name] then return Registered.Structures[name] end
    local parsed = StructureMain.parse(data)
    if name then
        Registered.Structures[name] = parsed
    end
    return parsed 
end

local function loopFeaturesAndAdd(feature,children,parser)
    if type(children) ~= "table" then return end 
    for i,v in children do
        if type(v) == "string" then
            local Struc = Registered[feature][v]
            if not Struc then
                children[i] = false
                continue
            end
            children[i] = Struc
        elseif type(v) == "table" then
            if type(v.Parent) == "string" then
                local Struc = Registered[feature][v.Parent]
                if not Struc then
                    children[i] = false
                    continue
                end
                local parsed = parser(v)
                for key,value in Struc do
                    if v[key] then continue end 
                    parsed[key] = value
                end
                children[i]  = parsed
            else
                local parsed = parser(v)
                children[i]  = parsed
            end
        end
    end
end

function parseFunc.Biomes(data,name)
    if name and Registered.Biomes[name] then return Registered.Biomes[name] end
    local Parsed = {
        Alias = name,

        Elevation = data.Elevation or 1,
        Factor = data.Factor or 1,
        NoiseScale = data.NoiseScale or 1,
        SurfaceScale = data.SurfaceScale or 1,

        Caves = data.Caves or false,
        SecondaryLength = data.SecondaryLength or 4,

        MainBlock = if data.MainBlock then Block.parse(data.MainBlock) else 1,
        SurfaceBlock = if data.SurfaceBlock then Block.parse(data.SurfaceBlock) else 1,
        SecondaryBlock = if data.SecondaryBlock then Block.parse(data.SecondaryBlock) else 1,
        Structures = data.Structures or {},
        Ores = data.Ores or {},
        Foliage = data.Foliage or {}
    }

    loopFeaturesAndAdd("Structures",Parsed.Structures,StructureMain.parse)
    loopFeaturesAndAdd("Ores",Parsed.Ores,OresMain.parse)
    loopFeaturesAndAdd("Foliage",Parsed.Foliage,FoilageMain.parse)


    if name then
        Registered.Biomes[name] = Parsed
    end
    return Parsed
end

function Registry.init()
    for _,comp in Order do
        local info = AllData[comp]
        local parse = parseFunc[comp]
        for name,data in info do
            if name == "ISFOLDER" then continue end 
            parse(data,name)
        end
    end 
    StructureMain.addRegirstry(Biomes)
    OresMain.addRegirstry(Biomes)
    FoilageMain.addRegirstry(Biomes)
    WormsMain.addRegirstry(Biomes)
end

local DEFAULTBIOME = parseFunc.Biomes({})

function Registry.getBiome(biome):Biome
    if not biome then return DEFAULTBIOME end 
    return Registered.Biomes[biome] or DEFAULTBIOME
end


return Registry