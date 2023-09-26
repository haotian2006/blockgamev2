return {
    ["c:Grass"] =  {
        name = "c:grass",
        noiseSettings = "c:treeNoise",
        isFoilage = true,
        noise_Range = {
            {  
                multiplier  = 200,
                min = -0.24,
                max =  -0.235,
            }
        },
        structure = {
           key = {"c:Grass"},
           layout = {
              Vector2int16.new(1,1)
           }
        }
     },
     ["c:Drass"] =  {
        name = "c:drass",
        noiseSettings = {
            amplitudes = { 1.0, 1.0, 0.0, 1.0, 1.0 },
            firstOctave = -9
        },
        isFoilage = true,
        noise_Range = {
          { 
            multiplier  = 1,
           min = 0,
           max = 1,
            }
        },
        structure = {
           key = {"c:Grass"},
           layout = {
              Vector2int16.new(1,1)
           }
        }
     },
}