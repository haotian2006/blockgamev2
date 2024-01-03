return {
    ["c:Grass"] = {
        name = "c:Grass",
        noiseSettings = "c:foliageNoise",
           isfoliage = true, -- structure will only change on the y-axis (better performance)
           override = false, --deafult true, if false then would not override blocks 
   
           noise_Range = {
               multiplier  = 200, 
               {  
                   min = -0.24,
                   max =  -0.235,
               },
               {  
                   min = 1.55,
                   max =  1.58,
               },
               {  
                   min = -1.407,
                   max =  -1.40,
               },
               {  
                   min = -1.99,
                   max =  -1.97,
               },
           },
           structure = {
              key = {
              "c:Grass"
            },
              layout = {
                {0,1,0,1},
              }
           }  
    },
    ["c:Tree"] =  {
        name = "c:Tree",
       -- noiseSettings = "c:treeNoise",
        noiseSettings = "c:foliageNoise",
        isfoliage = false, -- structure will only change on the y-axis (better performance)
        override = false, --deafult true, if false then would not override blocks 

        noise_Range = {
            multiplier  = 200, 
          {   
            min = -1.00,
            max =  -0.994,
          }
        },
        structure = {
           key = {{
            "c:Wood",
            "1,0,0"
           },
           "c:Leaf"
         },
           layout = {
              {0,1,0,1},
              {0,2,0,1},
              {0,3,0,1},
              {0,4,0,1},  
                {-1,4,0,2},{-2,4,0,2}, {-1,4,1,2},{-2,4,1,2}, {-1,4,-1,2},{-2,4,-1,2}, {-1,4,2,2},{-1,4,-2,2}, {1,4,0,2},{2,4,0,2}, {1,4,1,2},{2,4,1,2}, {1,4,-1,2},{2,4,-1,2}, {1,4,2,2},{1,4,-2,2}, 
                 {0,4,1,2},  {0,4,2,2},{0,4,-1,2},  {0,4,-2,2}, 
              {0,5,0,1},
                {-1,5,0,2},{-2,5,0,2}, {-1,5,1,2},{-2,5,1,2}, {-1,5,-1,2},{-2,5,-1,2}, {-1,5,2,2},{-1,5,-2,2}, {1,5,0,2},{2,5,0,2}, {1,5,1,2},{2,5,1,2}, {1,5,-1,2},{2,5,-1,2}, {1,5,2,2},{1,5,-2,2}, 
                {0,5,1,2},  {0,5,2,2},{0,5,-1,2},  {0,5,-2,2}, 
              {0,6,0,2},
                  {-1,6,0,2},{-1,6,1,2},{-1,6,-1,2},    {1,6,0,2},{1,6,1,2},{1,6,-1,2},    {0,6,-1,2},{0,6,1,2},
              {0,7,0,2},
           }
        }
     },
}