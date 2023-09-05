return{
    type = "c:add",
    argument1 = {
      type = "c:mul",
      argument1 = 4.0,
      argument2 = {
        type = "c:quarter_negative",
        argument = {
          type = "c:mul",
          argument1 = {
            type = "c:add",
            argument1 = "c:overworld/depth",
            argument2 = {
              type = "c:mul",
              argument1 = "c:overworld/jaggedness",
              argument2 = {
                type = "c:half_negative",
                argument = {
                  type = "c:noise",
                  noise = "c:jagged",
                  xz_scale = 1500.0, 
                  y_scale = 0.0
                }
              }
            }
          },
          argument2 = "c:overworld/factor"
        }
      }
    },
    argument2 = 0--"c:overworld/base_3d_noise"
  }