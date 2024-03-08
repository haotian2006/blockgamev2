return {
   {
      NameSpace = 'c:plains',

      Elevation  = 10, 
      Factor = 100, 
      NoiseScale = .4, 
      SurfaceScale = .1,

      SecondaryBlock = 'c:dirt',
      MainBlock = "c:stone",


      -- Elevation  = 14,
      -- Factor =150,
      -- NoiseScale = 1,
      -- SurfaceScale = 1,

       Caves = true,
      -- --.01,
      -- --SurfaceBlock = 'c:grassBlock',
      -- SecondaryBlock = 'c:dirt',
      -- MainBlock = "c:stone",
      Structures = {
         "c:tree"
      }
   },
   { 
    NameSpace = 'c:ocean',
    Elevation = 11,
    Factor = 100,

   },
   { 
      NameSpace = 'c:snow',
      Elevation = 14,
      Factor = 300,
      SurfaceBlock = {'c:grassBlock',0,1},
      NoiseScale = .5,
      SurfaceScale = 1,
      Caves = true,
      Structures = {
         "c:tree"
      }, 
      Ores = {
         {
            Parent = "c:purple",
            chance = 12,
            
      }
      }

   },
   { 
      NameSpace = 'c:hill',
      Elevation = 14,
      Factor = 100,
      SurfaceScale = .1;
      NoiseScale = .1,
   
     

   },
     { 
      NameSpace = 'c:desert',
      Elevation = 7,
      Factor = 50,
  

     },
  
} 