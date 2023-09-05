return {
    type = "c:mul",
    argument1 = -3.0,
    argument2 = {
        type = "c:add",
        argument1 = -0.3333333333333333,
        argument2 = {
            type = "c:abs",
            argument = {
                type = "c:add",
                argument1 = -0.6666666666666666,
                argument2 = {
                    type = "c:abs",
                    argument = "c:overworld/ridges"
                }
            }
        }
    }
}