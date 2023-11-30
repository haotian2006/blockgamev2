return {
    type = 'set',
    argument  ={
        type = "c:add",
        argument1 = {
            type = "c:y_clamped_gradient",
            from_value = 1.5,
            from_y = -64,
            to_value = -1.5,
            to_y = 320
        },
        argument2 = {
            type = 'reference',
            key = 'offset'
        }
    },
    key = 'depth'
}