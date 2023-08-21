return {
    type = "C:mul",
    argument1 = -3.0,
    argument2 = {
        type = "C:add",
        argument1 = -0.3333333333333333,
        argument2 = {
            type = "C:abs",
            argument = {
                type = "C:add",
                argument1 = -0.6666666666666666,
                argument2 = {
                    type = "C:abs",
                    argument = "C:overworld/ridges"
                }
            }
        }
    }
}