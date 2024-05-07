local layers = require(game.ServerStorage.Generation.generation.biomes.layers)
layers.Init()
local WorldConfig = require(game.ReplicatedStorage.WorldConfig)
local SEED = WorldConfig.Seed

local stuff = {}
local Noise = {}
local function add(x)
    table.insert(stuff,x)
    return x
end

local Base = add(layers.create("BaseLandLayer",SEED,2))

Base = add(layers.create("ScaleLayer",SEED,300,"FUZZY",Base))
Base = add(layers.create("LandLayer",SEED,1,Base))
Base = add(layers.create("ScaleLayer",SEED,4,"NORMAL",Base))
Base = add(layers.create("LandLayer",SEED,2,Base))

Base = add(layers.create("LandLayer",SEED,50,Base))
Base = add(layers.create("LandLayer",SEED,70,Base))
Base = add(layers.create("IslandLayer",SEED,2,Base))

Base = add(layers.create("ColdLayer",SEED,2,Base))

-- Base = add(layers.create("LandLayer",SEED,3,Base))
-- Base = add(layers.create("WarmLayer",SEED,2,Base))
-- Base = add(layers.create("CoolLayer",SEED,5,Base))

--Base = add(layers.create("SpecialLayer",SEED,2,Base))

Base = add(layers.create("ScaleLayer",SEED,2002,"NORMAL",Base))

Base = add(layers.create("ScaleLayer",SEED,2003,"NORMAL",Base))

Base = add(layers.create("LandLayer",SEED,4,Base))

Base = add(layers.create("ScaleLayer",SEED,2004,"NORMAL",Base))

Base = add(layers.create("LandLayer",SEED,2,Base))

Base = add(layers.create("ScaleLayer",SEED,2005,"NORMAL",Base))

 Base = add(layers.create("ScaleLayer",SEED,2006,"NORMAL",Base))
 Base = add(layers.create("ScaleLayer",SEED,2007,"NORMAL",Base))
Base = add(layers.create("ScaleLayer",SEED,2008,"NORMAL",Base))
Base = add(layers.create("ScaleLayer",SEED,2009,"NORMAL",Base))
Base = add(layers.create("SmoothScaleLayer",SEED,2010,Base))
Base = add(layers.create("VoronoiLayer",SEED,2,Base))
return Base