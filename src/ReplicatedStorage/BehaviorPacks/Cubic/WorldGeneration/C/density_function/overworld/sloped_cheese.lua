return{
    type = "C:add",
    argument1 = {
      type = "C:mul",
      argument1 = 4.0,
      argument2 = {
        type = "C:quarter_negative",
        argument = {
          type = "C:mul",
          argument1 = {
            type = "C:add",
            argument1 = "C:overworld/depth",
            argument2 = {
              type = "C:mul",
              argument1 = "C:overworld/jaggedness",
              argument2 = {
                type = "C:half_negative",
                argument = {
                  type = "C:noise",
                  noise = "C:jagged",
                  xz_scale = 1500.0, 
                  y_scale = 0.0
                }
              }
            }
          },
          argument2 = "C:overworld/factor"
        }
      }
    },
    argument2 = 0--"C:overworld/base_3d_noise"
  }