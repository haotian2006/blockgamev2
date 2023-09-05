local Components = {}
Components.BlockComp = {
    CanFloat = true,
    Gravity = nil,
    Hardness = 1, 
    CanCollide = true,
    BlastResistance = 0,
    CanRotate = false,
    Hitbox = 'Normal',
    Transparency = false,-- should blocks render behind 
    RotateX = false,
    RotateY = false,
    RotateZ = false,
}
Components.Inputs = {
    AlsoHold = {},
    Trigger = nil,
    Weight = -1,

    HasToBeInHand = true,
    HasToBeInHotBar =true,
    CanActivateInGui = false; 
} 

return Components